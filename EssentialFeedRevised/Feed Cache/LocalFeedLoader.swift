//
//  LocalFeedLoader.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 16/06/22.
//

import Foundation
import UIKit

private final class FeedCachePolicy {
    private init() {}
    private static let calender = Calendar(identifier: .gregorian)
    
    /*
     private let currentDate: () -> Date
     
     init(currentDate: @escaping () -> Date) {
     self.currentDate = currentDate
     } */
    
    /*
     Currently the current date is impure as It is not deterministic and it may change.
     To make it pure fucntion we can pass data instead of fucntion and our method become deterministic.
     
     Now data is a struct and In this case it is Immutable.
     */
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against data: Date) -> Bool {
        guard let maxCacheAge = FeedCachePolicy.calender.date(byAdding: .day, value: FeedCachePolicy.maxCacheAgeInDays, to: timestamp) else { return false }
        return data < maxCacheAge
    }
}

public class LocalFeedLoader {
    private let store: FeedStore
    // private let cachePolicy = FeedCachePolicy()
    private let currentDate: () -> Date

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

// MARK: - Save command

extension LocalFeedLoader {
    public typealias SaveResult = Error?

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
}

// MARK: - Load command

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = LoadFeedResult

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                // self.store.deleteCachedFeed { _ in }
                completion(.failure(error))
                
            case .found(let feed, let timestamp) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(feed.toModels()))
                
            case .empty, .found:
                // self.store.deleteCachedFeed { _ in }
                completion(.success([]))
            }
        }
    }
}

/*
 By using the Query- Command separation principle we have removed all the delete logic form load call.
 */

// MARK: - Save Validate command

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
                
            case .found(_, let timestamp) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
                
            case .empty, .found:
                break
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
