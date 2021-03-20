//
//  ViewController.swift
//  MicroStudent
//
//  Created by Milan Parađina on 23/10/2020.
//

import UIKit
import CoreData
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

class ViewController: UIViewController {

    @IBOutlet weak var timeShower: UILabel!
    @IBOutlet weak var dateShower: UILabel!
            
    @IBOutlet weak var clockInBtn: UIButton!
    @IBOutlet weak var clockOutBtn: UIButton!
    
    @IBOutlet weak var progressBarTitle: UILabel!
    @IBOutlet weak var moneyProgress: UIProgressView!
    @IBOutlet weak var percentigeLabel: UILabel!
        
    let defaults = UserDefaults.standard
        
    let db = DatabaseBrain()
    let utils = Utilities()
    let sheetBrain = SheetBrain()
    var entryArray = [WorkEntry]()
    var workDate: String?
    var workStart: String?
    var workEnd: String?
    var hours: String?
    var des: String?
    var start: String?
    var end: String?
    var descr: String?
        
    var timer = Timer()
    
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeSheetsDrive]
    private let combinedScopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeSheetsDrive]
    let service = GTLRSheetsService()
    let driveService = GTLRDriveService()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadEntries()
        showDate()
        showProgress()
        isClockedIn()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance()?.signIn()

    }
        
    @IBAction func didTapClockIn(_ sender: UIButton) {
        if (defaults.value(forKey: "isClockInSelected") as? Bool ?? false) == true {
            self.utils.showAlert(title: "Clocked in", message: "Already clocked in!", vc: self) {
            }
        } else {
            defaults.setValue(true, forKey: "isClockInSelected")
            let formatter = DateFormatter()
            let currentDateTime = Date()
            formatter.timeStyle = .short
            formatter.dateFormat = "hh:mm a"
            //formatter.dateStyle = .long
           let currentDate = formatter.string(from:currentDateTime)
            start = currentDate
            defaults.setValue(start, forKey: "timeStart")
            clockInBtn.setTitle("Clocked in at: \(currentDate)", for: .normal)
        }
    }
    
    @IBAction func didTapClockOut(_ sender: UIButton) {
        
        if (defaults.value(forKey:"isClockInSelected") as? Bool ?? false) == true {
 
            let formatter = DateFormatter()
            let currentDateTime = Date()
            formatter.timeStyle = .short
            formatter.dateFormat = "hh:mm a"
            //formatter.dateStyle = .long
           let currentDate = formatter.string(from:currentDateTime)
            end = currentDate

            let descAlert = UIAlertController(title: "What did you to today", message: "Write your work decription here:", preferredStyle: .alert)
            var descField = UITextField()
            let finish = UIAlertAction(title: "Done", style: .default) { (action) in
                self.defaults.setValue(false, forKey: "isClockInSelected")
                self.clockInBtn.setTitle("Clock in", for: .normal)
                
                self.descr = descField.text
                self.performSegue(withIdentifier: "newEntry", sender: self)
            }
            
            let nah = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)            
            descAlert.addAction(finish)
            descAlert.addAction(nah)
            descAlert.addTextField { (field) in
                descField = field
                field.placeholder = "Work Description"
            }
            self.present(descAlert, animated: true, completion: nil)
        } else {
            utils.showAlert(title: "Clock in", message: "You need to clock in first!", vc: self) {}
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "newEntry" {
                let dest = segue.destination as! NewEntryController
                dest.workDate = utils.getCurrentDate()
                dest.workingStart = defaults.value(forKey: "timeStart")! as? String
                dest.workingEnd = end
                dest.workDesc = descr
                dest.hours = utils.calculateTime(start: (defaults.value(forKey: "timeStart")! as? String)!, end: end!)
        }
    }
