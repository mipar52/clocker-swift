//
//  NewEntryTableView.swift
//  Clocker
//
//  Created by Milan Parađina on 23/10/2020.
//

import UIKit

protocol passWorkInfo {
    func passWorkInformation(date: String, workStart: String, workEnd: String, workHours: String, desc: String)
}

class NewEntryTableView: UITableViewController {

    
    @IBOutlet weak var descriptionLabel: UITextField!
    
    @IBOutlet weak var dateTextLabel: UITextField!
    
    @IBOutlet weak var workTimeStartLabel: UITextField!
    
    @IBOutlet weak var workTimeEndLabel: UITextField!
    
    @IBOutlet weak var workingHoursLabel: UITextField!
    
    var datePicker = UIDatePicker()
    var timePicker = UIDatePicker()
    
    let utils = Utilities()
    
    var date: String?
    var startTime :String?
    var endTime : String?
    var workingHours: String?
    var desc: String?
    
    static var workDelegate : passWorkInfo?
    
    override func viewWillAppear(_ animated: Bool) {
        if startTime != nil && endTime != nil {
            dateTextLabel.text = date
            workTimeStartLabel.text = startTime
            workTimeEndLabel.text = endTime
            workingHoursLabel.text = workingHours
            descriptionLabel.text = desc
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        showDatePickers()
        showTimePickerStart()
        showTimePickerEnd()
  
          let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
          
          view.addGestureRecognizer(tap)
  
    }
    
    func showDatePickers() {
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        toolbar.sizeToFit()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        dateTextLabel.inputView = datePicker

        dateTextLabel.inputAccessoryView = toolbar

        
    }
    
    func showTimePickerStart() {
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(startPressed))
        toolbar.setItems([doneButton], animated: true)
        toolbar.sizeToFit()
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = 15
        workTimeStartLabel.inputView = timePicker
        workTimeStartLabel.inputAccessoryView = toolbar
        
    }
    
    func showTimePickerEnd() {
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(endPressed))
        toolbar.setItems([doneButton], animated: true)
        toolbar.sizeToFit()
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = 15
        workTimeEndLabel.inputView = timePicker
        workTimeEndLabel.inputAccessoryView = toolbar


    }
    
    
    @objc func donePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "MM/dd/YYYY"
        dateTextLabel.text = dateFormatter.string(from: datePicker.date)
        date = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func startPressed() {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        timeFormatter.dateFormat = "hh:mm a"
        workTimeStartLabel.text = timeFormatter.string(from: timePicker.date)
        startTime = timeFormatter.string(from: timePicker.date)
        
        if workTimeStartLabel.text !=  "" && workTimeEndLabel.text != "" {
            
        workingHours = utils.calculateTime(start: startTime!, end: endTime!)
        workingHoursLabel.text = workingHours
            
        }

        self.view.endEditing(true)
    }
    @objc func endPressed() {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        timeFormatter.dateFormat = "hh:mm a"
        workTimeEndLabel.text = timeFormatter.string(from: timePicker.date)
        endTime = timeFormatter.string(from: timePicker.date)
        if workTimeStartLabel.text != "" && workTimeEndLabel.text != "" {
        workingHours = utils.calculateTime(start: startTime!, end: endTime!)
            workingHoursLabel.text = workingHours
        }


        print("Starterony \(startTime)")
        print("end \(endTime)")
        self.view.endEditing(true)
    }
    
    @objc func dismissKeyboard() {
        
        desc = descriptionLabel.text
        date = dateTextLabel.text
        startTime = workTimeStartLabel.text
        endTime = workTimeEndLabel.text
        workingHours = workingHoursLabel.text
    
        NewEntryTableView.self.workDelegate?.passWorkInformation(date: date!, workStart: startTime!, workEnd: endTime!, workHours: workingHours!, desc: desc!)
        
        view.endEditing(true)
    }
}
