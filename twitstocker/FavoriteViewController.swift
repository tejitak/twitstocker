//
//  SecondViewController.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2014/12/28.
//  Copyright (c) 2014年 Takuya Tejima. All rights reserved.
//

import UIKit
import UIKit
import TwitterKit

class FavoriteViewController: BaseTweetViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Favorites"
        
        prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)

        refresh()
    }
    
    override func loadMore(cb: ()->(), errcb: () -> ()) {
        var params = ["count": String(self.count)]
        if self.maxIdStr != "" {
            params["max_id"] = self.maxIdStr
        }
        TwitterAPI.listMyFavorites(params, {
            twttrs in
            cb()
            for tweet in twttrs {
                // adjust max_id position because requested max_id is included in a result on favorite API
                if tweet.tweetID == self.maxIdStr {
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