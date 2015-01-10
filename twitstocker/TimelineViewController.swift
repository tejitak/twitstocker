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

class TimelineViewController: BaseTweetViewController {
    
    var alert : UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Stocked Tweets"
        
        prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        
        tableView.registerClass(StockedTweetTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        refresh()
    }
    
    override func loadMore(cb: ()->(), errcb: () -> ()) {
        var params = ["q": "filter:links+-filter:images+from:" + Twitter.sharedInstance().session().userName, "result_type": "recent", "count": String(self.count)]
        if self.maxIdStr != "" {
            params["max_id"] = self.maxIdStr
        }
        TwitterAPI.search(params, tweets: {
            twttrs in
            cb()
            for tweet in twttrs {
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
    func favoriteTweet(index: Int) {
        // TODO: use favorite API
        self.alert = UIAlertController(title: "Favorited", message: nil, preferredStyle: .Alert)
        self.alert!.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        self.presentViewController(self.alert!, animated: true, completion: nil)
    }
    
    func removeTweet(index: Int) {
//        self.alertType = TodoAlertViewType.Remove(index)
        self.alert = UIAlertController(title: "削除", message: nil, preferredStyle: .Alert)
        self.alert!.addAction(UIAlertAction(title: "Delete", style: .Destructive) { action in
            self.tweets.removeAtIndex(index)
            self.tableView!.reloadData()
        })
        self.alert!.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
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