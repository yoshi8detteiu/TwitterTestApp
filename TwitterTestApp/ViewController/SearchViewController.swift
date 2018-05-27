//
//  SearchViewController.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/27.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import UIKit
import Vision

class SearchViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: LambdaTableView!
    
    private var model:SearchModel = SearchModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //空白行のラインを消す
        self.tableView.tableFooterView = UIView()
        // カメラロール起動
        let c = UIImagePickerController()
        c.delegate = self
        present(c, animated: true)
    }
    
    /** UIImagePickerControllerDelegate - キャンセルボタンを押された時に呼ばれる */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    /** UIImagePickerControllerDelegate - 写真が選択された時に呼ばれる */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.model.analyzeImage(image!, {idtext in
            // 解析結果をNavigationTitleへ
            self.navigationItem.title = idtext
            self.loadTimeLineView(idtext)
        })
        
        //閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func loadTimeLineView(_ text: String) {
        self.model.searchTweets(text,
            {[weak self] twArray in
                self?.loadTableView(twArray)
            },
            { message in
                //TODO: アラート
        })
    }
    
    private func loadTableView(_ twArray: Array<TweetModel>) {
        
        self.tableView.register(TweetViewCell.self, forCellReuseIdentifier: "TweetViewCell")
        self.tableView.register(UINib(nibName: "TweetViewCell", bundle: nil), forCellReuseIdentifier: "TweetViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.dataSourceNumberOfRowsInSection = {section in
            return twArray.count
        }
        
        self.tableView.dataSourceNumberOfSections = {
            return 1
        }
        
        self.tableView.delegateHeightRowAt = { indexPath in
            return  UITableViewAutomaticDimension
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
                // タップされたユーザのページへ
                let storyboard: UIStoryboard = UIStoryboard(name: "UserPageViewController", bundle: nil)
                let nextView  = storyboard.instantiateInitialViewController() as! UserPageViewController
                nextView.user = tweet.authorModel
                self?.navigationController?.pushViewController(nextView, animated: true)
            }
            cell.layoutIfNeeded()
            return cell
        }
        
        self.tableView.reloadData()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
