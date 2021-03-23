//
//  SettingsContoller.swift
//  MicroStudent
//
//  Created by Milan Parađina on 04.12.2020..
//

import UIKit
import CoreData
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

protocol SettingsChangedDelegate {
    
func hideTable(hidden: Bool)
func hideAmount(hidden: Bool)
func hideDate(hidden: Bool)
    
}

class SettingsContoller: UITableViewController, UINavigationControllerDelegate {

    @IBOutlet weak var hourCell: UITableViewCell!
    @IBOutlet weak var monthCell: UITableViewCell!
    @IBOutlet weak var signInCell: UITableViewCell!
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var teamCell: UITableViewCell!
    @IBOutlet weak var hideTableViewCell: UITableViewCell!
    @IBOutlet weak var hideLabelCell: UITableViewCell!
    @IBOutlet weak var hideDateCell: UITableViewCell!
    @IBOutlet weak var hideProgressCell: UITableViewCell!
    
    @IBOutlet weak var hideTableSwitch: UISwitch!
    @IBOutlet weak var hideAmountSwitch: UISwitch!
    @IBOutlet weak var hideDateSwitch: UISwitch!
    @IBOutlet weak var hideProgressSwitch: UISwitch!
    @IBOutlet weak var entiresSwitch: UISwitch!
    
    @IBOutlet weak var hourlyWageLabel: UITextField!
    @IBOutlet weak var monthlyGoalLabel: UITextField!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var positionLabel: UITextField!
    
