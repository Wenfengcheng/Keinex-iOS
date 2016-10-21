//
//  Defaults.swift
//  Keinex
//
//  Created by Андрей on 07.08.16.
//  Copyright © 2016 Keinex. All rights reserved.
//

import Foundation
import UIKit

let userDefaults = UserDefaults.standard
let isiPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
let latestPostValue = "postValue"

//Sources
let sourceUrl:NSString = "SourceUrlDefault"
let sourceUrlKeinexRu:NSString = "https://keinex.ru/wp-json/wp/v2/posts/"
let sourceUrlKeinexCom:NSString = "http://keinex.com/wp-json/wp/v2/posts/"
let autoDelCache:NSString = "none"

