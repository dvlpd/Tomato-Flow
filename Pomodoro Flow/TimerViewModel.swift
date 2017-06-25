////
////  TimerViewModel.swift
////  Pomodoro Flow
////
////  Created by Dan K. on 2016-05-14.
////  Copyright © 2016 Dan K. All rights reserved.
////
//
//import UIKit
//import RxSwift
//
//class TimerViewModel {
//
////  var timerLabel: Observable<String>!
////  var timerLabelColor: Observable<UIColor>!
//
//  var timerLabel: BehaviorSubject<String>!
//  var timerLabelColor: BehaviorSubject<UIColor>!
//
////  var pomodorosCount = Variable(0)
//  let pomodorosCount = BehaviorSubject(value: 0)
//  var targetPomodorosCount = Variable(0)
//  var paused = Variable(false)
//
//  fileprivate var currentTime = BehaviorSubject(value: 0)
//  fileprivate var state = Variable(State.default)
//
//  fileprivate let pomodoro = Pomodoro.sharedInstance
//  fileprivate let settings = Settings.sharedInstance
//  fileprivate let scheduler = Scheduler.sharedInstance
//
//  fileprivate let disposeBag = DisposeBag()
//  fileprivate var timer: Timer?
//
//  init() {
//    if let pausedTime = pomodoro.pausedTime {
//      currentTime.onNext(pausedTime)
//    } else {
//      currentTime.onNext(settings.pomodoroLength)
//    }
//
//    paused.value = pomodoro.paused
//    pomodorosCount.onNext(pomodoro.pomodorosCount)
//    targetPomodorosCount.value = settings.targetPomodoros
//
//    setup()
//  }
//
//  func start() {
//    switch state.value {
//    case .default: scheduler.schedulePomodoro()
//    case .shortBreak: scheduler.scheduleShortBreak()
//    case .longBreak: scheduler.scheduleLongBreak()
//    }
//
//    fireTimer()
//  }
//
//  func pause() {
//    pomodoro.pausedTime = try! currentTime.value()
//    scheduler.suspend()
//    timer?.invalidate()
//  }
//
//  func unpause() {
//    switch state.value {
//    case .default: scheduler.schedulePomodoro(pomodoro.pausedTime)
//    case .shortBreak: scheduler.scheduleShortBreak(pomodoro.pausedTime)
//    case .longBreak: scheduler.scheduleLongBreak(pomodoro.pausedTime)
//    }
//
//    fireTimer()
//  }
//
//  func stop() {
//    scheduler.suspend()
//    currentTime.value = settings.pomodoroLength
//    timer?.invalidate()
//  }
//
//  @objc internal func tick() {
//    currentTime.value -= 1
//  }
//
//  fileprivate func setup() {
//    timerLabel = currentTime.map { String(format: "%02d:%02d", $0 / 60, $0 % 60) }
//
//    timerLabelColor = state
//      .asObservable()
//      .map { $0 == State.default ? UIColor.primaryColor : UIColor.breakColor }
//
//    state
//      .asObservable()
//      .subscribe(onNext: { state in
//        if state == .shortBreak || state == .longBreak {
//          try! self.pomodorosCount.onNext(self.pomodorosCount.value() + 1)
////          self.pomodorosCount.value += 1
//        }
//      })
//      .addDisposableTo(disposeBag)
//
//    currentTime
//      .asObservable()
//      .subscribe(onNext: { time in
//        if time <= 0 { self.nextState() }
//      })
//      .addDisposableTo(disposeBag)
//
//    pomodorosCount
//      .asObservable()
//      .subscribe(onNext: { self.pomodoro.pomodorosCount = $0 })
//      .addDisposableTo(disposeBag)
//  }
//
//  fileprivate func nextState() {
//    switch state.value {
//    case .default: state.value = (pomodorosCount.value % 4 == 0 ? .longBreak : .shortBreak)
//    case .shortBreak, .longBreak: state.value = .default
//    }
//  }
//
//  fileprivate func fireTimer() {
//      timer = Timer.scheduledTimer(timeInterval: 1, target: self,
//                                   selector: #selector(tick),
//                                   userInfo: nil,
//                                   repeats: true)
//  }
//
//}
