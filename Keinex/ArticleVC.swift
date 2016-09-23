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
import Spring

class ArticleVC: UIViewController, UIWebViewDelegate {

    lazy var json : JSON = JSON.null
    lazy var indexRow : Int = Int()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var featuredImage: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var postContentWeb: UIWebView!
    @IBOutlet weak var webContentHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var featuredImageHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var commentsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ArticleVC.changeOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        commentsButton.isHidden = true
        
        if isiPad {
            featuredImageHeightConstant.constant = featuredImageHeightConstant.constant * 1.5
        }
        
        if let featured = json["better_featured_image"]["source_url"].string{
            featuredImage.clipsToBounds = true
            ImageLoader.sharedLoader.imageForUrl(urlString: featured, completionHandler:{(image: UIImage?, url: String) in self.featuredImage.image = image
            })
        }
        
        if let title = json["title"]["rendered"].string {
            postTitle.text = String(encodedString:  title)
        }
        
        if let date = json["date"].string {
            postTime.text = date.replacingOccurrences(of: "T", with: " ", options: NSString.CompareOptions.literal, range: nil)
        }
        
        if let content = json["content"]["rendered"].string {
            
            let webContent : String = "<!DOCTYPE HTML><html><head><title></title><link rel='stylesheet' href='appStyles.css'></head><body>" + content + "</body></html>"
            let mainbundle = Bundle.main.bundlePath
            let bundleURL = URL(fileURLWithPath: mainbundle)
            
            postContentWeb.loadHTMLString(webContent, baseURL: bundleURL)
            postContentWeb.delegate = self
            postContentWeb.scrollView.isScrollEnabled = false
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ArticleVC.ShareLink))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        webContentHeightConstant.constant = postContentWeb.scrollView.contentSize.height
        postContentWeb.layoutIfNeeded()
        
        var finalHeight : CGFloat = 0
        self.scrollView.subviews.forEach { (subview) -> () in
            finalHeight += subview.frame.height
        }
        self.scrollView.contentSize.height = finalHeight
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
    
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
        commentsButton.layer.shadowOffset = CGSize(width: 1, height: 0)
        commentsButton.layer.shadowOpacity = 0.5
        commentsButton.layer.shadowColor = UIColor.black.cgColor
        commentsButton.addTarget(self, action: #selector(commentsButtonAction), for: .touchUpInside)
        commentsButton.isHidden = false
        commentsButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.commentsButton.transform = CGAffineTransform(scaleX: 1,y: 1)
        })
    }
    
    func commentsButtonAction(_ sender: UIButton!) {
        let CommentsVC : ArticleCommentsVC = storyboard!.instantiateViewController(withIdentifier: "ArticleCommentsVC") as! ArticleCommentsVC
        CommentsVC.indexRow = indexRow
        CommentsVC.PostID = self.json["id"].int!
        self.navigationController?.pushViewController(CommentsVC, animated: true)
    }
    
    func ShareLink() {
        let textToShare = json["title"]["rendered"].string! + " "
        
        if let KeinexWebsite = URL(string: json["link"].string!) {
            let objectsToShare = [String(encodedString:  textToShare), KeinexWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.width / 2, y: self.view.frame.height, width: 0, height: 0)
                
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


