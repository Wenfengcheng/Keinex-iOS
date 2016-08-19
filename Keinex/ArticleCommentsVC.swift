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
    
    lazy var json: JSON = JSON.null
    lazy var indexRow : Int = Int()
    lazy var PostID : Int = Int()
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(successAlert(_:)), name: "CommentSended", object: nil)
    }
    
    func successAlert(notification: NSNotification) {
        let alert = UIAlertController(title: NSLocalizedString("Successfully", comment: ""), message: NSLocalizedString("Your comment has been sent to moderation", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func newComments(notification:NSNotification) {
        getComments()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func getComments() {
        let latestCommentsOriginal: String = userDefaults.stringForKey(sourceUrl as String)!
        var latestComments = String(latestCommentsOriginal.characters.dropLast(21))
        //latestComments.appendContentsOf("/?json=1")
        latestComments.appendContentsOf("/api/get_post/?post_id=\(PostID)")
        
        Alamofire.request(.GET, latestComments).responseJSON { response in
            guard let data = response.result.value else {
                print("Request failed with error")
                return
            }
            self.json = JSON(data)
            self.tableView.userInteractionEnabled = true
            self.tableView.reloadData()
            let addCommentButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ArticleCommentsVC.addCommentButtonAction))
            self.navigationItem.rightBarButtonItem = addCommentButton
            
            if self.json["post"]["comment_count"].int == 0 {
                let noCommentsLabel = UILabel(frame: CGRectMake(0, 0, 200, 21))
                noCommentsLabel.center.y = self.view.center.y - (self.view.frame.height / 4)
                noCommentsLabel.center.x = self.view.center.x
                noCommentsLabel.textAlignment = .Center
                noCommentsLabel.text = NSLocalizedString("No comments", comment: "")
                self.tableView.separatorColor = UIColor.clearColor()
                self.view.addSubview(noCommentsLabel)
            }
        }
    }
    
    func addCommentButtonAction(sender: UIButton!) {
        let SendCommentVC = storyboard!.instantiateViewControllerWithIdentifier("ArticleSendComment") as! ArticleSendComment
        SendCommentVC.postID = PostID
        self.navigationController?.pushViewController(SendCommentVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let commentsCount = self.json["post"]["comment_count"].int
  
        switch self.json.type {
        case Type.Dictionary:
            return commentsCount!
        default:
            return 1
        }
    }
    
    // MARK: Load cells data from site
    
    func populateFields(cell: ArticleCommentsCell, index: Int){
        
        guard let commentsContents = self.json["post"]["comments"][index]["content"].string else {
            cell.commentsContent!.text = NSLocalizedString("Loading...", comment: "")
            return
        }
        
        cell.commentsContent.text = String(encodedString: String(commentsContents))

        guard let commentsName = self.json["post"]["comments"][index]["name"].string else {
            cell.commentsName!.text = NSLocalizedString("--", comment: "")
            return
        }
        
        cell.commentsName.text = String(encodedString: String(commentsName))
        
        guard let commentsDate = self.json["post"]["comments"][index]["date"].string else {
            cell.commentsDate!.text = NSLocalizedString("--", comment: "")
            return
        }
        
        cell.commentsDate.text = String(encodedString: String(commentsDate))
 
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ArticleCommentsCell
        
        populateFields(cell, index: indexPath.row)
        
        return cell
    }

}
