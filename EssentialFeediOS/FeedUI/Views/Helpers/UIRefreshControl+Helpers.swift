//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 08/07/22.
//

import Foundation
import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
