//
//  LatestNewsTableViewCell.swift
//  Keinex
//
//  Created by Андрей on 7/15/15.
//  Copyright (c) 2016 Keinex. All rights reserved.
//

import UIKit

class ArticleCommentsCell: UITableViewCell {
    
    @IBOutlet weak var commentsContent: UILabel!
    @IBOutlet weak var commentsName: UILabel!
    @IBOutlet weak var commentsDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentsContent.sizeToFit()
        commentsName.sizeToFit()
        commentsDate.sizeToFit()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
