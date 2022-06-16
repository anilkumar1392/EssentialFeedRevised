//
//  LocalFeedLoader.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 16/06/22.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, completion: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(items, timestamp: self.currentDate(), completion: { [weak self] error  in
            guard self != nil else { return }
            
            completion(error)
        })
    }
}
