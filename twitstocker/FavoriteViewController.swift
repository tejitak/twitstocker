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

        loadMyFavorites({() -> () in }, errcb: {() -> () in })
    }
    
    override func refresh() {
        loadMyFavorites({() -> () in
            // clear existing tweets
            self.tweets = []
            self.refreshControl.endRefreshing()
            }, errcb: {() -> () in self.refreshControl.endRefreshing()})
    }
    
    func loadMyFavorites(cb: ()->(), errcb: () -> ()) {
        TwitterAPI.listMyFavorites({
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