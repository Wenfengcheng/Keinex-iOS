//
//  LocalizableEngine.swift
//  Keinex
//
//  Created by Андрей on 19.08.16.
//  Copyright © 2016 Keinex. All rights reserved.
//

import Foundation

extension String {
    var localize: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
}