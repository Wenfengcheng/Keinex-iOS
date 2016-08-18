//
//  LatestNewsTableViewCell.swift
//  Keinex
//
//  Created by Андрей on 7/15/15.
//  Copyright (c) 2016 Keinex. All rights reserved.
//

import UIKit

class NewsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postTitle.sizeToFit()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
