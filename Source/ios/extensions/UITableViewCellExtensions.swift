//
//  UITableViewCellExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import UIKit

public extension UITableViewCell {

    func enableEdgeToEdgeDividers() {
        layoutMargins = UIEdgeInsets.zero
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
    }
}
