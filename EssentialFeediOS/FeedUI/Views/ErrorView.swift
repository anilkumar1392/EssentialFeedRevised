//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 08/07/22.
//

import Foundation
import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var label: UILabel!
    
    public var message: String? {
        get { return label.text }
        set { label.text = newValue }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        label.text = nil
    }
}
