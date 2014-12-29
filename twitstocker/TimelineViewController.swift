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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Stocked Tweets"
        
        prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        
        tableView.registerClass(StockedTweetTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        loadTweets({() -> () in }, errcb: {() -> () in })
//        refresh()
    }
    
    override func refresh() {
        loadTweets({() -> () in
            // clear existing tweets
            self.tweets = []
            self.refreshControl.endRefreshing()
        }, errcb: {() -> () in self.refreshControl.endRefreshing()})
    }
    
    func loadTweets(cb: ()->(), errcb: () -> ()) {
        TwitterAPI.getUserTimeline(Twitter.sharedInstance().session().userName, {
            twttrs in
            cb()
            for tweet in twttrs {
                self.tweets.append(tweet)
            }
            }, error: {
                error in
                println(error.localizedDescription)
                errcb()
        })
    }
}