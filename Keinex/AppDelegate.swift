//
//  AppDelegate.swift
//  Keinex
//
//  Created by Андрей on 7/15/15.
//  Copyright (c) 2016 Keinex. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let lang = NSLocale.currentLocale().localeIdentifier

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        if lang == "ru_RU" {
            userDefaults.registerDefaults([String(sourceUrl):sourceUrlKeinexRu, "postCount": 50])
        } else {
            userDefaults.registerDefaults([String(sourceUrl):sourceUrlKeinexCom, "postCount": 50])
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }
}

