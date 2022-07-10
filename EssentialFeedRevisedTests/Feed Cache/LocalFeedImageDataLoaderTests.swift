//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 10/07/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

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
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_loadImageDataFromURL_delviersNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()

        _ = expect(sut, toCompleteWith: notFound()) {
            store.completeRetrieval(with: .none)
        }
    }
}

// MARK: - Success course

extension LocalFeedImageDataLoaderTests {
    func test_loadImageDataFromURL_deliversStoreDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = Data("any valid data".utf8)
        
        _ = expect(sut, toCompleteWith: .success(foundData)) {
            store.completeRetrieval(with: foundData)
        }
    }
}

//MARK:- Task cancelled and sut instance deallcoated

extension LocalFeedImageDataLoaderTests {
    func test_loadImageDataFromURL_doesNotDeliverResultAfterTaskHasBeenCacnelled() {
        let (sut, store) = makeSUT()
        let foundData = anyData()

        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()
        
        store.completeRetrieval(with: foundData)
        store.completeRetrieval(with: .none)
        store.completeRetrieval(with: anyError())
        
        XCTAssertTrue(received.isEmpty, "Expecetd no result after cancelling the task")
    }
}

// MARK: - Save oprations test

extension LocalFeedImageDataLoaderTests {
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()

        sut.insert(data, forUrl: url, completion: { _ in })
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, forUrl: url)])
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
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoaderTask {
        let exp = expectation(description: "wait for load completion...")
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as LocalFeedImageDataLoader.LoadError), .failure(expectedError as LocalFeedImageDataLoader.LoadError)):
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
            case insert(data: Data, forUrl: URL)
        }
        
        private(set) var receivedMessages = [Message]()
        private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
        private var insertionCompletions = [(InsertionResult) -> Void]()

        func retrieve(dataFromURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            retrievalCompletions.append(completion)
        }
        
        func completeRetrieval(with error: Error, at index: Int = 0) {
            retrievalCompletions[index](.failure(error))
        }
        
        func completeRetrieval(with data: Data?, at index: Int = 0) {
            retrievalCompletions[index](.success(data))
        }
        
        // MARK: - Insertion
        
        func insert(_ data: Data, forUrl url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
            receivedMessages.append(.insert(data: data, forUrl: url))
            insertionCompletions.append(completion)
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
