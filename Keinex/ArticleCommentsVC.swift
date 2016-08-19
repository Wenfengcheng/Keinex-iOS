//
//  ArticleCommentsVC.swift
//  Keinex
//
//  Created by Андрей on 18.08.16.
//  Copyright © 2016 Keinex. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ArticleCommentsVC: UITableViewController {
    
    lazy var json: JSON = JSON.null
    lazy var indexRow : Int = Int()
    lazy var PostID : Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Comments".localize
        tableView.userInteractionEnabled = false

        getComments()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(newComments), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newComments(_:)), name: "ChangedSource", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(successAlert(_:)), name: "CommentSended", object: nil)
    }
    
    func successAlert(notification: NSNotification) {
        let alert = UIAlertController(title: "Successfully".localize, message: "Your comment has been sent to moderation".localize, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok".localize, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func newComments(notification:NSNotification) {
        getComments()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func getComments() {
        var latestComments = String((userDefaults.stringForKey(sourceUrl as String)!).characters.dropLast(21))
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
                noCommentsLabel.text = "No comments".localize
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
    
    func populateCells(cell: ArticleCommentsCell, index: Int){
        
        guard let commentsContents = self.json["post"]["comments"][index]["content"].string else {
            cell.commentsContent!.text = "Loading...".localize
            return
        }
        
        cell.commentsContent.text = String(encodedString: String(commentsContents))

        guard let commentsName = self.json["post"]["comments"][index]["name"].string else {
            cell.commentsName!.text = "--"
            return
        }
        
        cell.commentsName.text = String(encodedString: String(commentsName))
        
        guard let commentsDate = self.json["post"]["comments"][index]["date"].string else {
            cell.commentsDate!.text = "--"
            return
        }
        
        cell.commentsDate.text = String(encodedString: String(commentsDate))
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ArticleCommentsCell
        
        populateCells(cell, index: indexPath.row)
        
        return cell
    }

}
