//
//  Defaults.swift
//  Keinex
//
//  Created by Андрей on 07.08.16.
//  Copyright © 2016 Keinex. All rights reserved.
//

import Foundation
import UIKit

let userDefaults = NSUserDefaults.standardUserDefaults()
let isiPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
let latestPostValue = "postValue"
let sourceUrl:NSString = "SourceUrlDefault"
let sourceUrlKeinexRu:NSString = "https://keinex.ru/wp-json/wp/v2/posts/"
let sourceUrlKeinexCom:NSString = "http://keinex.com/wp-json/wp/v2/posts/"

