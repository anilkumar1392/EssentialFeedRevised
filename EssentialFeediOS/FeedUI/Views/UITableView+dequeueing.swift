//
//  UITableView+dequeueing.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 07/07/22.
//

import Foundation
import UIKit

public extension UITableView {
    func dequeueResuableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
