//
//  SinglePostViewController.swift
//  Keinex
//
//  Created by Андрей on 9/16/15.
//  Copyright (c) 2016Keinex. All rights reserved.
//

import UIKit

class SinglePostViewController: UIViewController, UIWebViewDelegate {

    lazy var json : JSON = JSON.null
    lazy var scrollView : UIScrollView = UIScrollView()
    lazy var postTitle : UILabel = UILabel()
    lazy var featuredImage : UIImageView = UIImageView()
    lazy var postTime : UILabel = UILabel()
    lazy var postContent : UILabel = UILabel()
    lazy var postContentWeb : UIWebView = UIWebView()
    lazy var generalPadding : CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        if let featured = json["better_featured_image"]["source_url"].string{
            
            featuredImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 3)
            featuredImage.contentMode = .ScaleAspectFill
            featuredImage.clipsToBounds = true
            ImageLoader.sharedLoader.imageForUrl(featured, completionHandler:{(image: UIImage?, url: String) in
                self.featuredImage.image = image!
            })
            
            self.scrollView.addSubview(featuredImage)
        }
        
        if let title = json["title"]["rendered"].string {
            
            postTitle.frame = CGRect(x: 40, y: self.view.frame.size.height / 3 + generalPadding * 2, width:self.view.frame.size.width - 20, height: self.view.frame.size.height / 3)
            postTitle.textColor = UIColor.blackColor()
            postTitle.textAlignment = NSTextAlignment.Center
            postTitle.lineBreakMode = NSLineBreakMode.ByWordWrapping
            postTitle.font = UIFont.systemFontOfSize(24.0)
            postTitle.numberOfLines = 3
            postTitle.text = String(htmlEncodedString:  title)
            postTitle.sizeToFit()
            self.scrollView.addSubview(postTitle)
            
        }
        
        if let date = json["date"].string{
            
            postTime.frame = CGRectMake(10, (generalPadding * 2.5 + postTitle.frame.height + featuredImage.frame.height), self.view.frame.size.width - 20, 20)
            postTime.textColor = UIColor.grayColor()
            postTime.font = UIFont(name: postTime.font.fontName, size: 12)
            postTime.textAlignment = NSTextAlignment.Center
            postTime.text = date
            
            self.scrollView.addSubview(postTime)
        }
        
        if let content = json["content"]["rendered"].string{
            
            /*
            postContent.frame = CGRectMake(10, (generalPadding * 2 + postTitle.frame.height + featuredImage.frame.height + postTime.frame.height), self.view.frame.size.width - 20, 1)
            postContent.numberOfLines = 0
            self.scrollView.addSubview(postContent)
            */
            
            let webContent : String = "<!DOCTYPE HTML><html><head><title></title><link rel='stylesheet' href='appStyles.css'></head><body>" + content + "</body></html>"
            let mainbundle = NSBundle.mainBundle().bundlePath
            let bundleURL = NSURL(fileURLWithPath: mainbundle)
        
            
            postContentWeb.loadHTMLString(webContent, baseURL: bundleURL)
            postContentWeb.frame = CGRectMake(10, (generalPadding * 2 + postTitle.frame.height + featuredImage.frame.height + postTime.frame.height), self.view.frame.size.width - 20, 10)
            postContentWeb.delegate = self
            postContent.font = UIFont.systemFontOfSize(16.0)
            postContent.lineBreakMode = NSLineBreakMode.ByWordWrapping
            postContent.text = content
            postContent.sizeToFit()
            self.scrollView.addSubview(postContentWeb)
        }
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(SinglePostViewController.ShareLink))
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    

    
    func webViewDidFinishLoad(webView: UIWebView) {
    
        postContentWeb.frame = CGRectMake(10, (generalPadding * 2 + postTitle.frame.height + featuredImage.frame.height + postTime.frame.height), self.view.frame.size.width - 20, postContentWeb.scrollView.contentSize.height + 150)
        
        var finalHeight : CGFloat = 0
        self.scrollView.subviews.forEach { (subview) -> () in
            finalHeight += subview.frame.height
        }
        
        self.scrollView.contentSize.height = finalHeight
    }
    
    func ShareLink() {
        let textToShare = json["title"]["rendered"].string! + " "
        
        if let myWebsite = NSURL(string: json["link"].string!) {
            let objectsToShare = [String(htmlEncodedString:  textToShare), myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }

    /*
    // MARK: This method fires after all subviews have loaded
    override func viewDidLayoutSubviews() {
        
        //Set variable for final height. Cast it as CGFloat
        var finalHeight : CGFloat = 0
        
        //Loop through all subviews
        self.scrollView.subviews.forEach { (subview) -> () in
            
            //Add each subview height to finalHeight
            finalHeight += subview.frame.height
        }
        
        //Apply final height to scrollview
        self.scrollView.contentSize.height = finalHeight
        
        //NOTE: you maye need to add some padding

    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
