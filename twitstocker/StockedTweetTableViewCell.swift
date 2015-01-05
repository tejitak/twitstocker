//
//  StockedTweetViewCell.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2014/12/28.
//  Copyright (c) 2014年 Takuya Tejima. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit

@objc protocol StockedTableViewCellDelegate {
    optional func favoriteTweet(index: Int)
    optional func removeTweet(index: Int)
}

class StockedTweetTableViewCell : TWTRTweetTableViewCell {
    
    weak var delegate: StockedTableViewCellDelegate?
    var haveButtonsDisplayed = false
    
    func favoriteTweet() {
        delegate?.favoriteTweet?(self.tag)
    }
    
    func removeTweet() {
        delegate?.removeTweet?(self.tag)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        
        self.createView()
        
        self.contentView.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: "onRightSwipe"))
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "onLeftSwipe")
        swipeRecognizer.direction = .Left
        self.contentView.addGestureRecognizer(swipeRecognizer)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createView() {
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.backgroundView = UIView(frame: self.bounds)
    }
    
    func onLeftSwipe() {
        UIView.animateWithDuration(0.1, animations: {
            let size   = self.contentView.frame.size
            let origin = self.contentView.frame.origin
            self.contentView.frame = CGRect(x: origin.x - 100, y:origin.y, width:size.width, height:size.height)
            if origin.x == 0 {
                self.delegate?.removeTweet?(self.tag)
            }
            }) { completed in }
    }
    
    func onRightSwipe() {
        UIView.animateWithDuration(0.1, animations: {
            let size   = self.contentView.frame.size
            let origin = self.contentView.frame.origin
            self.contentView.frame = CGRect(x: origin.x + 100, y:origin.y, width:size.width, height:size.height)
            if origin.x == 0 {
                self.delegate?.favoriteTweet?(self.tag)
            }
            }) { completed in }
    }
}