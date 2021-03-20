//
//  SheetBrain.swift
//  MicroStudent
//
//  Created by Milan Parađina on 23.12.2020..
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit
import GTMSessionFetcher

class SheetBrain: NSObject, GIDSignInDelegate {
 
    private let combinedScopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeSheetsDrive]
    let service = GTLRSheetsService()
    let driveService = GTLRDriveService()
    
    let defaults = UserDefaults.standard
    
    var nameIndex: Int?
    var dateIndex: Int?
    var timeStartIndex: Int?
    var timeEndIndex: Int?
    var workHoursIndex: Int?
    var descIndex: Int?
    var timeStampIndex: Int?
    //https://docs.google.com/spreadsheets/d/12b3gUhvJfEBakrgR1r5lALfrdr6fKS6oCA1hmxrdlf4/edit#gid=0 -> test sheet

    func sendDataToSheet(results: Array<[Any]>.ArrayLiteralElement, failedData: String?, completionHandler: @escaping (Bool) -> Void) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = combinedScopes
        GIDSignIn.sharedInstance()?.signInSilently()
        
        print("Trenutni rezultati: \(results)")

        let spreadsheetId = defaults.object(forKey: "spreadId") as? String ?? ""
        let range = "A1:Q"
        let rangeToAppend = GTLRSheets_ValueRange.init();
        
        rangeToAppend.values = [results]
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: range)

            query.valueInputOption = "USER_ENTERED"
        
        service.executeQuery(query) { (ticket, result, error) in
                if let error = error {
                    print("Error in appending data: \(error)")
                    
                    completionHandler(false)
               
                } else {
                    print("Data sent: \(results)")
                    completionHandler(true)
                }
            }
        
        }
    
    func readData(completionHandler: @escaping (Bool) -> Void) {
        print("Getting sheet data...")
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = combinedScopes
        GIDSignIn.sharedInstance()?.signInSilently()
        
        let spreadsheetId = defaults.object(forKey: "spreadId") as? String ?? ""
        let range = "A1:Q"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        
        service.executeQuery(query) { [self] (ticket, result, error) in
            
            if let error = error {
                print("error in getting data")
                print(error.localizedDescription)
                completionHandler(false)
                return
            }
            
            guard let result = result as? GTLRSheets_ValueRange else {
                return
            }
            
            let rows = result.values!

            
            let db = DatabaseBrain()
            
            let stringRows = rows as! [[String]]
            let group = DispatchGroup()
            let defaults = UserDefaults.standard
            let name = defaults.object(forKey: "name") as? String ?? "name"
            //Enter the parameters you want to extract from the Spreadsheet
        
            for row in stringRows {
                group.enter()
                //Book name row
                if row.contains("Timestamp") {
                    //infoRow = row
                     timeStampIndex = row.firstIndex(of: "Timestamp")
                    print("Name index: \(String(describing: timeStampIndex))")
                }
                if row.contains("Name and Surname") {
                    //infoRow = row
                     nameIndex = row.firstIndex(of: "Name and Surname")
                    print("Name index: \(String(describing: nameIndex))")
                }
                if row.contains("Date") {
                    dateIndex = row.firstIndex(of: "Date")
                    print("Datum index: \(String(describing: dateIndex))")
                }
                if row.contains("Time start") {
                    timeStartIndex = row.firstIndex(of: "Time start")
                    print("Start index: \(String(describing: timeStartIndex))")
                }
                
                if row.contains("Time end") {
                    timeEndIndex = row.firstIndex(of: "Time end")
                    print("End time index: \(String(describing: timeEndIndex))")
                }
                
                if row.contains("Working hours") {
                    workHoursIndex = row.firstIndex(of: "Working hours")
                    print("Work hours: \(String(describing: workHoursIndex))")
                }
                
                if row.contains("Description") {
                    descIndex = row.firstIndex(of: "Description")
                    print("Desc index: \(String(describing: descIndex))")
                }
                
                if row.contains(name) {
                    
                let parsedDate = row[dateIndex!].components(separatedBy: "/")
                    
                let year = parsedDate[2]
                let month = parsedDate[0]
                    db.fetchExistingData(year: year, month: month, entryData: row, timeStamp: timeStampIndex!, date: dateIndex!, timeStart: timeStartIndex!, timeEnd: timeEndIndex!, workHours: workHoursIndex!, desc: descIndex!)
              
                }
            
            if rows.isEmpty {
                return
            }
                
            group.leave()

            
        }
            group.wait()
            
            DispatchQueue.main.async {
            completionHandler(true)
            }
        }
    }
    
        func findSpreadNameAndSheets(id: String, completionHandler: @escaping (String?,String?,Bool) -> Void ) {
            print("func findSpreadNameAndSheets executing...")
            
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().scopes = combinedScopes
            GIDSignIn.sharedInstance()?.signInSilently()
            
            
            let spreadsheetId = id
            let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)
            
            service.executeQuery(query) { (ticket, result, error) in
                if let error = error {
                    print("Error in the func loadSheets: \(error)")
                    completionHandler(nil,nil,false)
                } else {
                    
                    let result = result as? GTLRSheets_Spreadsheet
                    
                    let spreadsheetName = result?.properties?.title
                    let spreadsheetId = result?.spreadsheetId
                    
                    DispatchQueue.main.async {
                        completionHandler(spreadsheetName,spreadsheetId,true)

                    }
                }
            }
        }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
            if let error = error {
                print("Error: \(error)")
                self.service.authorizer = nil
                self.driveService.authorizer = nil
            } else {
                self.service.authorizer = user.authentication.fetcherAuthorizer()
                self.driveService.authorizer = user.authentication.fetcherAuthorizer()
                //let userID = "\(user.userID)"
            }
        }
}
