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
        
        self.contentView.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: "hideActionButton"))
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "showActionButton")
        swipeRecognizer.direction = .Left
        self.contentView.addGestureRecognizer(swipeRecognizer)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createView() {
        let origin  = self.frame.origin
        let size    = self.frame.size
        
        self.contentView.backgroundColor = UIColor.whiteColor()
        
        let favoriteButton = UIButton.buttonWithType(.System) as UIButton
        favoriteButton.frame = CGRect(x: size.width - 100, y: origin.y, width: 50, height: size.height)
        favoriteButton.backgroundColor = UIColor.greenColor()
        favoriteButton.setTitle("Favo", forState: .Normal)
        favoriteButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        favoriteButton.addTarget(self, action: "favoriteTweet", forControlEvents: .TouchUpInside)
        
        let removeButton = UIButton.buttonWithType(.System) as UIButton
        removeButton.frame = CGRect(x: size.width - 50, y: origin.y, width: 50, height: size.height)
        removeButton.backgroundColor = UIColor.redColor()
        removeButton.setTitle("Remove", forState: .Normal)
        removeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        removeButton.addTarget(self, action: "removeTweet", forControlEvents: .TouchUpInside)
        
        self.backgroundView = UIView(frame: self.bounds)
        self.backgroundView!.addSubview(favoriteButton)
        self.backgroundView!.addSubview(removeButton)
    }
    
    func showActionButton() {
        if !haveButtonsDisplayed {
            UIView.animateWithDuration(0.1, animations: {
                let size   = self.contentView.frame.size
                let origin = self.contentView.frame.origin
                
                self.contentView.frame = CGRect(x: origin.x - 100, y:origin.y, width:size.width, height:size.height)
                
                }) { completed in self.haveButtonsDisplayed = true }
        }
    }
    
    func hideActionButton() {
        if haveButtonsDisplayed {
            UIView.animateWithDuration(0.1, animations: {
                let size   = self.contentView.frame.size
                let origin = self.contentView.frame.origin
                
                self.contentView.frame = CGRect(x: origin.x + 100, y:origin.y, width:size.width, height:size.height)
                
                }) { completed in self.haveButtonsDisplayed = false }
        }
    }
}