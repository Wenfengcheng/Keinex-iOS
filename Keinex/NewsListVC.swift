//
//  LatestNewsTableViewController.swift
//  Keinex
//
//  Created by Андрей on 7/15/15.
//  Copyright (c) 2016 Keinex. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LatestNewsTableViewController: UITableViewController {

    var parameters: [String:AnyObject] = ["filter[posts_per_page]" : 10]
    var json : JSON = JSON.null
    let screenSize:CGRect = UIScreen.mainScreen().bounds
    let networkWarning = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getNews()
        
        self.title = "News".localize
        tableView.userInteractionEnabled = false

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(newNews), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newNews(_:)), name: "ChangedSource", object: nil)
        
        if Network.isConnectedToNetwork() == false {
            failedToConnect()
            tableView.userInteractionEnabled = true
        }
    }

    func newNews(notification:NSNotification) {
        if Network.isConnectedToNetwork() == true {
            getNews()
            self.tableView.reloadData()
        } else {
            failedToConnect()
        }
        refreshControl?.endRefreshing()
    }
    
    func showWarning() {
        UIView.animateWithDuration(1.0, delay: 1.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                UIView.animateWithDuration(1.0, animations: {
                    self.networkWarning.frame = CGRect(x: 0, y: self.screenSize.height * 0.125, width: self.screenSize.width * 0.8, height: 50)
                    self.networkWarning.center.x = self.view.center.x
                    self.networkWarning.translatesAutoresizingMaskIntoConstraints = false
                })
            }, completion: {
                (value: Bool) in
                
                let delayTime = (Int64(NSEC_PER_SEC) * 3)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTime), dispatch_get_main_queue(), { () -> Void in
                self.hideWarning()
            })
        })
    }
    
    func hideWarning() {
        UIView.animateWithDuration(1.0, animations: {
            self.networkWarning.frame = CGRect(x: 0, y: -500, width: self.screenSize.width * 0.8, height: 0)
            self.networkWarning.center.x = self.view.center.x
        })
    }
    
    func failedToConnect() {
        networkWarning.frame = CGRect(x: 0, y: -500, width: screenSize.width * 0.8, height: 0)
        networkWarning.backgroundColor = UIColor.warningColor()
        networkWarning.layer.cornerRadius = 15
        networkWarning.center.x = self.view.center.x
        networkWarning.layer.shadowOffset = CGSizeMake(1, 0)
        networkWarning.layer.shadowOpacity = 0.5
        networkWarning.layer.shadowColor = UIColor.blackColor().CGColor
        
        self.navigationController!.view.addSubview(networkWarning)
        
        let warningLabel = UILabel(frame: CGRectMake(0, 0, 200, 50))
        warningLabel.textColor = UIColor.whiteColor()
        warningLabel.center.x = self.view.center.x
        warningLabel.text = "Failed to connect".localize
        networkWarning.addSubview(warningLabel)
        
        let delayTime = Int64(NSEC_PER_SEC) * 1
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTime), dispatch_get_main_queue(), { () -> Void in
            self.showWarning()
        })
    }
    
    func getNews() {
        let latestNews: String = userDefaults.stringForKey(sourceUrl as String)!
        Alamofire.request(.GET, latestNews, parameters:parameters).responseJSON { response in
            guard let data = response.result.value else {
                print("Request failed with error")
                return
            }
            self.json = JSON(data)
            self.tableView.userInteractionEnabled = true
            self.loadMoreNews()

            //Check new post
            let latestPostTitle = userDefaults.stringForKey("postValue")
            if latestPostTitle == String(self.json[0]["title"]["rendered"]) {
                print("Latest post is latest")
            } else {
                print("Latest post is different")
                userDefaults.setObject(String(self.json[0]["title"]["rendered"]), forKey: latestPostValue)
            }
            self.tableView.reloadData()
        }
    }
    
    func loadMoreNews() {
        let latestNews: String = userDefaults.stringForKey(sourceUrl as String)!

        parameters = ["filter[posts_per_page]" : 50]
        Alamofire.request(.GET, latestNews, parameters:parameters).responseJSON { response in
            guard let data = response.result.value else {
                print("Request failed with error")
                return
            }
            self.json = JSON(data)
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Network.isConnectedToNetwork() == true {
            switch self.json.type {
                case Type.Array:
                    return self.json.count
                default:
                    return 10
            }
        } else {
            return 0
        }
    }
    
    // MARK: Load cells data from site
    
    func populateFields(cell: NewsListTableViewCell, index: Int){
        
        guard let title = self.json[index]["title"]["rendered"].string else{
            cell.postTitle!.text = "Loading...".localize
            return
        }
        
        cell.postTitle!.text = String(encodedString: title)
        
        guard let date = self.json[index]["date"].string else {
            cell.postDate!.text = "--"
            return
        }

        cell.postDate!.text = date.stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        guard let image = self.json[index]["better_featured_image"]["media_details"]["sizes"]["themo_blog_standard"]["source_url"].string where
        image != "null" else {
            print("Image didn't load")
            return
        }
    
        ImageLoader.sharedLoader.imageForUrl(image, completionHandler:{(image: UIImage?, url: String) in
            cell.postImage.image = image
        })
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! NewsListTableViewCell

        populateFields(cell, index: indexPath.row)

        return cell
    }
    
    // MARK: - Navigation
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let PostVC : ArticleVC = storyboard!.instantiateViewControllerWithIdentifier("ArticleVC") as! ArticleVC
        PostVC.json = self.json[indexPath.row]
        PostVC.indexRow = indexPath.row;
        self.navigationController?.pushViewController(PostVC, animated: true)
    }
}

extension String {
    init(encodedString: String) {
        do {
            let encodedData = encodedString.dataUsingEncoding(NSUTF8StringEncoding)!
            let attributedOptions : [String: AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
            ]
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            self.init(attributedString.string)
        } catch {
            fatalError("Unhandled error: \(error)")
        }
    }
}