    @IBOutlet weak var spreadsheetLabel: UILabel!
    
    
    let defaults = UserDefaults.standard
    
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeSheetsDrive]
    let service = GTLRSheetsService()
    let driveService = GTLRDriveService()
    
    var utils = Utilities()
    var sheetBrain = SheetBrain()
    var db = DatabaseBrain()
    var entryArray = [WorkEntry]()
    var yearArray = [Year]()
    var monthArray = [Month]()
    
    var hourlyWage : String?
    var monthlyGoal : String?
    var name: String?
    var position: String?
    
    var hideTable = false
    var hideAmount = false
    var hideDate = false
    var hideProgress = false

    var updateEntires = false
    
    public var settingsDelegate : SettingsChangedDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        
        GIDSignIn.sharedInstance()?.signInSilently()
        
        monthlyGoalLabel.text = defaults.object(forKey: "monthlyGoal") as? String ?? "0"
        hourlyWageLabel.text = defaults.object(forKey: "hourlyWage") as? String ?? "0"
        nameLabel.text = defaults.object(forKey: "name") as? String ?? ""
        positionLabel.text = defaults.object(forKey: "position") as? String ?? ""
        spreadsheetLabel.text = defaults.object(forKey: "spreadName") as? String ?? "Tap to enter Spreadsheet"
        
        hideTableSwitch.isOn = defaults.object(forKey: "hideTable") as? Bool ?? false
        hideAmountSwitch.isOn = defaults.object(forKey: "hideAmount") as? Bool ?? false
        entiresSwitch.isOn = defaults.object(forKey: "updateEntires") as? Bool ?? false
        hideDateSwitch.isOn = defaults.object(forKey: "hideDate") as? Bool ?? false
        hideProgressSwitch.isOn = defaults.object(forKey: "hideProgress") as? Bool ?? false
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPassedData()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        print(entryArray.count)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))

       view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        hideTableViewCell.textLabel?.text = "Hide Monthly Entries table"
        hideLabelCell.textLabel?.text = "Hide Amount label"
        hideDateCell.textLabel?.text = "Hide Date label"
        hideProgressCell.textLabel?.text = "Hide Progress bar"
        
        tableView.tableFooterView = UIView()
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        defaults.set(hideTableSwitch.isOn, forKey: "hideTable")
        defaults.set(hideAmountSwitch.isOn, forKey: "hideAmount")
        defaults.set(hideDateSwitch.isOn, forKey: "hideDate")
        defaults.set(hideProgressSwitch.isOn, forKey: "hideProgress")

        defaults.set(entiresSwitch.isOn, forKey: "updateEntires")
    }
    
    @IBAction func tableSwitchPressed(_ sender: UISwitch) {
        //prviSwitch
        if sender.isOn {
            hideTable = true
        } else {
           hideTable = false
        }
        defaults.set(hideTable, forKey: "hideTable")
        settingsDelegate?.hideTable(hidden: hideTable)

    }
    @IBAction func amountSwitchPressed(_ sender: UISwitch) {
        //drugiSwitch
        if sender.isOn {
            hideAmount = true
        } else {
            hideAmount = false
        }
        defaults.setValue(hideAmount, forKey: "hideAmount")
        settingsDelegate?.hideAmount(hidden: hideAmount)
    }
    
    @IBAction func dateSwitchPressed(_ sender: UISwitch) {
        //treciSwitch
        if sender.isOn {
            hideDate = true
        } else {
            hideDate = false
        }
        defaults.setValue(hideDate, forKey: "hideDate")
    }
    
    @IBAction func progressSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            hideProgress = true
        } else {
            hideProgress = false
        }
        defaults.setValue(hideProgress, forKey: "hideProgress")
    }
    
    
    @IBAction func entiresSwitchPressed(_ sender: UISwitch) {
        if sender.isOn {
            updateEntires = true
        } else {
            updateEntires = false
        }
        print(updateEntires)
        defaults.setValue(updateEntires, forKey: "updateEntires")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 0 {
            if nameLabel.text != "" && spreadsheetLabel.text != "Tap to enter Spreadsheet"{
                let descAlert = UIAlertController(title: "Import entries", message: "This operation will import any new entries that were entered", preferredStyle: .alert)
                let done = UIAlertAction(title: "Yes", style: .default) { (action) in
                    self.utils.showSpinner(message: "Getting entires..", vc: self)
                    self.sheetBrain.readData { (bool, counter) in
                        if bool == true && counter > 0{
                            self.dismiss(animated: true) {
                                self.utils.showAlert(title: "Success", message: "New entries added!", vc: self) {
                                    print("Done")
                                }
                            }
                        } else if bool == true && counter == 0 {
                            self.dismiss(animated: true) {
                                self.utils.showAlert(title: "Success", message: "All entries already added!\n \nIf you did not receive any entries try the following:\n \n1. See if you name is correctly written in the name field\n \n2. Check if your Spreadsheet is containing the correct entry format", vc: self) {
                                    print("Done")
                                }
                            }
                         
                        } else if bool == false {
                            self.dismiss(animated: true) {
                                self.utils.showAlert(title: "Error", message: "Errors in adding entries..", vc: self) {
                                    print("Fail")
                               }
                            }
                        }
                    }
                }
                
                let nah = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                descAlert.addAction(done)
                descAlert.addAction(nah)
                self.present(descAlert, animated: true, completion: nil)
            } else if nameLabel.text == ""{
                self.utils.showAlert(title: "Enter name", message: "Please enter your first and last name in the name field in order to find the entries!", vc: self) {
                    print("Need to enter name!")
                }
            } else if spreadsheetLabel.text == "Tap to enter Spreadsheet" {
                self.utils.showAlert(title: "Enter Spreadsheet", message: "Please enter a valid Spreadsheet to import enteries from!", vc: self) {
                    print("Missing Spread URL!")
                }
            }
            
        } else if indexPath.section == 3 && indexPath.row == 1 {
            let descAlert = UIAlertController(title: "Delete entries", message: "Are you sure you want to delete all entries?", preferredStyle: .alert)
            let done = UIAlertAction(title: "Yes", style: .default) { (action) in
                self.utils.showSpinner(message: "Deleting entries..", vc: self)
                print(self.entryArray.count)
                for entity in self.yearArray {
                    self.db.context.delete(entity)
                   self.db.savePassedData()
                }

                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.utils.showAlert(title: "Success", message: "All entries deleted!", vc: self) {
                            print("All items deleted")
                        }
                    }
                }
            }
            let nah = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            descAlert.addAction(done)
            descAlert.addAction(nah)
            self.present(descAlert, animated: true, completion: nil)
        } else if indexPath.section == 1 && indexPath.row == 0 {

            if self.service.authorizer == nil{
                signInCell.textLabel?.text = "Sign out"
            GIDSignIn.sharedInstance()?.signIn()
                print("signing in....")
            }

            if (self.service.authorizer != nil) {
                let signInCon = UIAlertController(title: "Sign out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
                let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
                    GIDSignIn.sharedInstance()?.signOut()
                    self.service.authorizer = nil
                    self.signInCell.imageView?.image = nil
                    self.signInCell.textLabel?.text = "Sign in with your Google account"
                    print("signing out....")
                }
                let nah = UIAlertAction(title: "No", style: .cancel) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                signInCon.addAction(yes)
                signInCon.addAction(nah)
                self.present(signInCon, animated: true, completion: nil)
            }
        } else if indexPath.section == 4 && indexPath.row == 0 {
            let sheetController = UIAlertController(title: "Spreadsheet", message: "Add new Spreadsheet to import/add work entires from?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
                let urlController = UIAlertController(title: "Spreadsheet URL", message: "Add Spreadsheet URL below", preferredStyle: .alert)
                var urlTextField = UITextField()
                urlController.addTextField { (field) in
                urlTextField = field
                urlTextField.placeholder = "Tap to enter Spreadsheet URL"
                }
                let done = UIAlertAction(title: "Done", style: .default) { (action) in
                    self.utils.isUrlValid(spreadsheetURL: urlTextField.text) { (spreadId, isUrlValid) in
                        if isUrlValid == true {
                            self.utils.showSpinner(message: "Getting Spreadsheet...", vc: self)
                            self.sheetBrain.findSpreadNameAndSheets(id: spreadId!) { (spreadName,spreadId,completionBool) in
                                self.dismiss(animated: true) {
                                    if completionBool == true {
                                        self.spreadsheetLabel.text = spreadName
                                        self.defaults.set(spreadId, forKey: "spreadId")
                                        self.defaults.set(spreadName, forKey: "spreadName")
                                        print("Saved ID: \(spreadId)")
                                        print("Saved name: \(spreadName)")
                                        self.utils.showAlert(title: "Success", message: "Added \(spreadName!) as your work entrie Spreadsheet!", vc: self) {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    } else {
                                        self.utils.showAlert(title: "Error", message: "Error with getting Spreadsheet!", vc: self) {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
                        } else {
                            self.utils.showAlert(title: "Spreadsheet error", message: "Invalid URL!\nPlease enter a valid URL!", vc: self) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                urlController.addAction(done)
                urlController.addAction(cancel)
                self.present(urlController, animated: true, completion: nil)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            sheetController.addAction(yes)
            sheetController.addAction(cancel)
            self.present(sheetController, animated: true, completion: nil)
        }
        }
    func loadPassedData() {

        let entryRequest : NSFetchRequest<WorkEntry> = WorkEntry.fetchRequest()

        do{
            entryArray = try db.context.fetch(entryRequest)
        } catch {
            print("Error loading categories \(error)")
        }
        let yearRequest : NSFetchRequest<Year> = Year.fetchRequest()

        do{
            yearArray = try db.context.fetch(yearRequest)
        } catch {
            print("Error loading categories \(error)")
        }
        
        let monthRequest : NSFetchRequest<Month> = Month.fetchRequest()

        do{
            monthArray = try db.context.fetch(monthRequest)
        } catch {
            print("Error loading categories \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    @objc func dismissKeyboard() {
        print("tap")
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        if monthlyGoalLabel.text != "" {
            monthlyGoal = monthlyGoalLabel.text
            defaults.setValue(monthlyGoal, forKey: "monthlyGoal")
        } else {
            monthlyGoal = "0"
            monthlyGoalLabel.text = "0"
            defaults.setValue(monthlyGoal, forKey: "monthlyGoal")
        }
        
        if hourlyWageLabel.text != "" {
            hourlyWage = hourlyWageLabel.text
            defaults.setValue(hourlyWage, forKey: "hourlyWage")

        } else {
            hourlyWage = "0"
            hourlyWageLabel.text = "0"
            defaults.setValue(hourlyWage, forKey: "hourlyWage")
        }
        
        if nameLabel.text != ""{
            name = nameLabel.text
            defaults.setValue(name, forKey: "name")

        } else {
            name = "name"
            defaults.setValue(name, forKey: "name")
        }
        position = positionLabel.text
        defaults.setValue(positionLabel.text, forKey: "position")
        print(monthlyGoal, hourlyWage, name, position)

        view.endEditing(true)
    }
        }

extension SettingsContoller: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {

            if let error = error {
                self.service.authorizer = nil
                self.driveService.authorizer = nil
                self.utils.addToast(backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), message: "Failed to sign in!", nc: self.navigationController!)
                signInCell.textLabel?.text = "Failed to Sign in! Tap to try again"

                print("Errors with signing in: \(error)")
            } else {
                self.signInCell.textLabel?.text = "Singing in..."
                tableView.reloadData()
                self.driveService.authorizer = user.authentication.fetcherAuthorizer()
                self.service.authorizer = user.authentication.fetcherAuthorizer()
                let id = user.profile.email
                let dim = (self.signInCell.imageView?.frame.size.width)! / 2
                let dimension = round(dim * UIScreen.main.scale)
                let pic = user.profile.imageURL(withDimension: UInt(dimension))
                self.signInCell.textLabel?.adjustsFontSizeToFitWidth = true
                //self.signInCell.textLabel?.text = "\(id!)"
                
                downloadImage(from: pic!, completionHandler: { (data) in
                    DispatchQueue.main.async {
                        let userPic = UIImage(data: data)
                        
                        //self.signInCell.imageView?.layer.cornerRadius = userPic.frame.size.width / 2
            
                        self.signInCell.imageView?.image = self.imageWithImage(image: userPic!, scaledToSize: CGSize(width: 35, height: 35))
                        self.signInCell.imageView?.layer.cornerRadius = (self.signInCell.imageView?.frame.size.width)! / 2
                        self.signInCell.imageView!.layer.masksToBounds = true
                        self.signInCell.textLabel?.text = "\(id!)"

                        self.tableView.reloadData()
                    }
                })
                print("Image URL: \(pic)")

                print("Success in Settings!")
                }
        }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, completionHandler: @escaping (Data) -> Void){
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                completionHandler(data)
            }
        }
    }
    
    func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0 ,y: 0 ,width: newSize.width ,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.alwaysOriginal)
    }
}
