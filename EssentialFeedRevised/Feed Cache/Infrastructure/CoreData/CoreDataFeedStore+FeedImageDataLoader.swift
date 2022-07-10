//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 10/07/22.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    func insert(_ data: Data, forUrl url: URL, completion: @escaping (InsertionResult) -> Void) {
    }
    
    func retrieve(dataFromURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
