//
//  TimelineViewController.swift
//  test
//
//  Created by TEJIMA TAKUYA on 2014/12/24.
//  Copyright (c) 2014年 TEJIMA TAKUYA. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit
import CoreData

class TimelineViewController: BaseTweetViewController {
    
    var readDataList = [NSManagedObject]()
    var alert : UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Stocked Tweets"
        
        prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        
        tableView.registerClass(StockedTweetTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        // initialize local stored core data
        fetchReadData()
        // load first page
        refresh()
    }
    
    override func loadMore(cb: ()->(), errcb: () -> ()) {
        var q = self.searchHashTag == "" ? "filter:links+-filter:images" : self.searchHashTag
        // exclude tweets already read
        if excludeHashTag != "" {
            q += "+-" + self.excludeHashTag
        }
        var params = ["q": q + "+from:" + Twitter.sharedInstance().session().userName, "result_type": "recent", "count": String(self.count)]
        if self.maxIdStr != "" {
            params["max_id"] = self.maxIdStr
        }
        TwitterAPI.search(params, tweets: {
            twttrs in
            cb()
            for tweet in twttrs {
                // exclude favorited
                if tweet.isFavorited == true {
                    continue
                }
                // exclude stored ids already read
                if self.existsInStoredData(tweet.tweetID) {
                    continue
                }
                self.tweets.append(tweet)
                self.maxIdStr = tweet.tweetID
            }
            // end of all pages
            if twttrs.count < self.count {
                self.maxIdStr = ""
            }
            self.tableView.reloadData()
            }, error: {
                error in
                println(error.localizedDescription)
                errcb()
        })
    }
    
    // check the tweet id is in stored data
    func existsInStoredData(id: String) -> Bool {
        for obj:NSManagedObject in self.readDataList {
            if id == obj.valueForKey("id") as? String {
                return true
            }
        }
        return false
    }
    
    // read from CoreData
    func fetchReadData() {
        self.readDataList = []
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let manageContext = appDelegate.managedObjectContext!
        /* Set search conditions */
        let fetchRequest = NSFetchRequest(entityName: "Read")
        var error: NSError?
        /* Get result array from ManagedObjectContext */
        let fetchResults = manageContext.executeFetchRequest(fetchRequest, error: &error)
        if let results: Array = fetchResults {
            var removeList = [NSManagedObject]();
            for obj:AnyObject in results {
                // TODO: check if 2 weeks past to delete old tweets never shown in search API
//                if obj {
//                    removeList.append(obj as NSManagedObject)
//                    continue
//                }
                self.readDataList.append(obj as NSManagedObject)
                let id:String? = obj.valueForKey("id") as? String
                let createdAt:NSDate? = obj.valueForKey("createdAt") as? NSDate
                println(id)
                println(createdAt)
            }
            println(results.count)
            // TODO: remove
            for obj:NSManagedObject in removeList {
//                deleteRead(obj)
            }
        } else {
            println("Could not fetch \(error) , \(error!.userInfo)")
        }
    }

    // Add an entry already read in CoreData
    func saveReadData(id: String, createdAt: NSDate){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        /* Create new ManagedObject */
        let entity = NSEntityDescription.entityForName("Read", inManagedObjectContext: managedContext)
        let obj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        /* Set the name attribute using key-value coding */
        obj.setValue(id, forKey: "id")
        obj.setValue(createdAt, forKey: "createdAt")
        /* Error handling */
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        println("object saved")
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
            println("Could not update \(error), \(error!.userInfo)")
        }
        println("Object deleted")
    }
    
    func resetAllReadData(){
        /* Get ManagedObjectContext from AppDelegate */
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let manageContext = appDelegate.managedObjectContext!
        /* Set search conditions */
        let fetchRequest = NSFetchRequest(entityName: "Read")
        var error: NSError?
        /* Get result array from ManagedObjectContext */
        let fetchResults = manageContext.executeFetchRequest(fetchRequest, error: &error)
        if let results: Array = fetchResults {
            var removeList = [NSManagedObject]();
            for obj:AnyObject in results {
                self.deleteReadData(obj as NSManagedObject)
            }
        } else {
            println("Could not fetch \(error) , \(error!.userInfo)")
        }
    }
}

extension TimelineViewController: StockedTableViewCellDelegate {
    func favoriteTweet(cell: StockedTweetTableViewCell) {
        let index: Int = cell.tag
        // show confirmation
        self.alert = UIAlertController(title: "このツイートをお気に入りしますか？", message: nil, preferredStyle: .Alert)
        self.alert!.addAction(UIAlertAction(title: "お気に入り", style: .Destructive) { action in
            // call favorite API
            var params = ["id": self.tweets[index].tweetID]
            TwitterAPI.favoriteTweet(params, success: {
                twttrs in
                self.alert = UIAlertController(title: "お気に入りしました", message: nil, preferredStyle: .Alert)
                self.alert!.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                self.presentViewController(self.alert!, animated: true, completion: nil)
                // remove from view
                var tweet = self.tweets[index]
                // store to local storage
                self.saveReadData(tweet.tweetID, createdAt: tweet.createdAt)
                self.tweets.removeAtIndex(index)
                self.tableView!.reloadData()
                // TODO: set reload flag to fav view
                
                
                }, error: {
                    error in
                    println(error.localizedDescription)
                    self.alert = UIAlertController(title: "Error", message: nil, preferredStyle: .Alert)
                    self.alert!.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                    self.presentViewController(self.alert!, animated: true, completion: nil)
            })
        })
        self.alert!.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { action in
            cell.moveToLeft()
        })
        self.presentViewController(self.alert!, animated: true, completion: nil)
    }
    
//    func removeTweet(cell: StockedTweetTableViewCell) {
//        let index: Int = cell.tag
//        self.alert = UIAlertController(title: "このツイートが削除されますがよろしいですか？", message: nil, preferredStyle: .Alert)
//        self.alert!.addAction(UIAlertAction(title: "Delete", style: .Destructive) { action in
//            self.tweets.removeAtIndex(index)
//            self.tableView!.reloadData()
//        })
//        self.alert!.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
//        self.presentViewController(self.alert!, animated: true, completion: nil)
//    }
    
    func readTweet(cell: StockedTweetTableViewCell) {
        let index: Int = cell.tag
        self.alert = UIAlertController(title: "このツイートを既読にしますか？", message: nil, preferredStyle: .Alert)
        self.alert!.addAction(UIAlertAction(title: "既読にする", style: .Destructive) { action in
            var tweet = self.tweets[index]
            // store to local storage
            self.saveReadData(tweet.tweetID, createdAt: tweet.createdAt)
            self.tweets.removeAtIndex(index)
            self.tableView!.reloadData()
        })
        self.alert!.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { action in
            cell.moveToRight()
        })
        self.presentViewController(self.alert!, animated: true, completion: nil)
    }

}

extension TimelineViewController : UITableViewDataSource {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as StockedTweetTableViewCell
        cell.delegate = self
        return cell
    }
}