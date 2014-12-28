//
//  TwitterAPI.swift
//  test
//
//  Created by TEJIMA TAKUYA on 2014/12/24.
//  Copyright (c) 2014年 TEJIMA TAKUYA. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterAPI {
    let baseURL = "https://api.twitter.com"
    let version = "/1.1"
    
    init() {
    }
    
    class func getHomeTimeline(tweets: [TWTRTweet]->(), error: (NSError) -> ()) {
        self.callAPI("/statuses/home_timeline.json", parameters: nil, {
            response, data, err in
            if err == nil {
                var jsonError: NSError?
                let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,
                    options: nil,
                    error: &jsonError)
                if let jsonArray = json as? NSArray {
                    tweets(TWTRTweet.tweetsWithJSONArray(jsonArray) as [TWTRTweet])
                }
            } else {
                error(err)
            }
        })
    }
    
    class func callAPI(path: String, parameters: [NSObject : AnyObject]!, completion: TWTRNetworkCompletion!){
        let api = TwitterAPI()
        var clientError: NSError?
        let endpoint = api.baseURL + api.version + path
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: endpoint, parameters: parameters, error: &clientError)
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: completion)
        }
    }
}