//
//  SearchModel.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/27.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import Foundation

class SearchModel: NSObject {
    
    func searchTweets(_ text: String, _ afterAction:@escaping (Array<TweetModel>) -> Void, _ errorAction:@escaping (String) -> Void) {
        
        // ログインチェック
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        if let session = sessionStore.session() {
            TwitterAPIUtil.requestSearch(session.userID,
                                         text,
                                         "",
                                         {twArray in afterAction(twArray)},
                                         errorAction)
            return
        }
        
        // 初回ログイン
        TWTRTwitter.sharedInstance().logIn { session, error in
            if let session = session {
                TwitterAPIUtil.requestSearch(session.userID,
                                             text,
                                             "",
                                             {twArray in afterAction(twArray)},
                                             errorAction)
            }
            else if let error = error {
                print("error: \(error.localizedDescription)")
                errorAction("ログインに失敗しました")
            }
        }
    }

}
