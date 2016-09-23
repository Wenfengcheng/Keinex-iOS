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
    
    lazy var postID : Int = Int()
    var placeholderLabel : UILabel!
    var activityIndicator = UIActivityIndicatorView()
    let sendingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    var CloseKeyboardButton = UIBarButtonItem()
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    override func viewDidLoad() {
        placeholderLabelText()
        Localizable()
        
        NameTextField.delegate = self
        EmailTextField.delegate = self
        CommentText.delegate = self
        CommentText.returnKeyType = .done
        
        NotificationCenter.default.addObserver(self, selector:#selector(ArticleSendComment.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ArticleSendComment.keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        CloseKeyboardButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ArticleSendComment.EndEditing))
        CloseKeyboardButton.tintColor = UIColor.clear
        self.navigationItem.rightBarButtonItem = CloseKeyboardButton
    }

    func keyboardWillAppear(_ notification: Notification){
        CloseKeyboardButton.tintColor = UIColor.white
    }

    func keyboardWillDisappear(_ notification: Notification){
        CloseKeyboardButton.tintColor = UIColor.clear
    }

    func EndEditing() {
        self.view.endEditing(true)
    }
    
    func Localizable() {
        SendCommentButton.setTitle("Send".localize, for: UIControlState())
        NameTextField.placeholder = "Enter your name".localize
        EmailTextField.placeholder = "Enter your email".localize
        NameLabel.text = "Your name:".localize
        EmailLabel.text = "Your Email:".localize
    }
    
    func placeholderLabelText() {
        CommentText.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter comment".localize
        placeholderLabel.sizeToFit()
        CommentText.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 10, y: CommentText.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.isHidden = !CommentText.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func activityIndicatorView() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        
        sendingLabel.center.y = self.view.center.y - (self.view.frame.height / 4)
        sendingLabel.center.x = self.view.center.x
        sendingLabel.textAlignment = .center
        sendingLabel.textColor = UIColor.white
        sendingLabel.text = "Sending..".localize
        sendingLabel.font = UIFont.systemFont(ofSize: 20)
    }

    func getComments() {
        
        visualEffectView.frame = (self.navigationController?.view.bounds)!
        visualEffectView.isHidden = false

        activityIndicatorView()
        self.view.isUserInteractionEnabled = false
        
        self.navigationController?.view.addSubview(visualEffectView)
        self.navigationController?.view.addSubview(activityIndicator)
        self.navigationController?.view.addSubview(sendingLabel)

        let latestCommentsOriginal: String = userDefaults.string(forKey: sourceUrl as String)!
        let latestComments = String(latestCommentsOriginal.characters.dropLast(21))
        
        var requestString = "\(latestComments)/api/?json=submit_comment&post_id=\(postID)&name=\(NameTextField.text!)&email=\(EmailTextField.text!)&content=\(CommentText.text)"
        requestString = requestString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        Alamofire.request(requestString, method: .post).response { response in
            debugPrint(response)
            self.view.isUserInteractionEnabled = true
            self.visualEffectView.isHidden = true
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.sendingLabel.removeFromSuperview()
            
            self.navigationController!.popViewController(animated: true)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "CommentSended"), object: nil)
        }
    }
    
    @IBAction func SendComment(_ sender: AnyObject) {
         if NameTextField.text! != "" && validateEmail(EmailTextField.text!) != false && CommentText.text! != "" {
            getComments()
         } else {
            let alert = UIAlertController(title: "Error".localize, message: "Enter text in all required fields".localize, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok".localize, style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == NameTextField {
            EmailTextField.becomeFirstResponder()
        } else if textField == EmailTextField {
            CommentText.becomeFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func validateEmail(_ enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
}

