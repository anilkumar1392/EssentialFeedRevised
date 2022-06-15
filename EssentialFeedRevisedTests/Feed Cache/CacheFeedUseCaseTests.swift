//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 15/06/22.
//

import XCTest

class FeedStore {
    var deleteCachedFeedcallCount = 0
}

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedcallCount, 0)
    }
}
