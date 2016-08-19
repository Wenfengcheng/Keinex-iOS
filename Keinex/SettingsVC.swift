//
//  SettingsViewController.swift
//  Keinex
//
//  Created by Андрей on 07.08.16.
//  Copyright © 2016 Keinex. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import SafariServices

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var SupportLabel: UILabel!
    @IBOutlet weak var OurAppsLabel: UILabel!
    @IBOutlet weak var VersionLabel: UILabel!
    @IBOutlet weak var VersionNumber: UILabel!    
    @IBOutlet weak var SourceLabel: UILabel!
    @IBOutlet weak var SourceUrl: UILabel!
    @IBOutlet weak var DeleteCacheLabel: UILabel!
    @IBOutlet weak var CacheSizeNumber: UILabel!
    
    let cachePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
    var cacheSize = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings".localize
        SourceLabel.text = "Source:".localize
        SourceUrl.text = SourceUrlText()
        SupportLabel.text = "Support".localize
        OurAppsLabel.text = "Our apps".localize
        VersionLabel.text = "Version:".localize
        DeleteCacheLabel.text = "Delete cache:".localize
        VersionNumber.text = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
    }

    override func viewDidAppear(animated: Bool) {
        CacheSizeNumber.text = "\(Double(round(100*DetectCacheSize())/100)) " + "Mb".localize
    }
    
    @IBAction func CloseButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func SourceUrlText() -> String {
        if userDefaults.stringForKey(sourceUrl as String)! == sourceUrlKeinexRu {
            SourceUrl.text = "keinex.ru"
        } else {
            SourceUrl.text = "keinex.com"
        }
        return SourceUrl.text!
    }
    
    func DetectCacheSize() -> Double {
        let cacheFiles = NSFileManager.defaultManager().subpathsAtPath(cachePath!)
        
        for i in cacheFiles! {
            let path = cachePath!.stringByAppendingFormat("/\(i)")
            let folder = try! NSFileManager.defaultManager().attributesOfItemAtPath(path)
            for (sizeBase, sizeNew) in folder {
                if sizeBase == NSFileSize {
                    cacheSize += sizeNew.doubleValue
                }
            }
        }
        return cacheSize/(1024*1024)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if (indexPath.section == 0 && indexPath.row == 0) {
            let sourceSelector: UIAlertController = UIAlertController(title: "Select source".localize, message: nil, preferredStyle: .ActionSheet)
            
            let cancelActionButton = UIAlertAction(title: "Cancel".localize, style: .Cancel) { action -> Void in
            }
            
            let setKeinexComButton = UIAlertAction(title: "keinex.com", style: .Default) { action -> Void in
                userDefaults.setObject(String(sourceUrlKeinexCom), forKey: sourceUrl as String)
                self.SourceUrl.text = self.SourceUrlText()
                NSNotificationCenter.defaultCenter().postNotificationName("ChangedSource", object: nil)
            }
            
            let setKeinexRuButton = UIAlertAction(title: "keinex.ru", style: .Default) { action -> Void in
                userDefaults.setObject(String(sourceUrlKeinexRu), forKey: sourceUrl as String)
                self.SourceUrl.text = self.SourceUrlText()
                NSNotificationCenter.defaultCenter().postNotificationName("ChangedSource", object: nil)
            }
            
            sourceSelector.addAction(cancelActionButton)
            sourceSelector.addAction(setKeinexComButton)
            sourceSelector.addAction(setKeinexRuButton)
            
            if let popoverController = sourceSelector.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.frame.width / 2, y: self.SupportLabel.frame.height * 2, width: 0, height: 0)
            }
            
            self.presentViewController(sourceSelector, animated: true, completion: nil)
            
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            if let deviceInfo = generateDeviceInfo().dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: false) {
                let mc = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.navigationBar.tintColor = UIColor.mainColor()
                mc.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.mainColor()]
                mc.setToRecipients(["info@keinex.info"])
                mc.setSubject("Keinex app")
                mc.addAttachmentData(deviceInfo, mimeType: "text/plain", fileName: "device_information.txt")
                self.presentViewController(mc, animated: true, completion: nil)
            }
            
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            let openLink = NSURL(string : "https://itunes.apple.com/developer/andrey-baranchikov/id785333926")
            UIApplication.sharedApplication().openURL(openLink!)
            
        } else if (indexPath.section == 1 && indexPath.row == 3) {
            let cacheFiles = NSFileManager.defaultManager().subpathsAtPath(cachePath!)
            
            let alert = UIAlertController(title: "Delete cache?".localize, message: "Cache size:".localize + " \(CacheSizeNumber.text!)", preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel".localize, style: UIAlertActionStyle.Cancel) { Void in }
            let confimAction = UIAlertAction(title: "Delete".localize, style: UIAlertActionStyle.Destructive) { (alertConfirm) -> Void in
                for i in cacheFiles! {
                    let path = self.cachePath!.stringByAppendingFormat("/\(i)")
                    if(NSFileManager.defaultManager().fileExistsAtPath(path)) {
                        do {
                            try NSFileManager.defaultManager().removeItemAtPath(path)
                        } catch let error as NSError {
                            print(error)
                        }
                        self.CacheSizeNumber.text = "0.0 " + "Mb".localize
                    }
                }
            }
            
            alert.addAction(confimAction)
            alert.addAction(cancelAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func generateDeviceInfo() -> String {
        let device = UIDevice.currentDevice()
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        
        var deviceInfo = "App Version: \(version)\r\r"
        deviceInfo += "Device: \(deviceName())\r"
        deviceInfo += "iOS Version: \(device.systemVersion)\r"
        deviceInfo += "Timezone: \(NSTimeZone.localTimeZone().name) (\(NSTimeZone.localTimeZone().abbreviation!))\r\r"
    
        return deviceInfo
    }
    
    func deviceName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return 4
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Reading".localize
        } else {
            return "Other".localize
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}