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

//Keinex.ru
let sourceUrlKeinexRu:NSString = "https://keinex.ru/wp-json/wp/v2/posts/"
let sourceUrlKeinexRuComments:NSString = "https://keinex.ru/?json=1"

//Keinex.com
let sourceUrlKeinexCom:NSString = "http://keinex.com/wp-json/wp/v2/posts/"
let sourceUrlKeinexComComments:NSString = "http://keinex.com/?json=1"

