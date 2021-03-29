//
//  NewEntryController.swift
//  Clocker
//
//  Created by Milan Parađina on 23/10/2020.
//

import UIKit
import CoreData


class NewEntryController: UIViewController {
    
    let db = DatabaseBrain()
    let sheetBrain = SheetBrain()
    let utils = Utilities()
    
    var workDate: String?
    var workingStart: String?
    var workingEnd: String?
    var hours: String?
    var workDesc: String?
    
    var entryArray = [WorkEntry]()
    var monthlyArray = [Month]()
    var yearArray = [Year]()
    
    var dataToSend : [String?] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        loadYears()
        loadMonths()
        loadEntries()
    }
    
    
    @IBAction func submitPressed(_ sender: UIButton) {
        print(workDate, workingStart, workingEnd, hours,workDesc)
        //let dataToSend : [String?] = [workDate, workingStart, workingEnd, hours, workDesc]
        
        if workDate == "" {
            utils.showAlert(title: "Date", message: "Date information is missing!", vc: self) {
                print("Date is empty!")
            }
        } else if workingStart == "" {
            utils.showAlert(title: "Work start", message: "Work start information is missing!", vc: self) {
                print("Work start is empty!")
            }
        } else if workingEnd == "" {
            utils.showAlert(title: "Work end", message: "Work end information is missing!", vc: self) {
                print("Work end is empty!")
            }
        } else if hours == "" {
            utils.showAlert(title: "Hours", message: "Working hours information is missing!", vc: self) {
                print("Working hours is empty!")
            }
        } else if workDesc == "" {
            utils.showAlert(title: "Description", message: "Description information is missing!", vc: self) {
                print("Description is empty!")
            }
        } else {
            self.utils.showSpinner(message: "Sending data..", vc: self)
            let defaults = UserDefaults.standard
            let name = defaults.object(forKey: "name") as? String ?? "name"

            let newEntry = WorkEntry(context: db.context)
            var parentMonth : Month?
            
            newEntry.year = utils.getYear()
            newEntry.timestamp = utils.giveDateAndTime()
            newEntry.date = workDate
            newEntry.start = workingStart
            newEntry.end = workingEnd
            newEntry.workHours = hours
            newEntry.desc = workDesc
            
            for month in monthlyArray {
                if month.month == utils.getDate() {
                   parentMonth = month
                } else {
                        for year in yearArray {
                            if year.year == utils.getYear() {
                               
                                let newMonth = Month(context: db.context)
                                newMonth.month = utils.getDate()
                                newMonth.parentEntity = year
                                monthlyArray.append(newMonth)
                                parentMonth = newMonth
                                print("Creating new month: \(newMonth.month), year: \(newMonth.parentEntity?.year)")
                        }
                    }
                }
            }
            print(utils.getDate())
            print(utils.getYear())
            newEntry.parentEntity = parentMonth
            entryArray.append(newEntry)
            db.savePassedData()
            
            dataToSend.append(utils.giveDateAndTime())
            dataToSend.append(name)
            dataToSend.append("")
            dataToSend.append(workDate)
            dataToSend.append(workingStart)
            dataToSend.append(workingEnd)
            dataToSend.append(hours)
            dataToSend.append(workDesc)
            for data in dataToSend {
                print("This the data: \(data)")
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "workInformation"), object: self)

            sheetBrain.sendDataToSheet(results: dataToSend as Array<[Any]>.ArrayLiteralElement, failedData: nil) { (bool) in
                if bool == true {
                    self.dismiss(animated: true) {
                        self.utils.showAlert(title: "Success", message: "Data sent!", vc: self) {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                } else {
                    self.dismiss(animated: true) {
                        self.utils.showAlert(title: "Error!", message: "Data could not be sent!", vc: self) {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                }
            }
        }
        }
    
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoTableView" {
            let destVC = segue.destination as! NewEntryTableView
            if workingStart != nil && workingEnd != nil{
                
                destVC.date = utils.getDate()
                destVC.startTime = workingStart
                destVC.endTime = workingEnd
                destVC.workingHours = utils.calculateTime(start: workingStart!, end: workingEnd!)
                destVC.desc = workDesc
            }
            NewEntryTableView.workDelegate = self
        }
    }
    func loadYears() {

        let request : NSFetchRequest<Year> = Year.fetchRequest()

        do{
            yearArray = try db.context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }

    }
    
    func loadMonths(with request: NSFetchRequest<Month> = Month.fetchRequest(), predicate: NSPredicate? = nil) {
        
   
        let monthPredicate = NSPredicate(format: "parentEntity.year LIKE  %@", utils.getYear())
       
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate,addtionalPredicate])
        } else {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate])
        }
        do {
            monthlyArray = try db.context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    func loadEntries(with request: NSFetchRequest<WorkEntry> = WorkEntry.fetchRequest(), predicate: NSPredicate? = nil) {
        

                
        let monthPredicate = NSPredicate(format: "parentEntity.month LIKE  %@", utils.getDate())
        let yearPredicate = NSPredicate(format: "year LIKE  %@", utils.getYear())
       
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate,yearPredicate,addtionalPredicate])
        } else {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate, yearPredicate])
        }
        do {
            entryArray = try db.context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    

        
}

extension NewEntryController:passWorkInfo {
    
    func passWorkInformation(date: String, workStart: String, workEnd: String, workHours: String, desc: String) {
        workDate = date
        workingStart = workStart
        workingEnd = workEnd
        hours = workHours
        workDesc = desc
    }
}
