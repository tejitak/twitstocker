//
//  FavoriteViewController.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2014/12/28.
//  Copyright (c) 2014年 Takuya Tejima. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit

class FavoriteViewController: BaseTweetViewController {
    
    var alert : UIAlertController?
    var onUnFavorite : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("favorite_title", comment: "")
        
        prototypeCell = TWTRTweetTableViewCell(style: .Default, reuseIdentifier: "cell")
        
        tableView.registerClass(FavoriteTableViewCell.self, forCellReuseIdentifier: "cell")
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
                self.alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .Alert)
                self.alert!.addAction(UIAlertAction(title: NSLocalizedString("common_close", comment: ""), style: .Cancel, handler: nil))
                self.presentViewController(self.alert!, animated: true, completion: nil)
                errcb()
        })
    }
}

extension FavoriteViewController: FavoriteTableViewCellDelegate {
    func unfavoriteTweet(cell: FavoriteTableViewCell) {
        let index: Int = cell.tag
        if SettingStore.sharedInstance.isNoConfirm() {
            self.submitUnfavorite(index, cell: cell)
        } else {
            // show confirmation
            self.alert = UIAlertController(title: NSLocalizedString("favorite_confirm_stop", comment: ""), message: nil, preferredStyle: .Alert)
            self.alert!.addAction(UIAlertAction(title: NSLocalizedString("common_ok", comment: ""), style: .Destructive) { action in
                self.submitUnfavorite(index, cell: cell)
            })
            self.alert!.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: ""), style: .Cancel) { action in
                cell.moveToRight()
            })
            self.presentViewController(self.alert!, animated: true, completion: nil)
        }
    }
    
    func submitUnfavorite(index: Int, cell: FavoriteTableViewCell) {
        // call favorite API
        if tweets.count > index {
            var params = ["id": self.tweets[index].tweetID]
            TwitterAPI.unfavoriteTweet(params, success: {
                twttrs in
                self.view.makeToast(message: NSLocalizedString("favorite_alert_stop_done", comment: ""), duration: 2, position: HRToastPositionTop)
                // remove from view
                var tweet = self.tweets[index]
                // remove registered id from local storage
                if let obj = ReadStore.sharedInstance.getStoredData(tweet.tweetID) {
                    ReadStore.sharedInstance.deleteReadData(obj, reload: true)
                }
                self.tweets.removeAtIndex(index)
                self.tableView!.reloadData()
                // set reload flag to read view
                self.onUnFavorite?()
                }, error: {
                    error in
                    cell.moveToRight()
                    self.alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .Alert)
                    self.alert!.addAction(UIAlertAction(title: NSLocalizedString("common_close", comment: ""), style: .Cancel, handler: nil))
                    self.presentViewController(self.alert!, animated: true, completion: nil)
            })
        }
    }
}

extension FavoriteViewController : UITableViewDataSource {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as FavoriteTableViewCell
        cell.delegate = self
        return cell
    }
}