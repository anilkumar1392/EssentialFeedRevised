//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 10/07/22.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, forUrl url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
    }

    public func retrieve(dataFromURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
