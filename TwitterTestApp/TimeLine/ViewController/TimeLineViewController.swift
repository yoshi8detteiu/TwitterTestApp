//
//  ViewController.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/25.
//  Copyright © 2018年 椎名陽介. All rights reserved.
//

import UIKit
import AlamofireImage

class TimeLineViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /** View */
    @IBOutlet weak var tableView: LambdaTableView!
    @IBOutlet weak var tweetButton: UIButton!
    private var speechRecognizingView: SpeechRecognizingView!
    /** Model */
    private let model:TimeLineModel = TimeLineModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //空白行のラインを消す
        self.tableView.tableFooterView = UIView()
        // 引張更新
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(hex: 0x1DA1F2)
        refreshControl.addTarget(self, action: #selector(TimeLineViewController.refreshControlValueChanged(sender:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        // 録音時View
        let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.speechRecognizingView = SpeechRecognizingView(frame: rect)
        self.navigationController?.view.addSubview(self.speechRecognizingView)
        self.speechRecognizingView.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadTimeLineView()
        
        // Tweetボタンの出現
        self.tweetButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: { [weak self] in
                            self?.tweetButton.transform = CGAffineTransform.identity
                        },
                       completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pushMoreButton(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let searchCamera = UIAlertAction(title: "カメラ画像を使って検索", style: UIAlertActionStyle.default, handler: {[weak self] (action: UIAlertAction!) in
            #if (!arch(i386) && !arch(x86_64))
            // カメラロール起動
            let iCtrler = UIImagePickerController()
            iCtrler.sourceType = UIImagePickerControllerSourceType.camera
            iCtrler.delegate = self
            self?.present(iCtrler, animated: true)
            #else
            self?.showAlert("シミュレータなので使えません...\nライブラリ画像を使用してください")
            #endif
        })
        let searchPhoto = UIAlertAction(title: "ライブラリ画像を使って検索", style: UIAlertActionStyle.default, handler: {[weak self] (action: UIAlertAction!) in
            // カメラロール起動
            let iCtrler = UIImagePickerController()
            iCtrler.sourceType = UIImagePickerControllerSourceType.photoLibrary
            iCtrler.delegate = self
            self?.present(iCtrler, animated: true)
        })
        let speech = UIAlertAction(title: "音声入力でTweet", style: UIAlertActionStyle.default, handler: {[weak self] (action: UIAlertAction!) in
            self?.showSpeecingView()
        })
        let logout = UIAlertAction(title: "ログアウト", style: UIAlertActionStyle.destructive, handler: {[weak self] (action: UIAlertAction!) in
            self?.model.logout()
            // ログアウト後に再ログイン
            self?.loadTimeLineView()
        })
        let login = UIAlertAction(title: "ログイン", style: UIAlertActionStyle.default, handler: {[weak self] (action: UIAlertAction!) in
            self?.loadTimeLineView()
        })
        let cancel = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
            
        })
        
        actionSheet.addAction(searchCamera)
        actionSheet.addAction(searchPhoto)
        actionSheet.addAction(speech)
        if (self.model.isLogin()) {
            actionSheet.addAction(logout)
        }
        else {
            actionSheet.addAction(login)
        }
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    @IBAction func pushTweetButton(_ sender: Any) {
        self.showTweetEntry(nil)
    }
    
    /** UIImagePickerControllerDelegate */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // キャンセルボタンを押された時に呼ばれる
        
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //写真が選択された時に呼ばれる
        
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.model.analyzeImage(image!, {[weak self] idtext in
            let storyboard: UIStoryboard = UIStoryboard(name: "SearchViewController", bundle: nil)
            let nextView  = storyboard.instantiateInitialViewController() as! SearchViewController
            nextView.searchText = idtext
            self?.navigationController?.pushViewController(nextView, animated: true)
        })
        
        //閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    /** RefreshControl event */
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        self.loadTimeLineView()
        // ローディングを終了
        sender.endRefreshing()
    }

    /** Load view */
    private func loadTimeLineView() {
        self.model.loadTimeLine({[weak self] twArray in
                                    self?.loadTableView(twArray)
                                },
                                {[weak self] message in
                                    self?.showAlert(message)
                                })
    }
    private func loadTableView(_ twArray: Array<TweetModel>) {
        
        self.tableView.register(TweetViewCell.self, forCellReuseIdentifier: "TweetViewCell")
        self.tableView.register(UINib(nibName: "TweetViewCell", bundle: nil), forCellReuseIdentifier: "TweetViewCell")
        
        self.tableView.dataSourceNumberOfRowsInSection = {section in
            return twArray.count
        }
        self.tableView.dataSourceNumberOfSections = {
            return 1
        }
        self.tableView.delegateHeightRowAt = { indexPath in
            return  UITableViewAutomaticDimension
        }
        self.tableView.delegateEstimatedHeightForRowAt = { indexPath in
            return 100
        }
        self.tableView.delegateEditingStyleForRowAt = { indexPath in
            return UITableViewCellEditingStyle.none
        }
        
        self.tableView.dataSourceCellForRowAt = {[weak self] indexPath in
            let cell = self?.tableView.dequeueReusableCell(withIdentifier: "TweetViewCell", for: indexPath) as! TweetViewCell
            
            let tweet = twArray[indexPath.row]
            cell.tweetLabel.text      = tweet.base?.text
            cell.authorNameLabel.text = tweet.authorModel.base!.name
            cell.screenNameLabel.text = "@" + tweet.authorModel.base!.screenName
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d日 H:mm"
            formatter.locale = Locale(identifier: "ja_JP")
            cell.dateLabel.text = formatter.string(from: tweet.base!.createdAt)
            
            cell.authorIconImageView.af_setImage(withURL: URL(string: tweet.authorModel.base!.profileImageURL)!,
                                                 placeholderImage: UIImage(named: "placeholder_oval"),
                                                 imageTransition: UIImageView.ImageTransition.crossDissolve(0.1))
            
            cell.pushedIconButton = {[weak self] sender in
                self?.presentUserPage(tweet)
            }
            cell.layoutIfNeeded()
            return cell
        }
        
        self.tableView.delegateScrollDidScroll = { [weak self] in

            let currentOffsetY = (self?.tableView.contentOffset.y)!
            let maximumOffset = (self?.tableView.contentSize.height)! - (self?.tableView.frame.height)!
            let distanceToBottom = maximumOffset - currentOffsetY
            if distanceToBottom < 300 {
                // 無限スクロール
                self?.moreTimeLineView(twArray)
            }
        }
        
        self.tableView.reloadData()
    }
    private func moreTimeLineView(_ oldTwArray: Array<TweetModel>) {
        
        if oldTwArray.count == 0 { return}
        
        let maxId = oldTwArray.last?.base?.tweetID
        self.model.moreTimeLine(maxId!,
            {[weak self] twArray in
                let newTwArray = oldTwArray + twArray
                // reloadDataでoffsetがリセットされないように
                let offset = self?.tableView.contentOffset
                self?.loadTableView(newTwArray)
                self?.tableView.layoutIfNeeded()
                self?.tableView.contentOffset = offset!
            },
            {[weak self] message in
                self?.showAlert(message)
            })
    }

    private func showAlert(_ message:String) {
        let alert = UIAlertController(title: "エラーです", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let close = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
            
        })
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
    private func showSpeecingView() {
        
        var speechText = ""
        do {
            try self.model.startRecording(
            { text in
                /* recording */
                speechText = text
            },
            {[weak self] in
                /* finished */
                self?.model.stopRecording()
                self?.speechRecognizingView.show(false)
            },
            {[weak self] error in
                print("error: \(error.localizedDescription)")
                if speechText.isEmpty {
                    self?.speechRecognizingView.isHidden = true
                    self?.showAlert("失敗しました")
                }
            })
        }
        catch let error as NSError {
            print("error: \(error.localizedDescription)")
            self.speechRecognizingView.isHidden = true
            self.showAlert("失敗しました")
        }
        
        self.speechRecognizingView.show(true)
        
        var isFinished = false
        
        self.speechRecognizingView.pushedFinishButton = {[weak self] sender in
            isFinished = true
            self?.model.stopRecording()
            self?.speechRecognizingView.show(false)
            self?.showTweetEntry(speechText)
        }
        
        // 10秒後に終了
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            if isFinished { return }
            
            self?.model.stopRecording()
            self?.speechRecognizingView.show(false)
            self?.showTweetEntry(speechText)
        }
    }
    private func showTweetEntry(_ text:String?) {
        
        let composer = TWTRComposer()
        
        if let text = text {
            composer.setText(text)
        }
        
        composer.show(from:self, completion: {[weak self] result in
            if result == TWTRComposerResult.done {
                self?.loadTimeLineView()
            }
        })
    }
    private func presentUserPage(_ tweet:TweetModel) {
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: { [weak self] in
                           self?.tweetButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                       },
                       completion: {  [weak self] result in
                            // タップされたユーザのページへ
                            let storyboard: UIStoryboard = UIStoryboard(name: "UserPageViewController", bundle: nil)
                            let nextView  = storyboard.instantiateInitialViewController() as! UserPageViewController
                            nextView.user = tweet.authorModel
                            self?.navigationController?.pushViewController(nextView, animated: true)
                      })
    }
    
}

