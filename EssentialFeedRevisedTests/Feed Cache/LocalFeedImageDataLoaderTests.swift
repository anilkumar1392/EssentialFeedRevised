//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 10/07/22.
//

import Foundation
import XCTest

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    func retrieve(dataFromURL url: URL, completion: @escaping (Result) -> Void)
}

class LocalFeedImageDataLoader: FeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        func cancel() { }
    }
    
    let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataFromURL: url, completion: { result in
            switch result {
            case let .success(data):
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(Error.failed))
                }
                
            case .failure:
                completion(.failure(Error.failed))
            }
        })
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

// MARK: - Error Course
extension LocalFeedImageDataLoaderTests {
    func test_loadImageDataFromUrl_failsOnStoreError() {
        let (sut, store) = makeSUT()

        /*
        let exp = expectation(description: "Wait for load completion...")
        _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case .success:
                XCTFail("Expecetd failure, got \(result) instead")
                
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            
            exp.fulfill()
        }
        store.complete(with: retrievalError)
        
        wait(for: [exp], timeout: 1.0)
         */
        
        expect(sut, toCompleteWith: failed()) {
            let retrievalError = anyError()
            store.complete(with: retrievalError)
        }
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
    
    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.failed)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion...")
        let url = anyURL()
        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as LocalFeedImageDataLoader.Error), .failure(expectedError as LocalFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult), Got \(receivedResult) instead.")
                
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 5.0)
    }
}

// MARK: - Spy helper
extension LocalFeedImageDataLoaderTests {
    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private(set) var receivedMessages = [Message]()
        private var completions = [(FeedImageDataStore.Result) -> Void]()
        
        func retrieve(dataFromURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
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
