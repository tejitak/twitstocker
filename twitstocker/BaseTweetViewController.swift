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
import MoPub

class BaseTweetViewController: UIViewController, MPAdViewDelegate {
    
    var tableView: UITableView!
    var tweets: [TWTRTweet] = []
    var prototypeCell: TWTRTweetTableViewCell?
    var refreshControl:UIRefreshControl!
    var maxIdStr:String = ""
    var needReload:Bool = false
    
    // count per an API request
    let count:Int = 20
    
    // MoPub AdUnitID
    var adView: MPAdView = MPAdView(adUnitId: "2e574b41acd448268fbd2d732dbf6969", size: MOPUB_BANNER_SIZE)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView = UITableView(frame: bounds)
        let bounds = self.view.bounds;
        tableView = UITableView(frame: CGRectMake(bounds.origin.x, bounds.origin.y, bounds.width, bounds.height - 49/*tabBarHieght*/))
        tableView.delegate = self
        tableView.dataSource = self

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "refresh")
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        tableView.registerClass(self.registerTableClass(), forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)

        // nav right item button
        var settingBtn:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        settingBtn.addTarget(self, action: "onClickSetting", forControlEvents: UIControlEvents.TouchUpInside)
        settingBtn.frame = CGRectMake(0, 0, 24, 24)
        settingBtn.setImage(UIImage(named: "settings-50.png"), forState: .Normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingBtn)
        
        setupAds()
    }
    
    func registerTableClass() -> UITableViewCell.Type {
        return TWTRTweetTableViewCell.self
    }
    
    func setupAds(){
        self.adView.delegate = self
        self.adView.frame = CGRectMake(0, self.tableView.bounds.size.height - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)
        self.view.addSubview(self.adView)
        self.adView.loadAd()
    }
    
    // for MoPub
    func viewControllerForPresentingModalView() -> UIViewController {
        return self
    }
    
    func refresh() {
        // clear existing tweets
        self.tweets = []
        self.maxIdStr = ""
        self.view.makeToastActivity()
        loadMore({() -> () in
            self.refreshControl.endRefreshing()
            self.view.hideToastActivity()
            }, errcb: {() -> () in
                self.refreshControl.endRefreshing()
                self.view.hideToastActivity()
            }
        )
    }
    
    override func viewDidAppear(animated: Bool) {
        if needReload == true {
            refresh()
            needReload = false
        }
    }

    // for override
    func loadMore(cb: ()->(), errcb: () -> ()) {
    }
    
    func onClickSetting() {
        let settingViewCtrl = SettingViewController()
        let modalView = UINavigationController(rootViewController: settingViewCtrl)
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
            // for TWTRTweetViewDelegate to handling on select
            cell.tweetView.delegate = self
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
        let tweet = tweets[indexPath.row]
        if tweets.count > indexPath.row {
            prototypeCell?.configureWithTweet(tweet)
        }
        // fabric 1.1以降は以下のクラスfuncでheightが取得できる
        return TWTRTweetTableViewCell.heightForTweet(tweet, width: self.view.bounds.width)
    }
}

extension BaseTweetViewController : TWTRTweetViewDelegate {
    // tap a cell
    func tweetView(tweetView: TWTRTweetView!, didSelectTweet tweet: TWTRTweet!) {
        var url: String = ""
        if let urlTweet = tweet as? URLTweet {
            url = urlTweet.url
        }
        if url == "" {
            return
        }
        self.openWebView(NSURL(string: url)!)
    }
    
    // tap a link in cell
    func tweetView(tweetView: TWTRTweetView!, didTapURL url: NSURL!) {
        self.openWebView(url)
    }
    
    func openWebView(url: NSURL){
        let webviewController = StockWebViewController()
        webviewController.url = url
        webviewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(webviewController, animated: true)
    }
}