//
//  UITableViewExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright © 2016 Kyle Thomas. All rights reserved.
//

import UIKit

public extension UITableView {

    subscript(reuseIdentifier: String) -> UITableViewCell {
        return dequeueReusableCell(withIdentifier: reuseIdentifier)!
    }

    subscript(reuseIdentifier: String, indexPath: IndexPath) -> UITableViewCell {
        return dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    }

    subscript(row: Int) -> UITableViewCell {
        return cellForRow(at: IndexPath(row: row, section: 0))!
    }

    subscript(row: Int, section: Int) -> UITableViewCell {
        return cellForRow(at: IndexPath(row: row, section: section))!
    }
}
