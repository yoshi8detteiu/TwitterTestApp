//
//  SearchModel.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/27.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import Foundation
import Vision

class SearchModel: NSObject {
    
    func analyzeImage(_ image:UIImage, _ afterAction:@escaping (String) -> Void) {
        
        // MobileNet(MLModel) を VNCoreMLModelに変換
        guard let coreMLModel = try? VNCoreMLModel(for: MobileNet().model) else { return }
        
        let request = VNCoreMLRequest(model: coreMLModel) { request, error in
            // results は confidence の高い（そのオブジェクトである可能性が高い）
            // 順番に sort された Array で返ってきます
            guard let results = request.results as? [VNClassificationObservation] else { return }
            
            if let classification = results.first {
                let idtext = classification.identifier
                afterAction(idtext)
            }
        }
        
        // UIImage -> CIImage
        guard let ciImage = CIImage(image: image) else { return }
        
        // VNImageRequestHandlerを作成し、performを実行
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        guard (try? handler.perform([request])) != nil else { return }
    }
    
    
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
