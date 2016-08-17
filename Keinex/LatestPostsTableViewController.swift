//
//  LatestNewsTableViewController.swift
//  Keinex
//
//  Created by Андрей on 7/15/15.
//  Copyright (c) 2016 Keinex. All rights reserved.
//

import UIKit
import Alamofire

class LatestNewsTableViewController: UITableViewController {

    var parameters: [String:AnyObject] = ["filter[posts_per_page]" : 10]
    var json : JSON = JSON.null

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getNews()
        
        self.title = NSLocalizedString("News", comment: "")
        tabBarController?.tabBar.items?[0].title = NSLocalizedString("News", comment: "")
        tabBarController?.tabBar.items?[1].title = NSLocalizedString("Settings", comment: "")
        tableView.userInteractionEnabled = false

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(newNews), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newNews(_:)), name: "ChangedSource", object: nil)
    }

    func newNews(notification:NSNotification) {
        getNews()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
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
        let postCount:Float = userDefaults.floatForKey("postCount")

        parameters = ["filter[posts_per_page]" : postCount]
        print(postCount)
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
        switch self.json.type {
            case Type.Array:
                return self.json.count
            default:
                return 10
        }
    }
    
    // MARK: Load cells data from site
    
    func populateFields(cell: LatestNewsTableViewCell, index: Int){
        
        guard let title = self.json[index]["title"]["rendered"].string else{
            cell.postTitle!.text = NSLocalizedString("Loading...", comment: "")
            return
        }
        
        cell.postTitle!.text = String(htmlEncodedString: title)
        
        guard let date = self.json[index]["date"].string else {
            cell.postDate!.text = "--"
            return
        }

        cell.postDate!.text = date.stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        guard let image = self.json[index]["better_featured_image"]["source_url"].string where
        image != "null" else {
            print("Image didn't load")
            return
        }
    
        ImageLoader.sharedLoader.imageForUrl(image, completionHandler:{(image: UIImage?, url: String) in
            cell.postImage.image = image
        })
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! LatestNewsTableViewCell

        populateFields(cell, index: indexPath.row)

        return cell
    }
    
    // MARK: - Navigation
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let singlePostVC : SinglePostViewController = storyboard!.instantiateViewControllerWithIdentifier("SinglePostViewController") as! SinglePostViewController
        singlePostVC.json = self.json[indexPath.row]
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.pushViewController(singlePostVC, animated: true)
    }
}


extension String {
    init(htmlEncodedString: String) {
        do {
            let encodedData = htmlEncodedString.dataUsingEncoding(NSUTF8StringEncoding)!
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