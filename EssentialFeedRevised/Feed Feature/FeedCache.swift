//
//  FeedCache.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 10/07/22.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
