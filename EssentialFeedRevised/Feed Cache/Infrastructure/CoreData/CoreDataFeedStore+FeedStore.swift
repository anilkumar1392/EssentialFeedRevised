//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 10/07/22.
//

import Foundation
import CoreData

extension CoreDataFeedStore: FeedStore {
    public func retrieve(completion: @escaping RetrivalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
            
//            completion(Result {
//                try ManagedCache.find(in: context) {
//                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
//                }
//            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in

            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context) //ManagedCache(context: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
            
            //            completion(Result {
            //                let managedCache = try ManagedCache.newUniqueInstance(in: context)
            //                managedCache.timestamp = timestamp
            //                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
            //                try context.save()
            //            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
