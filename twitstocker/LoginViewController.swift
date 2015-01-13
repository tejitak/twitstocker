//
//  LoginViewController.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2014/12/28.
//  Copyright (c) 2014年 Takuya Tejima. All rights reserved.
//

import Foundation
import TwitterKit

class LoginViewController: UIViewController {

    var alert : UIAlertController?
    var pageControl: UIPageControl!
    var scrollView: UIScrollView!
    
    let pageSize = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let width = self.view.frame.maxX, height = self.view.frame.maxY
        self.view.backgroundColor = UIColor.blueColor()
        scrollView = UIScrollView(frame: self.view.frame)

        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        scrollView.contentSize = CGSizeMake(CGFloat(self.pageSize) * width, 0)
        self.view.addSubview(scrollView)
        // create all images
        for var i = 0; i < self.pageSize; i++ {
            let myLabel:UILabel = UILabel(frame: CGRectMake(CGFloat(i) * width + width/2 - 40, height/2 - 40, 80, 80))
            myLabel.backgroundColor = UIColor.blackColor()
            myLabel.textColor = UIColor.whiteColor()
            myLabel.textAlignment = NSTextAlignment.Center
            myLabel.layer.masksToBounds = true
            myLabel.text = "Page\(i)"
            myLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
            myLabel.layer.cornerRadius = 40.0
            scrollView.addSubview(myLabel)
        }
        pageControl = UIPageControl(frame: CGRectMake(0, self.view.frame.maxY - 130, width, 50))
        pageControl.numberOfPages = self.pageSize
        pageControl.currentPage = 0
        pageControl.userInteractionEnabled = false
        self.view.addSubview(pageControl)
        
        let logInButton = TWTRLogInButton(logInCompletion: {
            (session: TWTRSession!, error: NSError!) in
            if session != nil {
                UIApplication.sharedApplication().keyWindow?.rootViewController = MainTabViewController()
            } else {
                // show an error
                self.alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .Alert)
                self.alert!.addAction(UIAlertAction(title: "閉じる", style: .Cancel, handler: nil))
                self.presentViewController(self.alert!, animated: true, completion: nil)
            }
        })
        logInButton.frame = CGRectMake(0, self.view.frame.maxY - 80, width, 80)
        self.view.addSubview(logInButton)
    }
}

extension LoginViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if fmod(scrollView.contentOffset.x, scrollView.frame.maxX) == 0 {
            pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.maxX)
        }
    }
}