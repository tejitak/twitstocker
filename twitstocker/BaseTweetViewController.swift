//
//  BaseTweetViewController.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2014/12/28.
//  Copyright (c) 2014年 Takuya Tejima. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit

class BaseTweetViewController: UIViewController {
    
    var tableView: UITableView!
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var prototypeCell: TWTRTweetTableViewCell?
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: self.view.bounds)
        tableView.delegate = self
        tableView.dataSource = self

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "refresh")
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh() {
    }
}

extension BaseTweetViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as TWTRTweetTableViewCell
        
        let tweet = tweets[indexPath.row]
        cell.configureWithTweet(tweet)
        
        return cell
    }
}

extension BaseTweetViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = tweets[indexPath.row]
        
        prototypeCell?.configureWithTweet(tweet)
        
        if let height = prototypeCell?.calculatedHeightForWidth(self.view.bounds.width) {
            return height
        } else {
            return tableView.estimatedRowHeight
        }
    }
}