//MARK: UI elements
    func showProgress() {
        
        let progress = defaults.object(forKey: "hideProgress") as? Bool ?? false
        
        if progress == false {
            progressBarTitle.isHidden = false
            percentigeLabel.isHidden = false
            moneyProgress.isHidden = false
            
            var number = 0.0
            let goal = defaults.object(forKey: "monthlyGoal") as? String ?? "0.0"
            let wage = defaults.object(forKey: "hourlyWage") as? String ?? "0.0"
            
            print("Goal: \(goal),Wage: \(wage)")
            for entry in entryArray {
                if entry.workHours == "" {
                    entry.workHours = "0.0"
                }
                number = number + Double(entry.workHours!)!
            }
            
            if entryArray.count == 0 {
                moneyProgress.setProgress(0.0, animated: true)
                percentigeLabel.text = "0.0%"
            }
            
             let percentige = (number * Double(wage)!) / Double(goal)!
            
            if percentige == 0.0 {
                percentigeLabel.text = "0%"
                moneyProgress.setProgress(Float(percentige), animated: true)
            } else if percentige > 0.0 && percentige <= 0.3 {
                moneyProgress.progressTintColor = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)
                moneyProgress.setProgress(Float(percentige), animated: true)
                percentigeLabel.text = "\(String(format: "%.2f", percentige * 100)) %"
            } else if percentige > 0.3 && percentige < 0.7 {
                moneyProgress.progressTintColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
                moneyProgress.setProgress(Float(percentige), animated: true)
                percentigeLabel.text = "\(String(format: "%.2f", percentige * 100)) %"
            } else if percentige > 0.7 && percentige < 1.0 {
                moneyProgress.progressTintColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                moneyProgress.setProgress(Float(percentige), animated: true)
                percentigeLabel.text = "\(String(format: "%.2f", percentige * 100)) %"
            } else if percentige >= 1.0 {
                moneyProgress.progressTintColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
                moneyProgress.setProgress(Float(1), animated: true)
                percentigeLabel.text = "💸💸Completed! Goal achieved!💸💸"
            }

        } else {
            progressBarTitle.isHidden = true
            percentigeLabel.isHidden = true
            moneyProgress.isHidden = true

        }
    }

    func showDate() {
        let hideDate = defaults.object(forKey: "hideDate") as? Bool ?? false

        if hideDate == false {
            timeShower.text = utils.getCurrentDate()
            dateShower.isHidden = false
            timeShower.isHidden = false
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)
        } else {
            dateShower.isHidden = true
            timeShower.isHidden = true
        }
    }

    @objc func tick() {
        dateShower.text = DateFormatter.localizedString(from: Date(), dateStyle: .none,timeStyle: .medium)
                                                               
     }
    
    func isClockedIn() {
        if (defaults.value(forKey:"isClockInSelected") as? Bool ?? false) == true {
            //clockInBtn.setBackgroundImage(#imageLiteral(resourceName: "greenBtn"), for: .normal)
            clockInBtn.setTitle("Clocked in at: \(String(describing: defaults.value(forKey: "timeStart")!))", for: .normal)
        }
    }
    
    //MARK: CoreData loading entries
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

extension ViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            self.service.authorizer = nil
            self.driveService.authorizer = nil
            self.utils.addToast(backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), message: "Failed to sign in!", nc: self.navigationController!)
            print("Errors with signing in: \(error)")
            
        } else {
            self.driveService.authorizer = user.authentication.fetcherAuthorizer()
            self.service.authorizer = user.authentication.fetcherAuthorizer()

            let updateEntires = defaults.object(forKey: "updateEntires") as? Bool ?? false
            
            if updateEntires == true {
            self.utils.addToast(backgroundColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), message: "Updating entries...", nc: self.navigationController!)
            self.sheetBrain.readData { (bool) in
                if bool == true {
                    DispatchQueue.main.async {
                        self.loadEntries()
                        self.showProgress()
                        self.utils.addToast(backgroundColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), message: "Entires updated!", nc: self.navigationController!)
                    }
                    print("New entries found!")
                } else {
                    self.utils.addToast(backgroundColor: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), message: "Failed to get entires...", nc: self.navigationController!)
                        }
                    }
                } else {
                return
            }
        }
    }
}
