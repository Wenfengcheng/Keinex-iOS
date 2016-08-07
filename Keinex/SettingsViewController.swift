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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        VersionLabel.text = version
    }

    @IBOutlet weak var VersionLabel: UILabel!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if (indexPath.section == 0 && indexPath.row == 0) {
            if let deviceInfo = generateDeviceInfo().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                let mc = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.navigationBar.barTintColor = UIColor.mainColor()
                mc.navigationBar.tintColor = UIColor.whiteColor()
                mc.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
                mc.setToRecipients(["info@keinex.info"])
                mc.setSubject("Keinex app")
                mc.addAttachmentData(deviceInfo, mimeType: "text/plain", fileName: "device_information.txt")
                self.presentViewController(mc, animated: true, completion: nil)
            }
        } else if (indexPath.section == 0 && indexPath.row == 1) {
                let openLink = NSURL(string : "https://itunes.apple.com/developer/andrey-baranchikov/id785333926")
                UIApplication.sharedApplication().openURL(openLink!)
        }
    }
    
    func generateDeviceInfo() -> String {
        let device = UIDevice.currentDevice()
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let name = dictionary["CFBundleName"] as! String
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        var deviceInfo = "App Information:\r"
        deviceInfo += "App Name: \(name)\r"
        deviceInfo += "App Version: \(version) (\(build))\r\r"
        
        deviceInfo += "Device Information:\r"
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
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}