//
//  MonthyMainController.swift
//  MicroStudent
//
//  Created by Milan Parađina on 07.01.2021..
//

import UIKit
import CoreData

class MonthyMainController: UIViewController {
    
    @IBOutlet weak var amountNumberLabel: UILabel!
    @IBOutlet weak var entiesNumberLabel: UILabel!
    @IBOutlet weak var leftNumberWorkingDays: UILabel!
    
    @IBOutlet weak var historyView: UIView!
    
    @IBOutlet weak var moneyEarnedLabel: UILabel!
    
    
    let db = DatabaseBrain()
    var entryArray = [WorkEntry]()
    var monthArray = [Month]()
    
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        loadEntries()
        showCash()
        showHistory()
        entiesNumberLabel.text = String(entryArray.count)
        
        if calculateWorkingDays() == 0 {
            leftNumberWorkingDays.adjustsFontSizeToFitWidth = true
            leftNumberWorkingDays.text = "No more working days!"
        } else {
            leftNumberWorkingDays.text = String(calculateWorkingDays())

        }
    }
    
    func showCash() {
        
        let hideAmount = defaults.object(forKey: "hideAmount") as? Bool ?? false
        var cashAmount = 0.0
        let wage = defaults.object(forKey: "hourlyWage") as? String ?? "0.0"

        if hideAmount == false {
            amountNumberLabel.isHidden = false
            moneyEarnedLabel.isHidden = false
            
            for entry in entryArray {
                if entry.workHours == "" {
                    entry.workHours = "0.0"
                }
                cashAmount = cashAmount + Double(entry.workHours!)!
                let roundedAmount = cashAmount * Double(wage)!
                amountNumberLabel.text = "\(String(format: "%.2f", roundedAmount)) HRK"
            }
        } else {
            amountNumberLabel.isHidden = true
            moneyEarnedLabel.isHidden = true
        }

    }
    
    func showHistory() {
        let hideHistory = defaults.object(forKey: "hideTable") as? Bool ?? false

        if hideHistory == false {
            historyView.isHidden = false
        } else {
            historyView.isHidden = true
        }
    }
    
    func calculateWorkingDays() -> Int  {
        
        let calendar = Calendar.current
        let currentDateTime = Date()
        
        let components = calendar.dateComponents([.year, .month, .day], from: currentDateTime)
        
        let startOfMonth = calendar.date(from:components)!
        print("Start of month:\(startOfMonth)")
        
        var endComponents = Calendar.current.dateComponents([.year, .month], from: currentDateTime)
        endComponents.month = (endComponents.month ?? 0) + 1
        
        let endOfMonth = Calendar.current.date(from: endComponents)!
        print("End of month\(endOfMonth)")
        var dates = [startOfMonth]
        var currentDate = startOfMonth

            repeat {
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                dates.append(currentDate)
                print("Current date \(currentDate)")
            } while !calendar.isDate(currentDate, inSameDayAs: endOfMonth)

            let weekdays = dates.filter { !calendar.isDateInWeekend($0) }
            weekdays.forEach { date in
                print(DateFormatter.localizedString(from: date, dateStyle: .full, timeStyle: .none))
            }
            return weekdays.count - 1
    }
        
    func loadEntries(with request: NSFetchRequest<WorkEntry> = WorkEntry.fetchRequest() ,predicate: NSPredicate? = nil) {
        
        let formatter = DateFormatter()
        let currentDateTime = Date()
        //formatter.timeStyle = .short
        formatter.dateStyle = .long
        let currentDate = formatter.string(from:currentDateTime)
        let parsed = currentDate.components(separatedBy: " ")
        print("parsed date: \(parsed)")
        let month = parsed[1]
        let year = parsed[2]
        print("Year to be filtered: \(year)")
        
        let monthPredicate = NSPredicate(format: "parentEntity.month LIKE  %@", month)
        let yearPredicate = NSPredicate(format: "year == %@", year)
       
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate,monthPredicate,addtionalPredicate])
        } else {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate, monthPredicate])
        }

        do {
            entryArray = try db.context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }
}

