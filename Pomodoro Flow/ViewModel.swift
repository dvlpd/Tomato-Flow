//
//  ViewModel.swift
//  Pomodoro Flow
//
//  Created by Dan Kim on 2017-06-25.
//  Copyright © 2017 Dan K. All rights reserved.
//

import UIKit
import RxSwift

class ViewModel {
  // Output
  var timerLabel = PublishSubject<String>()
  var timerLabelColor = PublishSubject<UIColor>()
  var pomodorosCount = PublishSubject<Int>()

  // Internal
  private var secondsRemaining = BehaviorSubject<Int>(value: 0)
  private var currentState = BehaviorSubject<State>(value: .pomodoro)
  private var isRunning = PublishSubject<Bool>()

  private var timer: Timer?

  private let pomodoro = Pomodoro.sharedInstance
  private let settings = Settings.sharedInstance
  private let scheduler = Scheduler.sharedInstance

  private let disposeBag = DisposeBag()

  init() {
    // Configure internal state
    if let pausedTime = pomodoro.pausedTime {
      secondsRemaining.onNext(pausedTime)
    } else {
      secondsRemaining.onNext(settings.pomodoroLength)
    }
    pomodorosCount.onNext(pomodoro.pomodorosCount)
    isRunning.onNext(pomodoro.isRunning)

    secondsRemaining.subscribe(onNext: { value in
      // Update label
      let formattedString = String(format: "%02d:%02d", value / 60, value % 60)
      print(formattedString)
      self.timerLabel.onNext(formattedString)

      // Handle timeout
      guard value == 0 else { return }

      // Change state
      self.currentState.onNext(self.pomodoro.nextState)
      self.pomodoro.currentState = self.pomodoro.nextState

      // Stop the timer
      self.timer?.invalidate()
    }).disposed(by: disposeBag)

    currentState.subscribe(onNext: { value in
      // Update label color
      switch value {
      case .pomodoro:
        self.timerLabelColor.onNext(UIColor.primaryColor)
      case .shortBreak, .longBreak:
        self.timerLabelColor.onNext(UIColor.breakColor)
      }

      // Increment counter
      if value == .shortBreak || value == .longBreak {
        self.pomodoro.incrementPomodorosCount()
        self.pomodorosCount.onNext(self.pomodoro.pomodorosCount)
      }

      // Reset seconds
      self.resetSeconds(forState: value)

      // Pause timer
      self.isRunning.onNext(false)
    }).disposed(by: disposeBag)

    isRunning.subscribe(onNext: { value in
      // Fire or invalidate timer
      if value {
        self.fireTimer()
      } else {
        self.timer?.invalidate()
        self.timer = nil
      }
    }).disposed(by: disposeBag)
  }

  func start() {
    isRunning.onNext(true)
  }

  func pause() {
    isRunning.onNext(false)
  }

  func resume() {
    isRunning.onNext(true)
  }

  func stop() {
    // Reset current state
    isRunning.onNext(false)
    resetSeconds(forState: try! currentState.value())
  }

  @objc func tick() {
    let value = try! secondsRemaining.value()
    print("tick: \(value)")
    secondsRemaining.onNext(value - 1)
  }

  // MARK: - Helpers

  private func resetSeconds(forState state: State) {
    switch state {
    case .pomodoro:
      self.secondsRemaining.onNext(self.settings.pomodoroLength)
      self.secondsRemaining.onNext(10)
    case .shortBreak:
      self.secondsRemaining.onNext(self.settings.shortBreakLength)
    case .longBreak:
      self.secondsRemaining.onNext(self.settings.longBreakLength)
    }
  }

  private func fireTimer() {
    guard timer == nil else { return }

    timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                 selector: #selector(tick),
                                 userInfo: nil,
                                 repeats: true)
  }
}
