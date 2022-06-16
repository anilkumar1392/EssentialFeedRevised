//
//  FeedStoreSpy.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 16/06/22.
//

import Foundation
import EssentialFeedRevised

class FeedStoreSpy: FeedStore {
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    // 2. Effective techique to test the sequence
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrivalCompletions = [RetrivalCompletion]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error: NSError, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    // MARK: - Retrival helper methods
    
    func retrieve(completion: @escaping RetrivalCompletion) {
        retrivalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrival(with error: NSError, at index: Int = 0) {
        retrivalCompletions[index](.failure(error))
    }
    
    func completeRetrivalWithEmptyCache(at index: Int = 0) {
        retrivalCompletions[index](.empty)
    }
    
    func completeRetrival(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrivalCompletions[index](.found(feed: feed, timestamp: timestamp))
    }
}
