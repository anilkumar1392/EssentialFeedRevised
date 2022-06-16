//
//  File.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 16/06/22.
//

import Foundation

// Feed stor has a ref to feedItem it has a soorce code dependency but HTTPClient does not has a ref to FeedItem why ?
// HTTPClient trails on foundation type which makes it domain specific and decopuled.
// refer to image cache- dependency

// Add 'LocalFeedItem' data transfer representation to decouple storage framework from 'FeedItem' data model

public enum RetrieveCachedFeedResult {
    case failure(Error)
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrivalCompletion = (RetrieveCachedFeedResult) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrivalCompletion)
}
/*
 To decouple use a local implementation of FeedImage specific to FeedStore.
 1. by doing this we allow them to change them own their own face for different reason.
 this is first step towards decentrilization.
 
 In Software this technique is often called DTO (Data transfer object)
 
 This is just Data transfer representation of data model to remove strong coupling
 */
