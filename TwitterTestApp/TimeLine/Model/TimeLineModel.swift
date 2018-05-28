//
//  TimeLineModel.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/26.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import Foundation
import Vision
import Speech

class TimeLineModel: NSObject {
    
    private var isLoading = false
    private var noMore = false
    
    func loadTimeLine(_ afterAction:@escaping (Array<TweetModel>) -> Void, _ errorAction:@escaping (String) -> Void) {
        
        if self.isLoading { return }
        
        let afterTask:((Array<TweetModel>) -> Void) = { [weak self] twArray in
            afterAction(twArray)
            self?.isLoading = false
        }
        
        let errorTask:((String) -> Void) = { [weak self] message in
            errorAction(message)
            self?.isLoading = false
        }
        
        // ログインチェック
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        if let session = sessionStore.session() {
            self.isLoading = true
            TwitterAPIUtil.requestHomeTimeLine(session.userID, "", afterTask, errorTask)
            return
        }
        
        // 初回ログイン
        TWTRTwitter.sharedInstance().logIn { session, error in
            if let session = session {
                self.isLoading = true
                TwitterAPIUtil.requestHomeTimeLine(session.userID, "", afterTask, errorTask)
            }
            else if let error = error {
                print("error: \(error.localizedDescription)")
                errorAction("ログインに失敗しました")
            }
        }
    }
    
    func logout() {
 
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        
        // アクティブなアカウントのsessionを取得
        if let session = sessionStore.session() {
            // userIDでログアウト
            sessionStore.logOutUserID(session.userID)
        }
    }
    
    func isLogin() -> Bool {
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        return sessionStore.session() != nil
    }
    
    func moreTimeLine(_ maxId:String, _ afterAction:@escaping (Array<TweetModel>) -> Void, _ errorAction:@escaping (String) -> Void) {
        
        if self.isLoading || self.noMore { return }
        
        let afterTask:((Array<TweetModel>) -> Void) = { [weak self] twArray in
            self?.isLoading = false
            // maxIdのtweetも混ざるので削除
            var twArray = twArray
            twArray.remove(at: 0)
            if twArray.count > 0  {
                afterAction(twArray)
            }
            else {
                // 古いツイートはないので打止
                // MEMO: 投稿や更新後にfalseにすべき
                self?.noMore = true
            }
        }
        
        let errorTask:((String) -> Void) = { [weak self] message in
            self?.isLoading = false
            errorAction(message)
        }
        
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        if let session = sessionStore.session() {
            self.isLoading = true
            TwitterAPIUtil.requestHomeTimeLine(session.userID, maxId, afterTask, errorTask)
        }
        else {
            errorAction("再ログインしてください")
        }
    }
    
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
    

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func startRecording(_ recognizingAction:@escaping (String) -> Void, _ finishAction:@escaping () -> Void, _ errorAction:@escaping (Error) -> Void) throws {

        //refreshTask
        if let rTask = self.recognitionTask {
            rTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        // 録音用のカテゴリをセット
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let rRequest = self.recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // 録音が完了する前のリクエストを作るかどうかのフラグ。
        // trueだと現在-1回目のリクエスト結果が返ってくる模様。falseだとボタンをオフにしたときに音声認識の結果が返ってくる設定。
        self.recognitionRequest?.shouldReportPartialResults = true
        
        self.recognitionTask = self.speechRecognizer.recognitionTask(with: rRequest) { [weak self] result, error in

            var isFinal = false
            
            if let result = result {
                let resultText = result.bestTranscription.formattedString
                recognizingAction(resultText)
                isFinal = result.isFinal
            }
            else if let error = error {
                errorAction(error)
            }
            
            if isFinal {
                finishAction()
            }
            
            // エラーがある、もしくは最後の認識結果だった場合の処理
            if error != nil || isFinal {
                self?.audioEngine.stop()
                self?.audioEngine.inputNode.removeTap(onBus: 0)
                
                self?.recognitionRequest = nil
                self?.recognitionTask = nil
                
                self?.audioEngine.stop()
                self?.recognitionRequest?.endAudio()
            }
        }
        
        // マイクから取得した音声バッファをリクエストに渡す
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        self.audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self?.recognitionRequest?.append(buffer)
        }
        
        // startの前にリソースを確保しておく。
        self.audioEngine.prepare()
        try self.audioEngine.start()
    }
    
    func stopRecording() {
        
        if self.audioEngine.isRunning {
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
        }
    }
    
}
