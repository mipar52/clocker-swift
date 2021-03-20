//
//  HistoryDetailsController.swift
//  MicroStudent
//
//  Created by Milan Parađina on 27.12.2020..
//

import UIKit
import CoreData


class HistoryDetailsController: UITableViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var workStartLabel: UILabel!
    @IBOutlet weak var workEndLabel: UILabel!
    @IBOutlet weak var workHoursLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    let db = DatabaseBrain()
        
    var seletectedEntry: WorkEntry? {
        didSet{
            db.loadPassedData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        adjustFields()
        tableView.tableFooterView = UIView()
        //print(seletectedEntry?.year)
        
        
    }
    func adjustFields() {
        dateLabel.text = seletectedEntry?.date
        workStartLabel.text = seletectedEntry?.start
        workEndLabel.text = seletectedEntry?.end
        descLabel.adjustsFontSizeToFitWidth = true
        descLabel.text = seletectedEntry?.desc
        workHoursLabel.text = seletectedEntry?.workHours
    }
}
