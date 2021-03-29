//
//  Utilities.swift
//  Clocker
//
//  Created by Milan Parađina on 23.12.2020..
//

import Foundation
import UIKit
import Toast_Swift


class Utilities {
    
    func showAlert(title : String, message: String, vc: UIViewController, completionHandler: @escaping () -> Void) {
         let alert = UIAlertController(title: title, message: message,preferredStyle:UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            completionHandler()
        })
        
         alert.addAction(ok)
        vc.present(alert, animated: true, completion: nil)
     }
    
   func showSpinner(message: String, vc: UIViewController) {
       let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
       let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 40, height: 50))
       alert.preferredContentSize = CGSize(width: 200.0, height: 100.0)

       loadingIndicator.style = UIActivityIndicatorView.Style.medium
       
       loadingIndicator.startAnimating();

       alert.view.addSubview(loadingIndicator)
       vc.present(alert, animated: true, completion: nil)

   }
    
    func addToast(backgroundColor: UIColor, message: String, nc: UINavigationController) {

        var style = ToastStyle()
        style.messageColor = .black
         style.backgroundColor = backgroundColor
        style.messageAlignment = .center
             
         nc.view.makeToast(message, duration: 2.0, position: .bottom, style: style)
    }
 
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()

        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.dateFormat = "MM/dd/YYYY"

        //formatter.dateFormat = "MM/dd/yyyy"
        let currentDateTime = Date()
        let currentDate = formatter.string(from: currentDateTime)
        
        return currentDate
    }
    
    func getDate() -> String {
        let formatter = DateFormatter()
        let currentDateTime = Date()
        //formatter.timeStyle = .short
        formatter.dateStyle = .long
        let currentDate = formatter.string(from:currentDateTime)
        let parsed = currentDate.components(separatedBy: " ")
        let month = parsed[1]
        
        return month
    }
    
    func getYear() -> String {
        let formatter = DateFormatter()
        let currentDateTime = Date()
        //formatter.timeStyle = .short
        formatter.dateStyle = .long
        let currentDate = formatter.string(from:currentDateTime)
        let parsed = currentDate.components(separatedBy: " ")
        //let month = parsed[1]
        let year = parsed[2]
        
        return year
    }
    
    func giveDateAndTime() -> String {
        
        let formatter = DateFormatter()
        let currentDateTime = Date()
        
        formatter.timeStyle = .full
        formatter.dateStyle = .long
        formatter.dateFormat = "MM/dd/YYYY HH:mm:ss"

        let currentDate = formatter.string(from: currentDateTime)
        
        return currentDate
    }
    
    func calculateTime(start: String, end: String) -> String {
        
        let time1 = start
        let time2 = end
         let formatter = DateFormatter()
         //formatter.dateFormat = "HH:mm a"
        formatter.dateFormat = "h:mma"


         let date1 = formatter.date(from: time1)!
         let date2 = formatter.date(from: time2)!

         let elapsedTime = date2.timeIntervalSince(date1)
            print("elapsedTime:\(elapsedTime)")

         let hours = floor(elapsedTime / 60 / 60)

         var minutes = floor((elapsedTime - (hours * 60 * 60)) / 60)
        
        if minutes > 0 && minutes <= 15 {
            minutes = 25
        } else if minutes > 15 && minutes <= 30 {
            minutes = 50
        } else if minutes > 30 && minutes <= 45 {
            minutes = 75
        }
        let result = "\(Int(hours)).\(Int(minutes))"
        print("\(Int(hours)) hr and \(Int(minutes)) min")
         
        return result
    }
    
    func isUrlValid(spreadsheetURL: String?, completionHandler: @escaping (String?, Bool) -> Void) {
        print("Checking URL:\(String(describing: spreadsheetURL))")
        let parsedString = spreadsheetURL?.components(separatedBy: "/")
                        
            if parsedString?.contains("spreadsheets") == true {
            print("Parsed String in SB is: \(String(describing: parsedString))")
            
            completionHandler((parsedString?[5])!, true)
                
            } else {
                print("Not a valid URL entered! Enter a valid URL!")
                completionHandler(nil, false)
            }
        }
    
}
