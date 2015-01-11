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
    
    var alert : UIAlertController?
    var onFavorite : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "未読記事"
        
        prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        
        tableView.registerClass(StockedTweetTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
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
                if ReadStore.sharedInstance.existsInStoredData(tweet.tweetID) {
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
}

extension TimelineViewController: StockedTableViewCellDelegate {
    func favoriteTweet(cell: StockedTweetTableViewCell) {
        let index: Int = cell.tag
        // show confirmation
        self.alert = UIAlertController(title: "お気に入りしますか？", message: nil, preferredStyle: .Alert)
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
                ReadStore.sharedInstance.saveReadData(tweet.tweetID, createdAt: tweet.createdAt)
                self.tweets.removeAtIndex(index)
                self.tableView!.reloadData()
                // set reload flag to fav view
                self.onFavorite?()
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
//        self.alert = UIAlertController(title: "ツイートが削除されますがよろしいですか？", message: nil, preferredStyle: .Alert)
//        self.alert!.addAction(UIAlertAction(title: "Delete", style: .Destructive) { action in
//            self.tweets.removeAtIndex(index)
//            self.tableView!.reloadData()
//        })
//        self.alert!.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
//        self.presentViewController(self.alert!, animated: true, completion: nil)
//    }
    
    func readTweet(cell: StockedTweetTableViewCell) {
        let index: Int = cell.tag
        self.alert = UIAlertController(title: "既読にしますか？", message: nil, preferredStyle: .Alert)
        self.alert!.addAction(UIAlertAction(title: "既読にする", style: .Destructive) { action in
            var tweet = self.tweets[index]
            // store to local storage
            ReadStore.sharedInstance.saveReadData(tweet.tweetID, createdAt: tweet.createdAt)
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