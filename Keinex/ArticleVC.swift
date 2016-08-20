//
//  ArticleVC.swift
//  Keinex
//
//  Created by Андрей on 9/16/15.
//  Copyright (c) 2016 Keinex. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ArticleVC: UIViewController, UIWebViewDelegate {

    lazy var json : JSON = JSON.null
    lazy var indexRow : Int = Int()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var featuredImage: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var postContentWeb: UIWebView!
    @IBOutlet weak var webContentHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var commentsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ArticleVC.changeOrientation), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        commentsButton.hidden = true
        
        if let featured = json["better_featured_image"]["source_url"].string{
            featuredImage.clipsToBounds = true
            ImageLoader.sharedLoader.imageForUrl(featured, completionHandler:{(image: UIImage?, url: String) in
                self.featuredImage.image = image
            })
        }
        
        if let title = json["title"]["rendered"].string {
            postTitle.text = String(encodedString:  title)
        }
        
        if let date = json["date"].string {
            postTime.text = date.stringByReplacingOccurrencesOfString("T", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        
        if let content = json["content"]["rendered"].string {
            
            let webContent : String = "<!DOCTYPE HTML><html><head><title></title><link rel='stylesheet' href='appStyles.css'></head><body>" + content + "</body></html>"
            let mainbundle = NSBundle.mainBundle().bundlePath
            let bundleURL = NSURL(fileURLWithPath: mainbundle)
            
            postContentWeb.loadHTMLString(webContent, baseURL: bundleURL)
            postContentWeb.delegate = self
            postContentWeb.scrollView.scrollEnabled = false
        }
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(ArticleVC.ShareLink))
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
    
        webContentHeightConstant.constant = postContentWeb.scrollView.contentSize.height
        postContentWeb.layoutIfNeeded()

        var finalHeight : CGFloat = 0
        self.scrollView.subviews.forEach { (subview) -> () in
            finalHeight += subview.frame.height
        }
        self.scrollView.contentSize.height = finalHeight
            
        showCommentsButton()
    }
    
    func changeOrientation() {
        webContentHeightConstant.constant = postContentWeb.scrollView.contentSize.height
        postContentWeb.layoutIfNeeded()
        
        var finalHeight : CGFloat = 0
        self.scrollView.subviews.forEach { (subview) -> () in
            finalHeight += subview.frame.height
        }
        self.scrollView.contentSize.height = finalHeight
    }
 
    func showCommentsButton() {
        commentsButton.layer.cornerRadius = 25
        commentsButton.layer.shadowOffset = CGSizeMake(1, 0)
        commentsButton.layer.shadowOpacity = 1.0
        commentsButton.layer.shadowColor = UIColor.mainColor().CGColor
        commentsButton.addTarget(self, action: #selector(commentsButtonAction), forControlEvents: .TouchUpInside)
        commentsButton.hidden = false
        commentsButton.transform = CGAffineTransformMakeScale(0.0, 0.0)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.commentsButton.transform = CGAffineTransformMakeScale(1,1)
        })
    }
    
    func commentsButtonAction(sender: UIButton!) {
        let CommentsVC : ArticleCommentsVC = storyboard!.instantiateViewControllerWithIdentifier("ArticleCommentsVC") as! ArticleCommentsVC
        CommentsVC.indexRow = indexRow
        CommentsVC.PostID = self.json["id"].int!
        self.navigationController?.pushViewController(CommentsVC, animated: true)
    }
    
    func ShareLink() {
        let textToShare = json["title"]["rendered"].string! + " "
        
        if let KeinexWebsite = NSURL(string: json["link"].string!) {
            let objectsToShare = [String(encodedString:  textToShare), KeinexWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.width / 2, y: self.view.frame.height, width: 0, height: 0)
                
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


