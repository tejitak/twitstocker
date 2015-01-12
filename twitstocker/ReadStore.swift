//
//  ReadStore.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2015/01/11.
//  Copyright (c) 2015年 Takuya Tejima. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ReadStore {
    
    let entityName:String = "Read"

    let expiration: Int = 30
    var readDataList = [NSManagedObject]()
    
    class var sharedInstance :ReadStore {
        struct Static {
            static let instance = ReadStore()
        }
        return Static.instance
    }
    
    // check the tweet id is in stored data
    func getStoredData(id: String) -> NSManagedObject? {
        for obj:NSManagedObject in self.readDataList {
            if id == obj.valueForKey("id") as? String {
                return obj
            }
        }
        return nil
    }
    
    // read from CoreData
    func load() {
        self.readDataList = []
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let manageContext = appDelegate.managedObjectContext!
        /* Set search conditions */
        let fetchRequest = NSFetchRequest(entityName: self.entityName)
        var error: NSError?
        /* Get result array from ManagedObjectContext */
        let fetchResults = manageContext.executeFetchRequest(fetchRequest, error: &error)
        if let results: Array = fetchResults {
            var removeList = [NSManagedObject]();
            for obj:AnyObject in results {
                // check if 2 weeks past to delete old tweets never shown in search API
                let id:String? = obj.valueForKey("id") as? String
                let createdAt:NSDate? = obj.valueForKey("createdAt") as? NSDate
                let calendar = NSCalendar.currentCalendar()
                let comps = NSDateComponents()
                comps.day = -self.expiration
                let twoWeeksAgo = calendar.dateByAddingComponents(comps, toDate: NSDate(), options: NSCalendarOptions.allZeros)
                if createdAt?.compare(twoWeeksAgo!) == NSComparisonResult.OrderedAscending {
                    removeList.append(obj as NSManagedObject)
                    continue
                }
                self.readDataList.append(obj as NSManagedObject)
            }
            // remove
            for obj:NSManagedObject in removeList {
                self.deleteReadData(obj)
            }
        } else {
//            println("Could not fetch \(error) , \(error!.userInfo)")
        }
    }
    
    // Add an entry already read in CoreData
    func saveReadData(id: String, createdAt: NSDate){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        /* Create new ManagedObject */
        let entity = NSEntityDescription.entityForName(self.entityName, inManagedObjectContext: managedContext)
        let obj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        /* Set the name attribute using key-value coding */
        obj.setValue(id, forKey: "id")
        obj.setValue(createdAt, forKey: "createdAt")
        /* Error handling */
        var error: NSError?
        if !managedContext.save(&error) {
//            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    // delete an entry in CoreData
    func deleteReadData(managedObject: NSManagedObject) {
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        /* Delete managedObject from managed context */
        managedContext.deleteObject(managedObject)
        /* Save value to managed context */
        var error: NSError?
        if !managedContext.save(&error) {
//            println("Could not update \(error), \(error!.userInfo)")
        }
    }
    
    func resetAllReadData(){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let manageContext = appDelegate.managedObjectContext!
        /* Set search conditions */
        let fetchRequest = NSFetchRequest(entityName: self.entityName)
        var error: NSError?
        /* Get result array from ManagedObjectContext */
        let fetchResults = manageContext.executeFetchRequest(fetchRequest, error: &error)
        if let results: Array = fetchResults {
            var removeList = [NSManagedObject]();
            for obj:AnyObject in results {
                self.deleteReadData(obj as NSManagedObject)
            }
        } else {
//            println("Could not fetch \(error) , \(error!.userInfo)")
        }
    }
}