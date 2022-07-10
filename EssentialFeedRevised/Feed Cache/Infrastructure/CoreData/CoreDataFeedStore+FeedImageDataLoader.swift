//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 10/07/22.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataFromURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        perform { context in
            // CoreData operation will perform serially
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)?.data
            })
        }
    }
    
    public func insert(_ data: Data, forUrl url: URL, completion: @escaping (InsertionResult) -> Void) {
        perform { context in
            // CoreData operation will perform serially
//            guard let image = try? ManagedFeedImage.first(with: url, in: context) else { return }
//            image.data = data
//            try? context.save()
            
//            completion(Result {
//                let image = try ManagedFeedImage.first(with: url, in: context)
//                image?.data = data
//                try? context.save()
//            })
            
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data =  data }
                    .map(context.save)
            })
        }
    }
}

