//
//  UITableViewExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright (c) 2016 Kyle Thomas. All rights reserved.
//

import UIKit

public extension UITableView {

    subscript(reuseIdentifier: String) -> UITableViewCell {
        return dequeueReusableCellWithIdentifier(reuseIdentifier)!
    }

    subscript(reuseIdentifier: String, indexPath: NSIndexPath) -> UITableViewCell {
        return dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
    }

    subscript(row: Int) -> UITableViewCell {
        return cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0))!
    }

    subscript(row: Int, section: Int) -> UITableViewCell {
        return cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section))!
    }
}
