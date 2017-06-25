//
//  Scheduler.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-07-12.
//  Copyright © 2015 Dan K. All rights reserved.
//

import UIKit

protocol SchedulerDelegate: class {
  func schedulerDidPause()
  func schedulerDidUnpause()
  func schedulerDidStart()
  func schedulerDidStop()
}

class Scheduler {

  static let sharedInstance = Scheduler()

  private init() { }

  private let userDefaults = UserDefaults.standard
  private let settings = Settings.sharedInstance
  private let pomodoro = Pomodoro.sharedInstance

  // MARK: - Helpers

  private var firstScheduledNotification: UILocalNotification? {
    return UIApplication.shared.scheduledLocalNotifications?.first
  }

  func suspend() {
    UIApplication.shared.cancelAllLocalNotifications()
    pomodoro.fireDate = nil

    print("Notification canceled")
  }

  func schedulePomodoro(_ interval: Int? = nil) {
    let interval = interval ?? settings.pomodoroLength

    scheduleNotification(TimeInterval(interval),
                         title: "Pomodoro finished",
                         body: "Time to take a break!")

    print("Pomodoro scheduled")
  }

  func scheduleShortBreak(_ interval: Int? = nil) {
    let interval = interval ?? settings.shortBreakLength

    scheduleNotification(TimeInterval(interval),
                         title: "Break finished",
                         body: "Time to get back to work!")

    print("Short break scheduled")
  }

  func scheduleLongBreak(_ interval: Int? = nil) {
    let interval = interval ?? settings.longBreakLength

    scheduleNotification(TimeInterval(interval),
                         title: "Long break is over",
                         body: "Time to get back to work!")

    print("Long break scheduled")
  }

  // MARK: - Helpers

  private func scheduleNotification(_ interval: TimeInterval, title: String, body: String) {
    let notification = UILocalNotification()

    notification.fireDate = Date(timeIntervalSinceNow: interval)
    notification.alertTitle = title
    notification.alertBody = body
    notification.applicationIconBadgeNumber = 1
    notification.soundName = UILocalNotificationDefaultSoundName

    UIApplication.shared.scheduleLocalNotification(notification)

    pomodoro.fireDate = notification.fireDate

    print("Pomodoro notification scheduled for \(notification.fireDate!)")
  }

}
