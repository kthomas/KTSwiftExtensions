//
//  UITableViewCellExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright (c) 2016 Kyle Thomas. All rights reserved.
//

import UIKit

public extension UITableViewCell {

    func enableEdgeToEdgeDividers() {
        layoutMargins = UIEdgeInsetsZero
        separatorInset = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false
    }
}
