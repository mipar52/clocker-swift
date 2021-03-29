//
//  EntryController.swift
//  Clocker
//
//  Created by Milan Parađina on 04.01.2021..
//

import UIKit
import CoreData

class EntryController: UITableViewController {

    
    @IBOutlet weak var hoursWorked: UIBarButtonItem!
    
    let sheetBrain = SheetBrain()
    let db = DatabaseBrain()
    
    var buttonPressed = false
    
    var selectedMonth : Month? {
        didSet {
            loadEntries()
        }
    }
    
    var entryArray = [WorkEntry]()

    override func viewWillAppear(_ animated: Bool) {
        //sheetBrain.readData()
        print("History entered")
        tableView.tableFooterView = UIView()
        loadEntries()
        self.title = "\(selectedMonth!.month!),\(selectedMonth!.parentEntity!.year!)"
        hoursWorked.title = loadHours()

    }
    
    @IBAction func moneyButtonPressed(_ sender: UIBarButtonItem) {
        
        if buttonPressed == false {
            hoursWorked.title = loadMoney()
            buttonPressed = true
        } else {
            hoursWorked.title = loadHours()
            buttonPressed = false
        }
        
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,reuseIdentifier: "entryCell")
        let entry = entryArray[indexPath.row]
        cell.textLabel?.text = entry.date
        cell.detailTextLabel?.text = entry.desc
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetails", sender: self)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destVC = segue.destination as! HistoryDetailsController
                destVC.seletectedEntry = entryArray[indexPath.row]
            }
        }
    }
    
    //MARK: UI funcs
    
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
    
    //MARK: CoreData
    
    func loadEntries(with request: NSFetchRequest<WorkEntry> = WorkEntry.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let monthPredicate = NSPredicate(format: "parentEntity.month LIKE  %@", selectedMonth!.month! as String)
        let yearPredicate = NSPredicate(format: "year LIKE  %@", selectedMonth!.parentEntity!.year! as String)
       
//        let timestamp = NSSortDescriptor(key: "timestamp", ascending: true)
//        request.sortDescriptors = [timestamp]
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate,yearPredicate,addtionalPredicate])
        } else {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate,yearPredicate])
        }

        
        do {
            entryArray = try db.context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
        
    }
}
