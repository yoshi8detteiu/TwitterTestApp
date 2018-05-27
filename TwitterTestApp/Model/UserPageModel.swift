//
//  UserPageModel.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/27.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import Foundation

class UserPageModel: NSObject {
    
    func loadUserTimeLine(_ userId:String, _ afterAction:@escaping (Array<TweetModel>) -> Void, _ errorAction:@escaping (String) -> Void) {
        
        // ログインチェック
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        if let session = sessionStore.session() {
            TwitterAPIUtil.requestUserTimeLine(session.userID, userId,{twArray in
                afterAction(twArray)
            }, errorAction)
            return
        }
        
        // 初回ログイン
        TWTRTwitter.sharedInstance().logIn { session, error in
            if let session = session {
                TwitterAPIUtil.requestUserTimeLine(session.userID,userId, {twArray in
                    afterAction(twArray)
                }, errorAction)
            }
            else if let error = error {
                print("error: \(error.localizedDescription)")
                errorAction("ログインに失敗しました")
            }
        }
    }
}
