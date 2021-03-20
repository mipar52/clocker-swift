//
//  Database.swift
//  MicroStudent
//
//  Created by Milan Parađina on 27/10/2020.
//

import Foundation
import CoreData
import UIKit

class DatabaseBrain {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var entryArray = [WorkEntry]()
    var yearArray = [Year]()
    var monthArray = [Month]()
    
    func savePassedData() {
             do {
                 try context.save()
                print("Data saved!")
             } catch {
                 print("Error saving: \(error)")
             }
             
             
         }
    
    func loadPassedData() {

        let request : NSFetchRequest<WorkEntry> = WorkEntry.fetchRequest()

        do{
            entryArray = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }

    }
    
    func fetchExistingData (year: String, month: String, entryData: [String],timeStamp: Int, date: Int, timeStart: Int, timeEnd: Int, workHours: Int, desc:Int ) {
        loadYears()
        
        var enteredMonth = month
        switch enteredMonth {
        case "1":
            enteredMonth = "January"
        case "2":
            enteredMonth = "February"
        case "3":
            enteredMonth = "March"
        case "4":
            enteredMonth = "April"
        case "5":
            enteredMonth = "May"
        case "6":
            enteredMonth = "June"
        case "7":
            enteredMonth = "July"
        case "8":
            enteredMonth = "August"
        case "9":
            enteredMonth = "September"
        case "10":
            enteredMonth = "October"
        case "11":
            enteredMonth = "November"
        case "12":
            enteredMonth = "December"
        default:
            print("lol")
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Year")
        fetchRequest.fetchLimit =  1
        fetchRequest.predicate = NSPredicate(format: "year == [d] %@" ,year)
        fetchRequest.includesPendingChanges = false
    
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                print("Year already added!: \(year)")
                
                for entity in yearArray {
                    if entity.year == year {
                        fetchExistingMonth(month: enteredMonth, yearString: entity.year!, year: entity, entryData: entryData, timeStamp: timeStamp, date: date, timeStart: timeStart, timeEnd: timeEnd, workHours: workHours, desc:desc)
                    }
                }
            } else {
                let newYear = Year(context: context)
                newYear.year = year
                yearArray.append(newYear)
                savePassedData()
                fetchExistingMonth(month: enteredMonth, yearString: newYear.year!, year: newYear, entryData: entryData, timeStamp: timeStamp, date: date, timeStart: timeStart, timeEnd: timeEnd, workHours: workHours, desc:desc)
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            
        }
        
    }
    
    func fetchExistingMonth (month: String,yearString : String,year: Year, entryData: [String],timeStamp: Int, date: Int, timeStart: Int, timeEnd: Int, workHours: Int, desc:Int) {
        print("Entered fetchExistingMonth")
        loadMonths(year: year)
    
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Month")
            fetchRequest.fetchLimit =  1
        
        let yearPredicate = NSPredicate(format: "parentEntity == %@", year)
        let monthPredicate = NSPredicate(format: "month == %@" ,month)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate, monthPredicate])
      

        fetchRequest.includesPendingChanges = false
        fetchRequest.includesSubentities = false
        
            do {
                let count = try context.count(for: fetchRequest)
                if count > 0 {
                    //print("count is \(count)")
                    print("Month already added!: \(month)")
                    for entity in monthArray {
                        if entity.month == month  {
                            fetchExistingEntry(entryDate: entryData[date], year: (entity.parentEntity?.year!)!, month: entity, yearEntity: year, entryData: entryData, timeStamp: timeStamp, date: date, timeStart: timeStart, timeEnd: timeEnd, workHours: workHours, desc:desc)
                        }
                    }
                } else {
                    let newMonth = Month(context: context)
                    newMonth.month = month
                    newMonth.parentEntity = year
                    monthArray.append(newMonth)
                    savePassedData()
                    
                    if newMonth.parentEntity?.year == yearString {
                        fetchExistingEntry(entryDate: entryData[date], year: (newMonth.parentEntity?.year!)!, month: newMonth, yearEntity: year, entryData: entryData, timeStamp: timeStamp, date: date, timeStart: timeStart, timeEnd: timeEnd, workHours: workHours, desc:desc)
                    }
                  print("Datum koji je prosa: \(month)")
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
}
    
    func fetchExistingEntry (entryDate: String, year: String,month: Month, yearEntity: Year, entryData: [String],timeStamp: Int, date: Int, timeStart: Int, timeEnd: Int, workHours: Int, desc:Int) {
        print("Entered fetchExistingEntry")

        entries()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WorkEntry")

        fetchRequest.fetchLimit =  1
        
        let yearPredicate = NSPredicate(format: "parentEntity == %@", month)
        let timeStampPredicate = NSPredicate(format: "timestamp == [d] %@", entryData[timeStamp])
        let datePredicate = NSPredicate(format: "date == [d] %@" ,entryDate)
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate, datePredicate, timeStampPredicate])
        fetchRequest.includesPendingChanges = false
        fetchRequest.includesSubentities = false

            do {
                let count = try context.count(for: fetchRequest)
                if count > 0 {
                    print("Entry already added!: \(true)")
                } else {
                        print("Adding entry: \(entryData[date])")
                        let newEntry = WorkEntry(context: context)
                        newEntry.year = year
                        newEntry.timestamp = entryData[timeStamp]
                        newEntry.date = entryData[date]
                        newEntry.start = entryData[timeStart]
                        newEntry.end = entryData[timeEnd]
                        newEntry.workHours = entryData[workHours]
                        newEntry.desc = entryData[desc]
                        newEntry.parentEntity = month
                    
                        entryArray.append(newEntry)
                        savePassedData()

                }
            }catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                
            }

}
    func loadYears() {

        let request : NSFetchRequest<Year> = Year.fetchRequest()

        do{
            yearArray = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }

    }
    
    func loadMonths(with request: NSFetchRequest<Month> = Month.fetchRequest(), predicate: NSPredicate? = nil, year: Year) {
        
        let yearPredicate = NSPredicate(format: "parentEntity.year LIKE %@", year.year! as String)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [yearPredicate, addtionalPredicate])
        } else {
            request.predicate = yearPredicate
        }

        
        do {
            monthArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }

    }
    
    func entries() {

        let request : NSFetchRequest<WorkEntry> = WorkEntry.fetchRequest()

        do{
            entryArray = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
    }
    
    func loadEntries(with request: NSFetchRequest<WorkEntry> = WorkEntry.fetchRequest(), predicate: NSPredicate? = nil, month: Month) {
        
        let monthPredicate = NSPredicate(format: "parentEntity.month LIKE %@", month.month! as String)
        
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate, addtionalPredicate])
        } else {
            request.predicate = monthPredicate
        }

        
        do {
            entryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }
}

