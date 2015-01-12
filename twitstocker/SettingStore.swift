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
    
    let KEY_HASHTAG: String = "hashtag"
    let KEY_NO_CONFRIM: String = "noConfirm"
    
    var config: NSManagedObject?

//    var hashtag: String = ""
//    var needConfirm: Bool = true
    
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
            if results.count > 0 {
                self.config = results[0] as? NSManagedObject
            }
        } else {
//            println("Could not fetch \(error) , \(error!.userInfo)")
        }
    }
    
    func saveSettingData(key: String, value: AnyObject?){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        if self.config == nil {
            /* Create new ManagedObject */
            let entity = NSEntityDescription.entityForName(self.entityName, inManagedObjectContext: managedContext)
            self.config = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        }
        /* Set the name attribute using key-value coding */
        self.config?.setValue(value, forKey: key)
        
        /* Error handling */
        var error: NSError?
        if !managedContext.save(&error) {
//            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    func getHashtag() -> String? {
        return self.config?.valueForKey(self.KEY_HASHTAG) as String?
    }

    func saveHashtag(hashtag: String?) {
        self.saveSettingData(self.KEY_HASHTAG, value: hashtag)
    }
    
    func getNoConfirm() -> Bool {
        return self.config?.valueForKey(self.KEY_NO_CONFRIM) as Bool
    }

    func saveNoConfirm(noConfirm: Bool) {
        self.saveSettingData(self.KEY_NO_CONFRIM, value: noConfirm)
    }
}