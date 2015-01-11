//
//  SettingStore.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2015/01/11.
//  Copyright (c) 2015年 Takuya Tejima. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class SettingStore {
    
    let entityName: String = "Setting"
    
    var hashtag: String = ""
    var skipTutorial: Bool = false
    var needConfirm: Bool = true
    
    class var sharedInstance :SettingStore {
        struct Static {
            static let instance = SettingStore()
        }
        return Static.instance
    }
    
    // read from CoreData
    func load() {
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let manageContext = appDelegate.managedObjectContext!
        /* Set search conditions */
        let fetchRequest = NSFetchRequest(entityName: self.entityName)
        var error: NSError?
        /* Get result array from ManagedObjectContext */
        let fetchResults = manageContext.executeFetchRequest(fetchRequest, error: &error)
        if let results: Array = fetchResults {
            for obj:AnyObject in results {
                // check if 2 weeks past to delete old tweets never shown in search API
                self.hashtag = obj.valueForKey("hashtag") as String
                self.skipTutorial = obj.valueForKey("skipTutorial") as Bool
                self.needConfirm = obj.valueForKey("needConfirm") as Bool
            }
        } else {
            println("Could not fetch \(error) , \(error!.userInfo)")
        }
    }
    
    func saveSettingData(key: String, value: AnyObject?){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        /* Create new ManagedObject */
        let entity = NSEntityDescription.entityForName(self.entityName, inManagedObjectContext: managedContext)
        let obj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        /* Set the name attribute using key-value coding */
        obj.setValue(value, forKey: key)
        /* Error handling */
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        println("object saved")
    }
    
}