//
//  MainScreenTableController.swift
//  MicroStudent
//
//  Created by Milan Parađina on 27/10/2020.
//

import UIKit
import CoreData

class MainScreenTableController: UITableViewController {

        let db = DatabaseBrain()
    let utils = Utilities()
    var entryArray = [WorkEntry]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadEntries()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entryArray.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,reuseIdentifier: "entryCell")

        let entry = entryArray[indexPath.row]
        cell.textLabel?.text = entry.date
        cell.detailTextLabel?.text = entry.desc
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    
    func loadEntries(with request: NSFetchRequest<WorkEntry> = WorkEntry.fetchRequest(), predicate: NSPredicate? = nil) {
                
        let monthPredicate = NSPredicate(format: "parentEntity.month LIKE  %@", utils.getDate())
        let yearPredicate = NSPredicate(format: "year == %@", utils.getYear())
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate,monthPredicate,addtionalPredicate])
        } else {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate,monthPredicate])
        }

        
        do {
            entryArray = try db.context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
