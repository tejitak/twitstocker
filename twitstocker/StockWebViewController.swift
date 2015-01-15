//
//  StockWebViewController.swift
//  twitstocker
//
//  Created by TEJIMA TAKUYA on 2015/01/15.
//  Copyright (c) 2015年 Takuya Tejima. All rights reserved.
//

import Foundation
import UIKit

class StockWebViewController : UIViewController, UIWebViewDelegate, UIActionSheetDelegate {
    
    var webView: UIWebView = UIWebView()
    var toolBar: UIToolbar = UIToolbar()
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var refreshButton: UIBarButtonItem!
    var safariButton: UIBarButtonItem!
    var url : NSURL?
    let toolBarHeight: CGFloat = 50.0
    
    override init() {
        super.init(nibName: nil, bundle: nil)
        let selfFrame: CGRect = self.view.frame
        self.webView.frame = CGRect(x: 0, y: 0, width: selfFrame.size.width, height: selfFrame.size.height-toolBarHeight)
        self.webView.delegate = self
        self.view.addSubview(self.webView)
        self.toolBar.frame = CGRect(x: 0, y: selfFrame.size.height - toolBarHeight, width: selfFrame.size.width, height: toolBarHeight)
        self.toolBar.backgroundColor = Constants.Theme.base()
        self.toolBar.tintColor = Constants.Theme.twitter()
        self.view.addSubview(self.toolBar)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        self.backButton = UIBarButtonItem(image: UIImage(named: "toolbar_back"), style: .Plain, target: self, action: Selector("back"))
        self.forwardButton = UIBarButtonItem(image: UIImage(named: "toolbar_forward"), style: .Plain, target: self, action: Selector("forward"))
        self.refreshButton = UIBarButtonItem(image: UIImage(named: "toolbar_reload"), style: .Plain, target: self, action: Selector("reload"))
        self.safariButton = UIBarButtonItem(image: UIImage(named: "toolbar_external"), style: .Plain, target: self, action: Selector("safari"))
        let items: NSArray = [spacer, self.backButton, spacer, self.forwardButton, spacer, self.refreshButton, spacer, self.safariButton, spacer]
        self.toolBar.items = items
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton.enabled = self.webView.canGoBack
        self.forwardButton.enabled = self.webView.canGoForward
        self.refreshButton.enabled = false
        self.safariButton.enabled = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.makeToastActivity()
        let requestURL: NSURLRequest = NSURLRequest(URL: self.url!)
        self.webView.loadRequest(requestURL)
    }
    
    func back() {
        self.webView.goBack()
        self.backButton.enabled = self.webView.canGoBack
        self.forwardButton.enabled = self.webView.canGoForward
    }
    
    func forward() {
        self.webView.goForward()
        self.backButton.enabled = self.webView.canGoBack
        self.forwardButton.enabled = self.webView.canGoForward
    }
    
    func reload() {
        self.view.makeToastActivity()
        self.webView.reload()
    }
    
    func safari() {
        if self.osVersion() >= 8.0 {
            self.alertController()
        } else {
            self.actionSheet()
        }
    }
    
    func alertController() {
        let actionSheet: UIAlertController = UIAlertController(title: "", message: NSLocalizedString("webview_toolbar_open_in", comment: ""), preferredStyle: .ActionSheet)
        let otherAction1: UIAlertAction = UIAlertAction(title: NSLocalizedString("webview_toolbar_safari", comment: ""), style: UIAlertActionStyle.Default, handler: { action1 in
            if let req = self.webView.request? {
                let url: NSURL = req.URL
                UIApplication.sharedApplication().openURL(url)
            }
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("common_cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: { cancel in })
        actionSheet.addAction(otherAction1)
        actionSheet.addAction(cancelAction)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func actionSheet() {
        let actionSheet: UIActionSheet = UIActionSheet()
        actionSheet.title = NSLocalizedString("webview_toolbar_open_in", comment: "")
        actionSheet.delegate = self
        actionSheet.addButtonWithTitle(NSLocalizedString("webview_toolbar_safari", comment: ""))
        actionSheet.addButtonWithTitle(NSLocalizedString("common_cancel", comment: ""))
        actionSheet.cancelButtonIndex = 1
        actionSheet.showFromToolbar(self.toolBar)
    }
    
    func actionSheet(myActionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        switch (buttonIndex) {
        case 0:
            if let req = self.webView.request? {
                let url: NSURL = req.URL
                UIApplication.sharedApplication().openURL(url)
            }
            break
        default:
            break
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        self.backButton.enabled = self.webView.canGoBack
        self.forwardButton.enabled = self.webView.canGoForward
        self.refreshButton.enabled = true
        self.safariButton.enabled = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        self.view.hideToastActivity()
        self.backButton.enabled = self.webView.canGoBack
        self.forwardButton.enabled = self.webView.canGoForward
    }
    
    func osVersion() -> Double {
        return NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
    }
}