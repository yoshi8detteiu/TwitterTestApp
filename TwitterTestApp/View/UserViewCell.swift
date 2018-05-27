//
//  UserViewCell.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/27.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import UIKit

class UserViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: CircleImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var followCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    
    var pushedLinkButton: ((_ sender:Any) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func pushLinkButton(_ sender: Any) {
        self.pushedLinkButton?(sender)
    }
}
