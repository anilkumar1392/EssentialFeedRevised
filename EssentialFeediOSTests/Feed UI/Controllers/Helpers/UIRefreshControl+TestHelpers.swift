//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 08/07/22.
//

import Foundation
import UIKit

extension UIRefreshControl {
    func simulatePullToReferesh() {
        allTargets.forEach({ target in
            actions(forTarget: target,
                    forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        })
    }
}
