//
//  FeedLoader.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 26/05/22.
//

import Foundation

// Public interface for both load from url and load from cache localDB.

enum LoadFeedResult {
    case success([FeedImage])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
