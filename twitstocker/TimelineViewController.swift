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

class TimelineViewController: UIViewController {
    var tableView: UITableView!
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var prototypeCell: TWTRTweetTableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Stocked Tweets"
        
        tableView = UITableView(frame: self.view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        
        prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        loadTweets()
    }
    
    func loadTweets() {
        TwitterAPI.getHomeTimeline({
            twttrs in
            for tweet in twttrs {
                self.tweets.append(tweet)
            }
            }, error: {
                error in
                println(error.localizedDescription)
        })
    }
}

extension TimelineViewController : UITableViewDataSource {
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

extension TimelineViewController : UITableViewDelegate {
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
