//
//  HistoryController.swift
//  Clocker
//
//  Created by Milan Parađina on 04.12.2020..
//

import UIKit
import CoreData

class HistoryController: UITableViewController {
    
    let sheetBrain = SheetBrain()
    let db = DatabaseBrain()
    
    var yearArray = [Year]()

    override func viewWillAppear(_ animated: Bool) {
        tableView.tableFooterView = UIView()
        self.title = "History"
        loadPassedData()
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return yearArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "yearCell", for: indexPath)
        let entry = yearArray[indexPath.row]
        
        cell.textLabel?.text = entry.year
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToMonth", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMonth" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destVC = segue.destination as! MonthEntryController
                destVC.selectedYear = yearArray[indexPath.row]
                //destVC.seletectedEntry = entryArray[indexPath.row]
            }            
        }
    }

    func loadPassedData() {

        let request : NSFetchRequest<Year> = Year.fetchRequest()

        do{
            yearArray = try db.context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
}
