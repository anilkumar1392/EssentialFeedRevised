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
    private let calender = Calendar(identifier: .gregorian)

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
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                // self.store.deleteCachedFeed { _ in }
                completion(.failure(error))
                
            case .found(let feed, let timestamp) where self.validate(timestamp):
                completion(.success(feed.toModels()))
                
            case .empty, .found:
                // self.store.deleteCachedFeed { _ in }
                completion(.success([]))
            }
        }
    }
    
    /*
     By using the Query- Command separation principle we have removed all the delete logic form load call.
     */
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
                
            case .found(_, let timestamp) where !self.validate(timestamp):
                self.store.deleteCachedFeed { _ in }

            case .empty, .found:
                break
            }
        }
    }
    
    var maxCacheAgeInDays: Int {
        return 7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return currentDate() < maxCacheAge
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
