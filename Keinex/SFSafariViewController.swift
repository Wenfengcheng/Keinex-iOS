//
//  SFSafariViewController.swift
//  Keinex
//
//  Created by Андрей on 09.08.16.
//  Copyright © 2016 Keinex. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

@available(iOS 9.0, *)
class CustomSafariViewContoller: SFSafariViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(false)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
}