//
//  SettingsViewController.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-07-06.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, PickerViewControllerDelegate {

    @IBOutlet weak var pomodoroLengthLabel: UILabel!
    @IBOutlet weak var shortBreakLengthLabel: UILabel!
    @IBOutlet weak var longBreakLengthLabel: UILabel!
    @IBOutlet weak var targetPomodorosLabel: UILabel!
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let settings = SettingsManager.sharedManager

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLabels()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    private func setupLabels() {
        pomodoroLengthLabel.text = "\(settings.pomodoroLength / 60) minutes"
        shortBreakLengthLabel.text = "\(settings.shortBreakLength / 60) minutes"
        longBreakLengthLabel.text = "\(settings.longBreakLength / 60) minutes"
        targetPomodorosLabel.text = "\(settings.targetPomodoros) pomodoros"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let picker = segue.destinationViewController as? PickerViewController {
            switch segue.identifier! {
            case "PomodoroLengthPicker":
                picker.selectedValue = settings.pomodoroLength
                picker.type = PickerType.PomodoroLength
            case "ShortBreakLengthPicker":
                picker.selectedValue = settings.shortBreakLength
                picker.type = PickerType.ShortBreakLength
            case "LongBreakLengthPicker":
                picker.selectedValue = settings.longBreakLength
                picker.type = PickerType.LongBreakLength
            case "TargetPomodorosPicker":
                picker.specifier = "pomodoros"
                picker.selectedValue = settings.targetPomodoros
                picker.type = PickerType.TargetPomodoros
            default:
                break
            }
            picker.delegate = self
        }
    }
    
    func pickerDidFinishPicking(picker: PickerViewController) {
        setupLabels()
    }

}
