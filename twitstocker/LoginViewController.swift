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
    
    let pageSize = 4
    let titleH: CGFloat = 70.0
    let controlH: CGFloat = 20.0
    let twBtnH: CGFloat = 80.0
    let imageW: CGFloat = 475
    let imageH: CGFloat = 327
    let paddingTop: CGFloat = 20.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let width = self.view.frame.maxX, height = self.view.frame.maxY
        self.view.backgroundColor = Constants.Theme.concept()
        scrollView = UIScrollView(frame: self.view.frame)

        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        scrollView.contentSize = CGSizeMake(CGFloat(self.pageSize) * width, 0)
        self.view.addSubview(scrollView)
        for var i = 0; i < self.pageSize; i++ {
            // show title message
            let x = CGFloat(i) * width
//            let introTitle:UILabel = UILabel(frame: CGRectMake(x, height - titleH - imageH - twBtnH - paddingTop, width, titleH))
            let margin = height - imageH - twBtnH - paddingTop * 2 - controlH
            let introTitle:UILabel = UILabel(frame: CGRectMake(x + 10, paddingTop * 2 + controlH + (margin - titleH) / 2, width - 20, titleH))
            introTitle.textColor = UIColor.whiteColor()
            introTitle.textAlignment = NSTextAlignment.Center
            introTitle.text = NSLocalizedString("tutorial_title_" + String(i + 1), comment: "")
            introTitle.numberOfLines = 0
            introTitle.lineBreakMode = NSLineBreakMode.ByWordWrapping
            scrollView.addSubview(introTitle)
            // show image
            let diffW = (width - imageW) / 2
            let imageView: UIImageView = UIImageView(frame: CGRectMake(x + diffW, height - imageH - twBtnH, imageW, imageH))
            let image = UIImage(named: NSLocalizedString("tutorial_image_" + String(i + 1), comment: ""))
            imageView.image = image
            scrollView.addSubview(imageView)
        }
//        pageControl = UIPageControl(frame: CGRectMake(0, height - controlH - imageH - twBtnH - titleH - paddingTop, width, controlH))
        pageControl = UIPageControl(frame: CGRectMake(0, paddingTop * 2, width, controlH))
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
                self.alert!.addAction(UIAlertAction(title: NSLocalizedString("common_close", comment: ""), style: .Cancel, handler: nil))
                self.presentViewController(self.alert!, animated: true, completion: nil)
            }
        })
        logInButton.frame = CGRectMake(0, self.view.frame.maxY - twBtnH, width, twBtnH)
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