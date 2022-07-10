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
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
}

extension LocalFeedImageDataLoaderTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }
}

// MARK: - Spy helper
extension LocalFeedImageDataLoaderTests {
    private class FeedStoreSpy {
        private(set) var receivedMessages = [Any]()
    }
}
