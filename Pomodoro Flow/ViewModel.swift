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
  // MARK: - Output

  var timerLabel = PublishSubject<String>()
  var timerLabelColor = PublishSubject<UIColor>()
  var pomodorosCount: BehaviorSubject<Int>

  var startButtonIsHidden = BehaviorSubject(value: false)
  var pauseButtonIsHidden = BehaviorSubject(value: false)
  var resumeButtonIsHidden = BehaviorSubject(value: false)
  var stopButtonIsHidden = BehaviorSubject(value: false)

  // MARK: - Internal

  private var secondsRemaining: BehaviorSubject<Int>
  private var currentState: BehaviorSubject<State>
  private var isRunning = BehaviorSubject(value: false)
  private var isPaused = BehaviorSubject(value: false)

  private var timer: Timer?

  private let pomodoro = Pomodoro.sharedInstance
  private let settings = Settings.sharedInstance
  private let scheduler = Scheduler.sharedInstance

  private let disposeBag = DisposeBag()

  init() {
    if let pausedTime = pomodoro.pausedTime {
      secondsRemaining = BehaviorSubject(value: pausedTime)
    } else {
      secondsRemaining = BehaviorSubject(value: settings.pomodoroLength)
    }
    currentState = BehaviorSubject(value: pomodoro.currentState)
    pomodorosCount = BehaviorSubject(value: pomodoro.pomodorosCount)

    isRunning = BehaviorSubject(value: false)
    isPaused = BehaviorSubject(value: true)

    // Start button
    isRunning
      .bind(to: startButtonIsHidden)
      .disposed(by: disposeBag)

    // Stop button
    isRunning
      .map { return !$0 }
      .bind(to: stopButtonIsHidden)
      .disposed(by: disposeBag)

    // Pause button
    Observable.combineLatest(isRunning, isPaused) { isRunning, isPaused in
      return isPaused || !isRunning
      }.bind(to: pauseButtonIsHidden).disposed(by: disposeBag)

    // Resume button
    Observable.combineLatest(isRunning, isPaused) { isRunning, isPaused in
      return !isPaused || !isRunning
      }.bind(to: resumeButtonIsHidden).disposed(by: disposeBag)

    // Timer label
    secondsRemaining
      .map { String(format: "%02d:%02d", $0 / 60, $0 % 60) }
      .bind(to: timerLabel)
      .disposed(by: disposeBag)

    secondsRemaining.subscribe(onNext: { value in
      // Handle timeout
      guard value == 0 else { return }

      // Change state
      self.currentState.onNext(self.pomodoro.nextState)
      self.pomodoro.currentState = self.pomodoro.nextState

      // Stop the timer
      self.timer?.invalidate()
    }).disposed(by: disposeBag)

    // Timer label color
    currentState
      .map { value in
        switch value {
        case .pomodoro:
          return UIColor.primaryColor
        case .shortBreak, .longBreak:
          return UIColor.breakColor
        }
      }
      .bind(to: timerLabelColor)
      .disposed(by: disposeBag)

    currentState.subscribe(onNext: { value in
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

    isPaused.subscribe(onNext: { value in
      if value {
        self.timer?.invalidate()
        self.timer = nil
      } else {
        self.fireTimer()
      }
    }).disposed(by: disposeBag)
  }

  func start() {
    isRunning.onNext(true)
    isPaused.onNext(false)
  }

  func pause() {
    isPaused.onNext(true)
  }

  func resume() {
    isPaused.onNext(false)
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
