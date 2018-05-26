//
//  TwitterAPIUtil.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/26.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import Foundation

class TwitterAPIUtil: NSObject {
    
    static func requestHomeTimeLine(_ userId: String, _ afterAction:@escaping (Array<TWTRTweet>) -> Void, _ errorAction:@escaping (String) -> Void) {
        
        var clientError: NSError?
        
        let apiClient = TWTRAPIClient(userID: userId)
        let request = apiClient.urlRequest(withMethod: "GET",
                                           urlString: "https://api.twitter.com/1.1/statuses/home_timeline.json",
                                           parameters: ["user_id": userId,
                                                        "count": "50",], // Intで渡すとエラー
            error: &clientError)
        
        
        apiClient.sendTwitterRequest(request) { response, data, error in
            if let error = error {
                print(error.localizedDescription)
                errorAction("リクエストに失敗しました")
            }
            else if let data = data {
                let tweetArray = TwitterAPIUtil.convertTweet(data)
                afterAction(tweetArray)
            }
        }
    }
    
    private static func convertTweet(_ data: Data) -> Array<TWTRTweet> {
        
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as! Array<Any>
            let twArray = TWTRTweet.tweets(withJSONArray: jsonArray) as! [TWTRTweet]
            return twArray
        }
        catch let jsonError as NSError {
            print("json error: \(jsonError.localizedDescription)")
        }
        return Array<TWTRTweet>()
    }
    
    
}
