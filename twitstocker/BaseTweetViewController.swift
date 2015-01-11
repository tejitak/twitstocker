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
    var tweets: [TWTRTweet] = []
    var prototypeCell: TWTRTweetTableViewCell?
    var refreshControl:UIRefreshControl!
    var maxIdStr:String = ""
    
    let count:Int = 10
    // if search hash tag is empty, filter with tweets including URL
//    let searchHashTag:String = "#あとで読む"
    let searchHashTag:String = ""
    let excludeHashTag:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: self.view.bounds)
        tableView.delegate = self
        tableView.dataSource = self

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "refresh")
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        // nav right item button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "設定", style: .Plain, target: self, action: "onClickSetting")
    }
    
    func refresh() {
        // clear existing tweets
        self.tweets = []
        self.maxIdStr = ""
        loadMore({() -> () in
            self.refreshControl.endRefreshing()
            }, errcb: {() -> () in self.refreshControl.endRefreshing()}
        )
    }
    
    // for override
    func loadMore(cb: ()->(), errcb: () -> ()) {
    }
    
    func onClickSetting() {
        let modalView = SettingViewController()
        modalView.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(modalView, animated: true, completion: nil)
    }
}

extension BaseTweetViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as TWTRTweetTableViewCell
        if tweets.count > indexPath.row {
            let tweet = tweets[indexPath.row]
            cell.tag = indexPath.row
            cell.configureWithTweet(tweet)
            // load more data by showing a last table cell
            if (tweets.count - 1) == indexPath.row && self.maxIdStr != "" {
                self.loadMore({() -> () in }, errcb: {() -> () in })
            }
        }
        return cell
    }
}

extension BaseTweetViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tweets.count > indexPath.row {
            let tweet = tweets[indexPath.row]
            prototypeCell?.configureWithTweet(tweet)
        }
        if let height = prototypeCell?.calculatedHeightForWidth(self.view.bounds.width) {
            return height
        } else {
            return tableView.estimatedRowHeight
        }
    }
}