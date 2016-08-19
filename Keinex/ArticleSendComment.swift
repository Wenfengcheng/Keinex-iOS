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

class ArticleSendComment: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
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
    let sendingLabel = UILabel(frame: CGRectMake(0, 0, 200, 21))
    var CloseKeyboardButton = UIBarButtonItem()

    override func viewDidLoad() {
        placeholderLabelText()
        Localizable()
        
        NameTextField.delegate = self
        EmailTextField.delegate = self
        CommentText.delegate = self
        CommentText.returnKeyType = .Done
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ArticleSendComment.keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ArticleSendComment.keyboardWillDisappear(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        CloseKeyboardButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(ArticleSendComment.EndEditing))
        self.navigationItem.rightBarButtonItem = CloseKeyboardButton
        CloseKeyboardButton.enabled = false
        CloseKeyboardButton.tintColor = UIColor.clearColor()
    }

    func keyboardWillAppear(notification: NSNotification){
        CloseKeyboardButton.enabled = true
        CloseKeyboardButton.tintColor = UIColor.whiteColor()
        
    }

    func keyboardWillDisappear(notification: NSNotification){
        CloseKeyboardButton.enabled = false
        CloseKeyboardButton.tintColor = UIColor.clearColor()
    }

    func EndEditing() {
        self.view.endEditing(true)
    }
    
    
    
    func Localizable() {
        SendCommentButton.setTitle(NSLocalizedString("Send", comment: ""), forState: .Normal)
        NameTextField.placeholder = NSLocalizedString("Enter your name", comment: "")
        EmailTextField.placeholder = NSLocalizedString("Enter your email", comment: "")
        NameLabel.text = NSLocalizedString("Your name:", comment: "")
        EmailLabel.text = NSLocalizedString("Your Email:", comment: "")
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
        
        sendingLabel.center.y = self.view.center.y - (self.view.frame.height / 4)
        sendingLabel.center.x = self.view.center.x
        sendingLabel.textAlignment = .Center
        sendingLabel.textColor = UIColor.whiteColor()
        sendingLabel.text = NSLocalizedString("Sending..", comment: "")
        sendingLabel.font = UIFont.systemFontOfSize(20)
    }

    func getComments() {
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        visualEffectView.frame = (self.navigationController?.view.bounds)!
        visualEffectView.hidden = false

        activityIndicatorView()
        self.view.userInteractionEnabled = false
        
        self.navigationController?.view.addSubview(visualEffectView)
        self.navigationController?.view.addSubview(activityIndicator)
        self.navigationController?.view.addSubview(sendingLabel)

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
            self.sendingLabel.removeFromSuperview()
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == NameTextField {
            EmailTextField.becomeFirstResponder()
        } else if textField == EmailTextField {
            CommentText.becomeFirstResponder()
        }
        return true
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluateWithObject(enteredEmail)
    }
}

