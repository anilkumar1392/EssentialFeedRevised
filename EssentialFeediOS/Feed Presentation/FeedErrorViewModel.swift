//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 08/07/22.
//

import Foundation

public struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
