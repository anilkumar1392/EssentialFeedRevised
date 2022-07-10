//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 10/07/22.
//

import Foundation
import XCTest

protocol FeedImageDataStore {
    func retrieve(dataFromURL url: URL)
}

class LocalFeedImageDataLoader: FeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        func cancel() { }
    }
    
    let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataFromURL: url)
        return Task()
    }
    
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadFeedFromURl_requestDataFromStoreWithURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url, completion: { _ in })
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
      }
    
    func test_loadFeedFromURlTwice_requestDataFromStoreWithURLTwice() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url, completion: { _ in })
        _ = sut.loadImageData(from: url, completion: { _ in })

        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url), .retrieve(dataFor: url)])
      }
}

extension LocalFeedImageDataLoaderTests {
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }
}

// MARK: - Spy helper
extension LocalFeedImageDataLoaderTests {
    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private(set) var receivedMessages = [Message]()
        
        func retrieve(dataFromURL url: URL) {
            receivedMessages.append(.retrieve(dataFor: url))
        }
    }
}

/*
 ---

 ### Load Feed Image Data From Cache Use Case

 #### Data:
 - URL

 #### Primary course (happy path):
 1. Execute "Load Image Data" command with above data.
 2. System retrieves data from the cache.
 3. System delivers cached image data.

 #### Cancel course:
 1. System does not deliver image data nor error.

 #### Retrieval error course (sad path):
 1. System delivers error.

 #### Empty cache course (sad path):
 1. System delivers not found error.

 ---
 */
