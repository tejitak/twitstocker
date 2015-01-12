//
//  TimelineViewController.swift
//  twitstocker
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
    var unreadCount : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "未読記事"
        
        prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        
        tableView.registerClass(StockedTweetTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        // load first page
        refresh()
    }
    
    override func refresh() {
        self.unreadCount = 0
        super.refresh()
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
                if ReadStore.sharedInstance.getStoredData(tweet.tweetID) != nil {
                    continue
                }
                // update title
                self.unreadCount++
                self.updateTitle()
                self.tweets.append(tweet)
                self.maxIdStr = tweet.tweetID
            }
            if twttrs.count < self.count {
                // end of all pages
                self.maxIdStr = ""
                // TODO: show screen for no unread tweets
                if self.tweets.count == 0 {
                
                }
            }else{
                // continue to load until all done
                self.loadMore({() -> () in }, errcb: {() -> () in })
            }
            self.tableView.reloadData()
            }, error: {
                error in
                self.alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .Alert)
                self.alert!.addAction(UIAlertAction(title: "閉じる", style: .Cancel, handler: nil))
                self.presentViewController(self.alert!, animated: true, completion: nil)
                errcb()
        })
    }
    
    func updateTitle(){
        self.title = "未読記事(" + String(self.unreadCount) + ")"
    }
}

extension TimelineViewController: StockedTableViewCellDelegate {
    func favoriteTweet(cell: StockedTweetTableViewCell) {
        let index: Int = cell.tag
        if SettingStore.sharedInstance.isNoConfirm() {
            self.submitFavorite(index, cell: cell)
        } else {
            // show confirmation
            self.alert = UIAlertController(title: "お気に入りしますか？", message: nil, preferredStyle: .Alert)
            self.alert!.addAction(UIAlertAction(title: "OK", style: .Destructive) { action in
                self.submitFavorite(index, cell: cell)
            })
            self.alert!.addAction(UIAlertAction(title: "キャンセル", style: .Cancel) { action in
                cell.moveToLeft()
            })
            self.presentViewController(self.alert!, animated: true, completion: nil)
        }
    }
    
    func submitFavorite(index: Int, cell: StockedTweetTableViewCell) {
        // call favorite API
        if tweets.count > index {
            var params = ["id": self.tweets[index].tweetID]
            TwitterAPI.favoriteTweet(params, success: {
                twttrs in
                self.view.makeToast(message: "お気に入りしました", duration: 2, position: HRToastPositionTop)
                // remove from view
                var tweet = self.tweets[index]
                // store to local storage
                ReadStore.sharedInstance.saveReadData(tweet.tweetID, createdAt: tweet.createdAt)
                self.tweets.removeAtIndex(index)
                self.unreadCount--
                self.updateTitle()
                self.tableView!.reloadData()
                // set reload flag to fav view
                self.onFavorite?()
                }, error: {
                    error in
                    // maybe already favorited
                    // remove from view
                    var tweet = self.tweets[index]
                    // store to local storage
                    ReadStore.sharedInstance.saveReadData(tweet.tweetID, createdAt: tweet.createdAt)
                    self.tweets.removeAtIndex(index)
                    self.unreadCount--
                    self.updateTitle()
                    self.tableView!.reloadData()
                    // set reload flag to fav view
                    self.onFavorite?()
//                    cell.moveToLeft()
//                    self.alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .Alert)
//                    self.alert!.addAction(UIAlertAction(title: "閉じる", style: .Cancel, handler: nil))
//                    self.presentViewController(self.alert!, animated: true, completion: nil)
            })
        }
    }
    
    func readTweet(cell: StockedTweetTableViewCell) {
        let index: Int = cell.tag
        if SettingStore.sharedInstance.isNoConfirm() {
            self.submitRead(index, cell: cell)
        }else{
            self.alert = UIAlertController(title: "既読にしますか？", message: nil, preferredStyle: .Alert)
            self.alert!.addAction(UIAlertAction(title: "OK", style: .Destructive) { action in
                self.submitRead(index, cell: cell)
            })
            self.alert!.addAction(UIAlertAction(title: "キャンセル", style: .Cancel) { action in
                cell.moveToRight()
            })
            self.presentViewController(self.alert!, animated: true, completion: nil)
        }
    }
        
    func submitRead(index: Int, cell: StockedTweetTableViewCell) {
        if tweets.count > index {
            self.view.makeToast(message: "既読にしました", duration: 2, position: HRToastPositionTop)
            var tweet = self.tweets[index]
            // store to local storage
            ReadStore.sharedInstance.saveReadData(tweet.tweetID, createdAt: tweet.createdAt)
            self.tweets.removeAtIndex(index)
            self.unreadCount--
            self.updateTitle()
            self.tableView!.reloadData()
        }
    }
}

extension TimelineViewController : UITableViewDataSource {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as StockedTweetTableViewCell
        if tweets.count > indexPath.row {
            cell.delegate = self
            let tweet = tweets[indexPath.row]
            cell.tag = indexPath.row
            cell.configureWithTweet(tweet)
        }
        return cell
    }
}