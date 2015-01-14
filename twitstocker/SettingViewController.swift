//
//  SettingViewController.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2015/01/05.
//  Copyright (c) 2015年 Takuya Tejima. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit

class SettingViewController: UIViewController {
    
    var closeBtn: UIBarButtonItem?
    var hashtagInput: UITextField?
    var noConfirmSwitch: UISwitch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("setting_title", comment: "")
        self.view.backgroundColor = Constants.Theme.base()
        
        // right top close button
        var closeBtn:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        closeBtn.addTarget(self, action: "onClickClose", forControlEvents: UIControlEvents.TouchUpInside)
        closeBtn.frame = CGRectMake(0, 0, 20, 20)
        closeBtn.setImage(UIImage(named: "close-50.png"), forState: .Normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeBtn)
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        // hashtag
        let rowHeight: CGFloat = 40.0
        let rowPaddingTop: CGFloat = 4.0
        let rowPaddingLeft: CGFloat = 20.0
        let inputWidth: CGFloat = 200.0
        let switchWidth: CGFloat = 60.0
        
        let hashtagLabel: UILabel = UILabel(frame: CGRectMake(rowPaddingLeft, rowPaddingTop, width - inputWidth - rowPaddingLeft * 2, rowHeight))
        hashtagLabel.text = NSLocalizedString("setting_hashtag_input_label", comment: "")
        let hashtagInput = UITextField(frame: CGRectMake(width - inputWidth - rowPaddingLeft, rowPaddingTop, inputWidth, rowHeight))
        hashtagInput.borderStyle = UITextBorderStyle.None
        hashtagInput.placeholder = NSLocalizedString("setting_hashtag_input_placeholder", comment: "")
        hashtagInput.text = SettingStore.sharedInstance.getHashtag()
        self.hashtagInput = hashtagInput
        
        let container1 = UIView()
        container1.backgroundColor = UIColor.whiteColor()
        container1.frame = CGRectMake(0, 100, width, rowHeight + rowPaddingTop * 2)
        container1.addSubview(hashtagLabel)
        container1.addSubview(hashtagInput)
        self.view.addSubview(container1)
        
        let hashtagDescription: UILabel = UILabel(frame: CGRectMake(rowPaddingLeft, 160, width - rowPaddingLeft * 2, 0))
        hashtagDescription.text = NSLocalizedString("setting_hashtag_description", comment: "")
        hashtagDescription.font = UIFont.systemFontOfSize(12)
        hashtagDescription.textColor = Constants.Theme.gray()
        hashtagDescription.numberOfLines = 0
        hashtagDescription.textAlignment = NSTextAlignment.Left
        hashtagDescription.sizeToFit()
        hashtagDescription.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.view.addSubview(hashtagDescription)
        
        // no confirm
        let noConfirmLabel: UILabel = UILabel(frame: CGRectMake(rowPaddingLeft, rowPaddingTop, width - switchWidth - rowPaddingLeft, rowHeight))
        noConfirmLabel.text = NSLocalizedString("setting_swipe_confirm_label", comment: "")
        let noConfirmSwitch = UISwitch(frame: CGRectMake(width - switchWidth - rowPaddingLeft, rowPaddingTop + 4, switchWidth, rowHeight))
        noConfirmSwitch.on = SettingStore.sharedInstance.isNoConfirm()
        self.noConfirmSwitch = noConfirmSwitch
        let container2 = UIView()
        container2.backgroundColor = UIColor.whiteColor()
        container2.frame = CGRectMake(0, 260, width, rowHeight + rowPaddingTop * 2)
        container2.addSubview(noConfirmLabel)
        container2.addSubview(noConfirmSwitch)
        self.view.addSubview(container2)
        
        // reset read data
        let restBtn: UIButton = UIButton(frame: CGRectMake(rowPaddingLeft, 340, width - rowPaddingLeft * 2, rowHeight))
        restBtn.setTitle(NSLocalizedString("setting_reset_read_data", comment: ""), forState: UIControlState.Normal)
        restBtn.backgroundColor = Constants.Theme.reset()
        restBtn.layer.cornerRadius = 8
        restBtn.addTarget(self, action: "onClickResetReadData", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(restBtn)
        
        // logout
        let logoutBtn: UIButton = UIButton(frame: CGRectMake(rowPaddingLeft, 400, width - rowPaddingLeft * 2, rowHeight))
        logoutBtn.setTitle(NSLocalizedString("setting_twitter_logout", comment: ""), forState: UIControlState.Normal)
        logoutBtn.backgroundColor = Constants.Theme.twitter()
        logoutBtn.layer.cornerRadius = 8
        logoutBtn.addTarget(self, action: "onClickLogout", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(logoutBtn)
        
        // footer
        let footer: UILabel = UILabel(frame: CGRectMake(rowPaddingLeft * 2, height - 50, width - rowPaddingLeft * 4, rowHeight))
        footer.text = NSLocalizedString("common_app_name", comment: "") + " " + NSLocalizedString("common_version", comment: "") + Constants.Product.version() + ", " + NSLocalizedString("common_copyright", comment: "")
        footer.textColor = Constants.Theme.gray()
        footer.adjustsFontSizeToFitWidth = true
        self.view.addSubview(footer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onClickResetReadData(){
        ReadStore.sharedInstance.resetAllReadData()
        // reload timeline after close
        close(true)
    }
    
    func onClickLogout() {
        // show login dialog
        Twitter.sharedInstance().logOut()
        close(false)
        // remove original view controllers
        UIApplication.sharedApplication().keyWindow?.rootViewController?.view?.removeFromSuperview()
        UIApplication.sharedApplication().keyWindow?.rootViewController?.removeFromParentViewController()
        // show a new login view
        UIApplication.sharedApplication().keyWindow?.rootViewController = LoginViewController()
    }
    
    func close(reload: Bool) {
        // save all settings
        SettingStore.sharedInstance.saveHashtag(self.hashtagInput?.text)
        if let noConfirm = self.noConfirmSwitch {
            SettingStore.sharedInstance.saveNoConfirm(noConfirm.on)
        }
        if reload {
            // set true for reload flag for timeline view
            if let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController as? MainTabViewController {
                viewController.timelineView.needReload = true
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onClickClose() {
        var reload:Bool = false
        if self.hashtagInput?.text != SettingStore.sharedInstance.getHashtag() {
            reload = true
        }
        if let noConfirm = self.noConfirmSwitch {
            if noConfirm.on != SettingStore.sharedInstance.isNoConfirm() {
                reload = true
            }
        }
        close(reload)
    }
}