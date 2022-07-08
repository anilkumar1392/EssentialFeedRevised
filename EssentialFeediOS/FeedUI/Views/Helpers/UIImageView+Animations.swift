//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 07/07/22.
//

import Foundation
import UIKit

public extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        guard newImage != nil else { return }
        alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
