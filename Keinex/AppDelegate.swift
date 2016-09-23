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
    let lang = Locale.current.identifier

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

        if lang == "ru_RU" {
            userDefaults.register(defaults: [String(sourceUrl):sourceUrlKeinexRu])
        } else {
            userDefaults.register(defaults: [String(sourceUrl):sourceUrlKeinexCom])
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

