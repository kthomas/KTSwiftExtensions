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

public extension UITableView {

    // This method can be used when the reuseIdentifier matches the name of the class
    func dequeue<CellClass>(_ cellClass: CellClass.Type, for indexPath: IndexPath) -> CellClass {
        let reuseIdentifier = "\(cellClass)"
        guard let cell = dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? CellClass else {
            fatalError("Could not find a cell with reuseIdentifier: \(reuseIdentifier). Please ensure that the reuseidentifier for \(cellClass) is set to \(reuseIdentifier)")
        }
        return cell
    }
}

public extension UICollectionView {

    // This method can be used when the reuseIdentifier matches the name of the class
    func dequeue<CellClass>(_ cellClass: CellClass.Type, for indexPath: IndexPath) -> CellClass {
        let reuseIdentifier = "\(cellClass)"
        guard let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CellClass else {
            fatalError("Could not find a cell with reuseIdentifier: \(reuseIdentifier). Please ensuer that the reuseidentifier for \(cellClass) is set to \(reuseIdentifier)")
        }
        return cell
    }
}
