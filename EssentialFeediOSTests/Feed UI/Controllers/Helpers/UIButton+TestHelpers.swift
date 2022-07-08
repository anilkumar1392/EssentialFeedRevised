//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 08/07/22.
//

import Foundation
import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
