//
//  LocalFeedLoader.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 16/06/22.
//

import Foundation
import UIKit

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, completion: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: self.currentDate(), completion: { [weak self] error  in
            guard self != nil else { return }
            
            completion(error)
        })
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .empty:
                completion(.success([]))
                
            case .found(let feed, _):
                completion(.success(feed.toModels() ))
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}


private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
