//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 10/07/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
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

extension LoadFeedImageDataFromCacheUseCaseTests {
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

extension LoadFeedImageDataFromCacheUseCaseTests {
    func test_loadImageDataFromURL_deliversStoreDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = Data("any valid data".utf8)
        
        _ = expect(sut, toCompleteWith: .success(foundData)) {
            store.completeRetrieval(with: foundData)
        }
    }
}

//MARK:- Task cancelled and sut instance deallcoated

extension LoadFeedImageDataFromCacheUseCaseTests {
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

extension LoadFeedImageDataFromCacheUseCaseTests {
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
