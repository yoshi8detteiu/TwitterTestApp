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
    
    var searchText:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //空白行のラインを消す
        self.tableView.tableFooterView = UIView()
        // 検索対象をNavigationTitleへ
        self.navigationItem.title = self.searchText
        // RefreshControlのセット
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(hex: 0x1DA1F2)
        refreshControl.addTarget(self, action: #selector(TimeLineViewController.refreshControlValueChanged(sender:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadSearchView()
    }
    
    private func loadSearchView() {
        
        self.model.searchTweets(self.searchText,
                                {[weak self] twArray in
                                    self?.loadTableView(twArray)
                                },
                                {[weak self] message in
                                    self?.showAlert(message)
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
    
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        self.loadSearchView()
        // ローディングを終了
        sender.endRefreshing()
    }

    private func showAlert(_ message:String) {
        let alert = UIAlertController(title: "エラーです", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let close = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
            
        })
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
