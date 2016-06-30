//
//  UIStoryboardExtensions.swift
//  KTSwiftExtensions
//
//  Created by Kyle Thomas on 6/27/16.
//  Copyright (c) 2016 Kyle Thomas. All rights reserved.
//

import UIKit

extension UIStoryboard {

    convenience init(_ name: String) {
        self.init(name: name, bundle: nil)
    }
}
