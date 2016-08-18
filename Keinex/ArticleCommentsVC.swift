//
//  ArticleCommentsVC.swift
//  Keinex
//
//  Created by Андрей on 18.08.16.
//  Copyright © 2016 Keinex. All rights reserved.
//

import UIKit
import Alamofire

class ArticleCommentsVC: UITableViewController {
    
    lazy var jsonForComments: JSON = JSON.null
    lazy var indexRow : Int = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getComments()
        
        self.title = NSLocalizedString("Comments", comment: "")
        tableView.userInteractionEnabled = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(newComments), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newComments(_:)), name: "ChangedSource", object: nil)
    }
    
    func newComments(notification:NSNotification) {
        getComments()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func getComments() {
        let latestCommentsOriginal: String = userDefaults.stringForKey(sourceUrl as String)!
        var latestComments = String(latestCommentsOriginal.characters.dropLast(21))
        latestComments.appendContentsOf("/?json=1")
        
        Alamofire.request(.GET, latestComments).responseJSON { response in
            guard let data = response.result.value else {
                print("Request failed with error")
                return
            }
            self.jsonForComments = JSON(data)
            self.tableView.userInteractionEnabled = true
            self.tableView.reloadData()
            let addCommentButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ArticleCommentsVC.addCommentButtonAction))
            self.navigationItem.rightBarButtonItem = addCommentButton
        }
    }
    
    func addCommentButtonAction(sender: UIButton!) {
        let postID = self.jsonForComments["posts"][self.indexRow]["id"].int
        let SendCommentVC : ArticleSendComment = storyboard!.instantiateViewControllerWithIdentifier("ArticleSendComment") as! ArticleSendComment
        SendCommentVC.postID = postID!
        self.navigationController?.pushViewController(SendCommentVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let commentsCount = self.jsonForComments["posts"][self.indexRow]["comment_count"].int

        switch self.jsonForComments.type {
        case Type.Dictionary:
            return Int(commentsCount!)
        default:
            return 1
        }
    }
    
    // MARK: Load cells data from site
    
    func populateFields(cell: ArticleCommentsCell, index: Int){
        
        guard let commentsContents = self.jsonForComments["posts"][self.indexRow]["comments"][index]["content"].string else {
            cell.commentsContent!.text = NSLocalizedString("Loading...", comment: "")
            return
        }
        
        cell.commentsContent.text = String(htmlEncodedString: String(commentsContents))

        guard let commentsName = self.jsonForComments["posts"][self.indexRow]["comments"][index]["name"].string else {
            cell.commentsName!.text = NSLocalizedString("--", comment: "")
            return
        }
        
        cell.commentsName.text = String(htmlEncodedString: String(commentsName))
        
        guard let commentsDate = self.jsonForComments["posts"][self.indexRow]["comments"][index]["date"].string else {
            cell.commentsDate!.text = NSLocalizedString("--", comment: "")
            return
        }
        
        cell.commentsDate.text = String(htmlEncodedString: String(commentsDate))
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ArticleCommentsCell
        
        populateFields(cell, index: indexPath.row)
        
        return cell
    }

}
