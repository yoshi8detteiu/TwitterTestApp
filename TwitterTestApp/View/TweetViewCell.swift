//
//  TweetViewCell.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/26.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import UIKit

class TweetViewCell: UITableViewCell {

    @IBOutlet weak var authorIconImageView: CircleImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    
    var pushedIconButton: ((_ sender: Any) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func pushIconButton(_ sender: Any) {
        self.pushedIconButton?(sender)
    }
    
}
