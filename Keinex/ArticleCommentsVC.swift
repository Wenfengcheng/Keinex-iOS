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
        tableView.isUserInteractionEnabled = false

        getComments()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(newComments), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(newComments(_:)), name: NSNotification.Name(rawValue: "ChangedSource"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(successAlert(_:)), name: NSNotification.Name(rawValue: "CommentSended"), object: nil)
    }
    
    func successAlert(_ notification: Notification) {
        let alert = UIAlertController(title: "Successfully".localize, message: "Your comment has been sent to moderation".localize, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok".localize, style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func newComments(_ notification:Notification) {
        getComments()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func getComments() {
        var latestComments = String((userDefaults.string(forKey: sourceUrl as String)!).characters.dropLast(21))
        latestComments.append("/api/get_post/?post_id=\(PostID)")
        
        Alamofire.request(latestComments, method: .get).responseJSON { response in
            guard let data = response.result.value else {
                print("Request failed with error")
                return
            }

            self.json = JSON(data)
            self.tableView.isUserInteractionEnabled = true
            self.tableView.reloadData()
            let addCommentButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ArticleCommentsVC.addCommentButtonAction))
            self.navigationItem.rightBarButtonItem = addCommentButton
            
            if self.json["post"]["comment_count"].int == 0 {
                let noCommentsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                noCommentsLabel.center.y = self.view.center.y - (self.view.frame.height / 4)
                noCommentsLabel.center.x = self.view.center.x
                noCommentsLabel.textAlignment = .center
                noCommentsLabel.text = "No comments".localize
                self.tableView.separatorColor = UIColor.clear
                self.view.addSubview(noCommentsLabel)
            }
        }
    }
    
    func addCommentButtonAction(_ sender: UIButton!) {
        let SendCommentVC = storyboard!.instantiateViewController(withIdentifier: "ArticleSendComment") as! ArticleSendComment
        SendCommentVC.postID = PostID
        self.navigationController?.pushViewController(SendCommentVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let commentsCount = self.json["post"]["comment_count"].int
  
        switch self.json.type {
        case Type.dictionary:
            return commentsCount!
        default:
            return 1
        }
    }
    
    // MARK: Load cells data from site
    
    func populateCells(_ cell: ArticleCommentsCell, index: Int){
        
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ArticleCommentsCell
        
        populateCells(cell, index: (indexPath as NSIndexPath).row)
        
        return cell
    }

}
