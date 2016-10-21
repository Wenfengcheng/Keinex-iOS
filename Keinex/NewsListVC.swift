//
//  NewsListVC.swift
//  Keinex
//
//  Created by Андрей on 7/15/15.
//  Copyright (c) 2016 Keinex. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LatestNewsTableViewController: UITableViewController {

    var parameters: [String:AnyObject] = ["filter[posts_per_page]" : 50 as AnyObject]
    var json : JSON = JSON.null
    let screenSize:CGRect = UIScreen.main.bounds
    let networkWarning = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterface()
        getNews()
    }
    
    func loadInterface() {
        self.title = "News".localize
        tableView.isUserInteractionEnabled = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(LatestNewsTableViewController.newNews), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(LatestNewsTableViewController.newNews), name: NSNotification.Name(rawValue: "ChangedSource"), object: nil)
        
        if Network.isConnectedToNetwork() == false {
            failedToConnect()
            tableView.isUserInteractionEnabled = true
        }
    }

    func newNews() {
        if Network.isConnectedToNetwork() == true {
            getNews()
        } else {
            failedToConnect()
        }
        
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func showWarning() {
        UIView.animate(withDuration: 1.0, delay: 1.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                UIView.animate(withDuration: 1.0, animations: {
                    self.networkWarning.frame = CGRect(x: 0, y: self.screenSize.height * 0.125, width: self.screenSize.width * 0.8, height: 50)
                    self.networkWarning.center.x = self.view.center.x
                    self.networkWarning.translatesAutoresizingMaskIntoConstraints = false
                })
            }, completion: {
                (value: Bool) in
                
                let delayTime = (Int64(NSEC_PER_SEC) * 3)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(delayTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                self.hideWarning()
            })
        })
    }
    
    func hideWarning() {
        UIView.animate(withDuration: 1.0, animations: {
            self.networkWarning.frame = CGRect(x: 0, y: -500, width: self.screenSize.width * 0.8, height: 0)
            self.networkWarning.center.x = self.view.center.x
        })
    }
    
    func failedToConnect() {
        networkWarning.frame = CGRect(x: 0, y: -500, width: screenSize.width * 0.8, height: 0)
        networkWarning.backgroundColor = UIColor.warningColor()
        networkWarning.layer.cornerRadius = 15
        networkWarning.center.x = self.view.center.x
        networkWarning.layer.shadowOffset = CGSize(width: 1, height: 0)
        networkWarning.layer.shadowOpacity = 0.5
        networkWarning.layer.shadowColor = UIColor.black.cgColor
        
        self.navigationController!.view.addSubview(networkWarning)
        
        let warningLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        warningLabel.textColor = UIColor.white
        warningLabel.center.x = self.view.center.x
        warningLabel.text = "Failed to connect".localize
        networkWarning.addSubview(warningLabel)
        
        let delayTime = Int64(NSEC_PER_SEC) * 1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(delayTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.showWarning()
        })
    }
    
    func getNews() {
        let latestNews: String = userDefaults.string(forKey: sourceUrl as String)!
        
        Alamofire.request(latestNews, method: .get, parameters: parameters).responseJSON { response in
            guard let data = response.result.value else {
                print("Request failed with error. Url: \(latestNews)")
                return
            }
            
            self.json = JSON(data)
            self.tableView.isUserInteractionEnabled = true
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Network.isConnectedToNetwork() == true {
            switch self.json.type {
                case Type.array:
                    return self.json.count
                default:
                    return 50
            }
        } else {
            return 0
        }
    }
    
    // MARK: Load cells data from site
    
    func populateFields(_ cell: NewsListTableViewCell, index: Int){
        
        
        guard let title = self.json[index]["title"]["rendered"].string else {
            cell.postTitle!.text = "Loading...".localize
            return
        }
        
        cell.postTitle!.text = String(encodedString: title)
 
        
        guard let date = self.json[index]["date"].string else {
            cell.postDate!.text = "--"
            return
        }

        cell.postDate!.text = date.replacingOccurrences(of: "T", with: " ", options: NSString.CompareOptions.literal, range: nil)
        
        guard let image = self.json[index]["better_featured_image"]["source_url"].string, image != "null" else {
            print("Image didn't load")
            return
        }

        ImageLoader.sharedLoader.imageForUrl(urlString: image) { [weak self] image, url in
            if self != nil {
                DispatchQueue.main.async(execute: { () -> Void in
                    cell.postImage.image = image
                })
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsListTableViewCell

        populateFields(cell, index: (indexPath as NSIndexPath).row)

        return cell
    }
    
    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let PostVC : ArticleVC = storyboard!.instantiateViewController(withIdentifier: "ArticleVC") as! ArticleVC
        PostVC.json = self.json[(indexPath as NSIndexPath).row]
        PostVC.indexRow = (indexPath as NSIndexPath).row;
        self.navigationController?.pushViewController(PostVC, animated: true)
    }
}

extension String {
    init(encodedString: String) {
        self.init()
        guard let encodedData = encodedString.data(using: .utf8) else {
            self = encodedString
            return
        }
        
        let attributedOptions: [String : Any] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
        ]
        
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            self = attributedString.string
        } catch {
            print("Error: \(error)")
            self = encodedString
        }
    }
}
