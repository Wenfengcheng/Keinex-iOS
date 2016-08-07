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

    var latestNews: String = "http://keinex.com/wp-json/wp/v2/posts/"
    let parameters: [String:AnyObject] = ["filter[posts_per_page]" : 50]
    var json : JSON = JSON.null
    let lang = NSLocale.currentLocale().localeIdentifier

    func SourceUrl() -> String {
        if lang == "ru_RU" {
            latestNews = "https://keinex.ru/wp-json/wp/v2/posts/"
        } else {
            latestNews = "http://keinex.com/wp-json/wp/v2/posts/"
        }
        return latestNews
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SourceUrl()
        
        self.title = NSLocalizedString("News", comment: "")
        
        tabBarController?.tabBar.items?[0].title = NSLocalizedString("News", comment: "")
        tabBarController?.tabBar.items?[1].title = NSLocalizedString("Settings", comment: "")
        
        getNews(latestNews)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(LatestNewsTableViewController.newNews), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    func newNews() {
        getNews(latestNews)
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }

    func getNews(getNews : String) {
        Alamofire.request(.GET, getNews, parameters:parameters).responseJSON { response in
            guard let data = response.result.value else {
                print("Request failed with error")
                return
            }
            self.json = JSON(data)
            self.tableView.reloadData()
            
            for index in 1...self.json.count {
                print(self.json[index]["title"]["rendered"])
            }
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
    
    func populateFields(cell: LatestNewsTableViewCell, index: Int){
        
        //Make sure post title is a string
        
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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