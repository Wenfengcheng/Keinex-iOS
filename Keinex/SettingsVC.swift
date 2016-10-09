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
    @IBOutlet weak var ClearCacheLabel: UILabel!
    @IBOutlet weak var CacheSizeNumber: UILabel!
    @IBOutlet weak var ClearCacheOnExitLabel: UILabel!
    @IBOutlet weak var ClearCacheSwitch: UISwitch!
    
    let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
    var cacheSize = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings".localize
        SourceLabel.text = "Source:".localize
        SourceUrl.text = SourceUrlText()
        SupportLabel.text = "Support".localize
        OurAppsLabel.text = "Our apps".localize
        VersionLabel.text = "Version:".localize
        ClearCacheLabel.text = "Clear cache:".localize
        ClearCacheOnExitLabel.text = "Clear cache on exit:".localize
        VersionNumber.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        ClearCacheSwitch.addTarget(self, action: #selector(SettingsViewController.clearCacheSwitchState), for: UIControlEvents.valueChanged)
        ClearCacheSwitch.onTintColor = UIColor.mainColor()
        
        if userDefaults.string(forKey: autoDelCache as String)! == "onClose" {
            ClearCacheSwitch.setOn(true, animated: true);
        }
    }
    
    func clearCacheSwitchState() {
        if ClearCacheSwitch.isOn {
            userDefaults.set("onClose", forKey: autoDelCache as String)
            userDefaults.synchronize()
        } else {
            userDefaults.set("none", forKey: autoDelCache as String)
            userDefaults.synchronize()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        CacheSizeNumber.text = "\(Double(round(100 * DetectCacheSize()) / 100)) " + "Mb".localize
    }
    
    @IBAction func CloseButtonAction(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func SourceUrlText() -> String {
        if userDefaults.string(forKey: sourceUrl as String)! == sourceUrlKeinexRu as String {
            SourceUrl.text = "keinex.ru"
        } else {
            SourceUrl.text = "keinex.com"
        }
        return SourceUrl.text!
    }
    
    func DetectCacheSize() -> Double {
        let cacheFiles = FileManager.default.subpaths(atPath: cachePath!)
        
        for i in cacheFiles! {
            let path = cachePath!.appendingFormat("/\(i)")
            let folder = try! FileManager.default.attributesOfItem(atPath: path)
            for (sizeBase, sizeNew) in folder {
                if sizeBase == FileAttributeKey.size {
                    cacheSize += (sizeNew as AnyObject).doubleValue
                }
            }
        }
        
        return cacheSize / (1024 * 1024)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if ((indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0) {
            let sourceSelector: UIAlertController = UIAlertController(title: "Select source".localize, message: nil, preferredStyle: .actionSheet)

            let cancelActionButton = UIAlertAction(title: "Cancel".localize, style: .cancel) { action -> Void in
            }
            
            let setKeinexComButton = UIAlertAction(title: "keinex.com", style: .default) { action -> Void in
                userDefaults.set(String(sourceUrlKeinexCom), forKey: sourceUrl as String)
                userDefaults.synchronize()
                self.SourceUrl.text = self.SourceUrlText()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ChangedSource"), object: nil)
            }
            
            let setKeinexRuButton = UIAlertAction(title: "keinex.ru", style: .default) { action -> Void in
                userDefaults.set(String(sourceUrlKeinexRu), forKey: sourceUrl as String)
                userDefaults.synchronize()
                self.SourceUrl.text = self.SourceUrlText()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ChangedSource"), object: nil)
            }
            
            sourceSelector.addAction(cancelActionButton)
            sourceSelector.addAction(setKeinexComButton)
            sourceSelector.addAction(setKeinexRuButton)
            sourceSelector.view.tintColor = UIColor.mainColor()
            
            if let popoverController = sourceSelector.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.frame.width / 2, y: self.SupportLabel.frame.height * 2, width: 0, height: 0)
            }
            
            self.present(sourceSelector, animated: true, completion: nil)
            
        } else if ((indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0) {
            
            let alert = UIAlertController(title: "Clear cache?".localize, message: "Cache size:".localize + " \(CacheSizeNumber.text!)", preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "Cancel".localize, style: UIAlertActionStyle.cancel) { Void in
            }
            
            let confimAction = UIAlertAction(title: "Clear".localize, style: UIAlertActionStyle.destructive) { (alertConfirm) -> Void in
                self.deleteCache()
                self.CacheSizeNumber.text = "0.0 " + "Mb".localize
            }
            
            alert.addAction(confimAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        
        } else if ((indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0) {
            if let deviceInfo = generateDeviceInfo().data(using: String.Encoding.utf8,allowLossyConversion: false) {
                let mc = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.navigationBar.tintColor = UIColor.mainColor()
                mc.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.mainColor()]
                mc.setToRecipients(["info@keinex.info"])
                mc.setSubject("Keinex app")
                mc.addAttachmentData(deviceInfo, mimeType: "text/plain", fileName: "device_information.txt")
                self.present(mc, animated: true, completion: nil)
            }
            
        } else if ((indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 1) {
            let openLink = URL(string : "https://itunes.apple.com/developer/andrey-baranchikov/id785333926")
            UIApplication.shared.openURL(openLink!)
        }
    }
    
    func deleteCache() {
        let cacheFiles = FileManager.default.subpaths(atPath: cachePath!)

        for i in cacheFiles! {
            let path = self.cachePath!.appendingFormat("/\(i)")
            if (FileManager.default.fileExists(atPath: path)) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
    
    func generateDeviceInfo() -> String {
        let device = UIDevice.current
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        
        var deviceInfo = "App Version: \(version)\r\r"
        deviceInfo += "Device: \(deviceName())\r"
        deviceInfo += "iOS Version: \(device.systemVersion)\r"
        deviceInfo += "Timezone: \(TimeZone.autoupdatingCurrent.identifier) (\(NSTimeZone.local.abbreviation()!))\r\r"
    
        return deviceInfo
    }
    
    func deviceName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return 2
        } else if (section == 2) {
            return 3
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Reading".localize
        } else if (section == 1) {
            return "Cache".localize
        } else if (section == 2) {
            return "Other".localize
        } else {
            return ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
