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
    private class Task: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompeltions()
        }
        
        private func preventFurtherCompeltions() {
            completion = nil
        }
    }
    
    let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion)
        store.retrieve(dataFromURL: url, completion: { result in
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(Error.notFound)
                })
        })
        return task
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
        
        _ = expect(sut, toCompleteWith: failed()) {
            let retrievalError = anyError()
            store.complete(with: retrievalError)
        }
    }
    
    func test_loadImageDataFromURL_delviersNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()

        _ = expect(sut, toCompleteWith: notFound()) {
            store.complete(with: .none)
        }
    }
}

// MARK: - Success course

extension LocalFeedImageDataLoaderTests {
    func test_loadImageDataFromURL_deliversStoreDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = Data("any valid data".utf8)
        
        _ = expect(sut, toCompleteWith: .success(foundData)) {
            store.complete(with: foundData)
        }
    }
}

//MARK:- Task cancelled

extension LocalFeedImageDataLoaderTests {
    func test_loadImageDataFromURL_doesNotDeliverResultAfterTaskHasBeenCacnelled() {
        let (sut, store) = makeSUT()
        let foundData = anyData()

        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()
        
        store.complete(with: foundData)
        store.complete(with: .none)
        store.complete(with: anyError())
        
        XCTAssertTrue(received.isEmpty, "Expecetd no result after cancelling the task")
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
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.notFound)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoaderTask {
        let exp = expectation(description: "wait for load completion...")
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { receivedResult in
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
        
        return task
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
        
        func complete(with data: Data?, at index: Int = 0) {
            completions[index](.success(data))
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
