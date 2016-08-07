//
//  LatestNewsTableViewController.swift
//  Keinex
//
//  Created by Андрей on 7/15/15.
//  Copyright (c) 2016Keinex. All rights reserved.
//

import UIKit
import Alamofire

class LatestNewsTableViewController: UITableViewController {

    let latestNews : String = "http://keinex.com/wp-json/wp/v2/posts/"
    
    let parameters : [String:AnyObject] = [
        "filter[posts_per_page]" : 50
    ]
    
    var json : JSON = JSON.null
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getNews(latestNews)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(LatestNewsTableViewController.newNews), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    func newNews() {
        getNews(latestNews)
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }

    func getNews(getNews : String) {
        Alamofire.request(.GET, getNews, parameters:parameters)
            .responseJSON { response in
                
                guard let data = response.result.value else{
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
                return 5
        }
    }
    
    func populateFields(cell: LatestNewsTableViewCell, index: Int){
        
        //Make sure post title is a string
        
        guard let title = self.json[index]["title"]["rendered"].string else{
            cell.postTitle!.text = "Loading..."
            return
        }
        
        cell.postTitle!.text = String(htmlEncodedString: title)
        
        guard let date = self.json[index]["date"].string else{
            cell.postDate!.text = "--"
            return
        }
        cell.postDate!.text = String(htmlEncodedString: date)
        
        guard let image = self.json[index]["better_featured_image"]["source_url"].string where
        image != "null"
            else{
            
            print("Image didn't load")
            return
        }
    
        ImageLoader.sharedLoader.imageForUrl(image, completionHandler:{(image: UIImage?, url: String) in
            cell.postImage.image = image!
        })
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! LatestNewsTableViewCell

        populateFields(cell, index: indexPath.row)

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let singlePostVC : SinglePostViewController = storyboard!.instantiateViewControllerWithIdentifier("SinglePostViewController") as! SinglePostViewController
        singlePostVC.json = self.json[indexPath.row]
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