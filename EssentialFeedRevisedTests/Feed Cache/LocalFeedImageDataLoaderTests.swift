//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 10/07/22.
//

import Foundation
import XCTest

class LocalFeedImageDataLoader {
    init(store: Any) {
        
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let store = FeedStoreSpy()
        let _ = LocalFeedImageDataLoader(store: store)
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
}

// MARK: - Spy helper
extension LocalFeedImageDataLoaderTests {
    private class FeedStoreSpy {
        private(set) var receivedMessages = [Any]()
    }
}
