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

    @IBOutlet weak var tableView: LambdaTableView!
    @IBOutlet weak var tweetButton: UIButton!
    
    private let model:TimeLineModel = TimeLineModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //空白行のラインを消す
        self.tableView.tableFooterView = UIView()
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(hex: 0x1DA1F2)
        refreshControl.addTarget(self, action: #selector(TimeLineViewController.refreshControlValueChanged(sender:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
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
            
            cell.authorIconImageView.af_setImage(withURL: URL(string: tweet.authorModel.base!.profileImageURL)!)
            
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
            if distanceToBottom < 100 {
                // TODO: 無限スクロール
//                self?.moreTimeLineView(twArray)
            }
        }
        
        self.tableView.reloadData()
    }
    
    private func moreTimeLineView(_ oldTwArray: Array<TweetModel>) {
        
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
            { message in
                //TODO: アラート
        })
    }
    
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        self.loadTimeLineView()
        // ローディングを終了
        sender.endRefreshing()
    }
    
    @IBAction func pushMoreButton(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let search = UIAlertAction(title: "画像から検索", style: UIAlertActionStyle.default, handler: {[weak self] (action: UIAlertAction!) in
            // カメラロール起動
            let c = UIImagePickerController()
            c.delegate = self
            self?.present(c, animated: true)
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
        
        
        actionSheet.addAction(search)
        if (self.model.isLogin()) {
            actionSheet.addAction(logout)
        }
        else {
            actionSheet.addAction(login)
        }
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }

    /** UIImagePickerControllerDelegate - キャンセルボタンを押された時に呼ばれる */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    /** UIImagePickerControllerDelegate - 写真が選択された時に呼ばれる */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
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
    
    private func showAlert(_ message:String) {
        let alert = UIAlertController(title: "エラーです", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let close = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
            
        })
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pushTweetButton(_ sender: Any) {
        let composer = TWTRComposer()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

