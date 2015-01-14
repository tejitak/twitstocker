//
//  FavoriteTableViewCell.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2015/01/11.
//  Copyright (c) 2015年 Takuya Tejima. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit

@objc protocol FavoriteTableViewCellDelegate {
    optional func unfavoriteTweet(cell: FavoriteTableViewCell)
}

class FavoriteTableViewCell : TWTRTweetTableViewCell {
    
    weak var delegate: FavoriteTableViewCellDelegate?
    var haveButtonsDisplayed = false
    
    func unfavoriteTweet() {
        delegate?.unfavoriteTweet?(self)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        
        self.createView()
        
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
        self.backgroundView?.backgroundColor = Constants.Theme.concept()
        UIView.animateWithDuration(0.1, animations: {
            let size   = self.contentView.frame.size
            let origin = self.contentView.frame.origin
            self.contentView.frame = CGRect(x: origin.x - 100, y:origin.y, width:size.width, height:size.height)
            if origin.x == 0 {
                self.delegate?.unfavoriteTweet?(self)
            }
            }) { completed in }
    }
    
    func moveToRight() {
        let size   = self.contentView.frame.size
        let origin = self.contentView.frame.origin
        self.contentView.frame = CGRect(x: origin.x + 100, y:origin.y, width:size.width, height:size.height)
    }
}