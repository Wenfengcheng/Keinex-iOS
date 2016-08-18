//
//  ArticleSendComment.swift
//  Keinex
//
//  Created by Андрей on 18.08.16.
//  Copyright © 2016 Keinex. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ArticleSendComment: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var WebsiteTextField: UITextField!
    @IBOutlet weak var CommentText: UITextView!
    
    lazy var jsonForComments: JSON = JSON.null
    lazy var postID : Int = Int()
    var placeholderLabel : UILabel!
    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        
        CommentText.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter comment"
        placeholderLabel.sizeToFit()
        CommentText.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, CommentText.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.hidden = !CommentText.text.isEmpty
    }
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !textView.text.isEmpty
    }

    func getComments() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        visualEffectView.frame = (self.navigationController?.view.bounds)!
        visualEffectView.hidden = false
        self.navigationController?.view.addSubview(visualEffectView)
        self.navigationController?.view.addSubview(activityIndicator)
        self.view.userInteractionEnabled = false
        
        let latestCommentsOriginal: String = userDefaults.stringForKey(sourceUrl as String)!
        var latestComments = String(latestCommentsOriginal.characters.dropLast(21))
        latestComments.appendContentsOf("/?json=1")
        
        var requestString = "http://keinex.com/api/?json=submit_comment&post_id=\(postID)&name=\(NameTextField.text!)&email=\(EmailTextField.text!)&content=\(CommentText.text)"
        requestString = requestString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        Alamofire.request(.POST, requestString, parameters: nil).response {
            request, response, data, error in
                visualEffectView.hidden = true
                self.view.userInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func SendComment(sender: AnyObject) {
         if NameTextField.text! != "" && validateEmail(EmailTextField.text!) != false && CommentText.text! != "" {
            getComments()
         } else {
            let alert = UIAlertController(title: "Error", message: "Enter text in all required fields", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func validateEmail(enteredEmail:String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluateWithObject(enteredEmail)
        
    }
}

