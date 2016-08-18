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
    
    @IBOutlet weak var SendCommentButton: UIButton!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var CommentText: UITextView!
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    
    
    lazy var jsonForComments: JSON = JSON.null
    lazy var postID : Int = Int()
    var placeholderLabel : UILabel!
    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        CommentText.layer.cornerRadius = 5
        SendCommentButton.layer.cornerRadius = 5
        placeholderLabelText()
        Localizable()
    }
    
    func Localizable() {
        SendCommentButton.setTitle(NSLocalizedString("Send", comment: ""), forState: .Normal)
        NameTextField.placeholder = NSLocalizedString("Enter your name", comment: "")
        EmailTextField.placeholder = NSLocalizedString("Enter your email", comment: "")
        NameLabel.text = NSLocalizedString("Your name:", comment: "")
        EmailLabel.text = NSLocalizedString("Your Email", comment: "")
    }
    
    func placeholderLabelText() {
        CommentText.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("Enter comment", comment: "")
        placeholderLabel.sizeToFit()
        CommentText.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, CommentText.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.hidden = !CommentText.text.isEmpty
    }
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !textView.text.isEmpty
    }
    
    func activityIndicatorView() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
    }

    func getComments() {
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        visualEffectView.frame = (self.navigationController?.view.bounds)!
        visualEffectView.hidden = false

        activityIndicatorView()
        self.view.userInteractionEnabled = false
        
        self.navigationController?.view.addSubview(visualEffectView)
        self.navigationController?.view.addSubview(activityIndicator)
        
        let latestCommentsOriginal: String = userDefaults.stringForKey(sourceUrl as String)!
        let latestComments = String(latestCommentsOriginal.characters.dropLast(21))
        
        var requestString = "\(latestComments)/api/?json=submit_comment&post_id=\(postID)&name=\(NameTextField.text!)&email=\(EmailTextField.text!)&content=\(CommentText.text)"
        requestString = requestString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        Alamofire.request(.POST, requestString, parameters: nil).response {
            request, response, data, error in
            
            print(request)
            print(response)
            print(error)
            
            visualEffectView.hidden = true
            self.view.userInteractionEnabled = true
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.navigationController?.popViewControllerAnimated(true)
            NSNotificationCenter.defaultCenter().postNotificationName("CommentSended", object: nil)
        }
    }
    
    @IBAction func SendComment(sender: AnyObject) {
         if NameTextField.text! != "" && validateEmail(EmailTextField.text!) != false && CommentText.text! != "" {
            getComments()
         } else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Enter text in all required fields", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluateWithObject(enteredEmail)
    }
}

