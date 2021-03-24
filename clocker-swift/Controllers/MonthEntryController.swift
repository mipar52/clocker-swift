//
//  MonthEntryController.swift
//  MicroStudent
//
//  Created by Milan Parađina on 04.01.2021..
//

import UIKit
import CoreData

class MonthEntryController: UITableViewController {

    @IBOutlet weak var workedHours: UIBarButtonItem!
    
    var db = DatabaseBrain()
    var monthArray = [Month]()
    var selectedYear : Year? {
        didSet {
        loadMonths()
        }
    }
    var entryArray = [WorkEntry]()
    
    var buttonPressed = false

    override func viewWillAppear(_ animated: Bool) {
        //sheetBrain.readData()
        print("History entered")
        tableView.tableFooterView = UIView()
        loadMonths()
        loadEntries() 
        self.title = selectedYear?.year
        self.workedHours.title = loadHours()
    }
    

    @IBAction func hoursButtonPressed(_ sender: UIBarButtonItem) {
        
        if buttonPressed == false {
            workedHours.title = loadMoney()
            buttonPressed = true
        } else {
            workedHours.title = loadHours()
            buttonPressed = false
        }
        
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return monthArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "monthCell", for: indexPath)
        let entry = monthArray[indexPath.row]
        
        cell.textLabel?.text = entry.month
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToEntry", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEntry" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destVC = segue.destination as! EntryController
                destVC.selectedMonth = monthArray[indexPath.row]
            }
        }
    }
    
    func loadHours() -> String {
        var hours = 0.0
        for entry in entryArray {
            hours = hours + Double(entry.workHours!)!
        }
        return "\(String(hours)) hours"
    }
    
    func loadMoney() -> String {
        let defaults = UserDefaults.standard
        let wage = defaults.object(forKey: "hourlyWage") as? String ?? "0.0"

        var money = 0.0
        for entry in entryArray {
            money = money + (Double(entry.workHours!)! * Double(wage)!)
            print(money)
        }
        
        return "\(String(money)) HRK"

    }
    

    func loadPassedData() {

        let request : NSFetchRequest<Month> = Month.fetchRequest()

        do{
            monthArray = try db.context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
    
    func loadMonths(with request: NSFetchRequest<Month> = Month.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let yearPredicate = NSPredicate(format: "parentEntity.year LIKE %@", selectedYear!.year! as String)
                
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate, addtionalPredicate])
        } else {
            request.predicate = yearPredicate
        }

        
        do {
            monthArray = try db.context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
                
        tableView.reloadData()
        
    }
    
    func loadEntries(with request: NSFetchRequest<WorkEntry> = WorkEntry.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let yearPredicate = NSPredicate(format: "year LIKE  %@", selectedYear!.year! as String)
       
        let timestamp = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [timestamp]
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate,addtionalPredicate])
        } else {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate])
        }

        
        do {
            entryArray = try db.context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
        
    }
}
