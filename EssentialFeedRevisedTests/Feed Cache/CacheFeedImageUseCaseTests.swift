//
//  CacheFeedImageUseCaseTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 10/07/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

class CacheFeedImageUseCasesTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()

        sut.save(data, for: url, completion: { _ in })
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, forUrl: url)])
    }
    
    func test_saveImageDataForURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()

        /*
        let exp = expectation(description: "wait for save completion...")
        sut.insert(anyData(), forUrl: anyURL()) { result in
            switch result {
            case let .failure(error):
                XCTAssertNotNil(error)
                
            default:
                XCTFail("Expected to complete with failure, got \(result) instead.")
            }
            exp.fulfill()
        }
        
        store.completeInsertion(with: anyError())
        
        wait(for: [exp], timeout: 1.0)
         */
        
        expect(sut, toCompleteWith: failed()) {
            store.completeInsertion(with: anyError())
        }
    }
    
    func test_saveImageDataForURL_succeedsOnSuccessfullStoreInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(())) {
            store.completeInsertionSuccessfully()
        }
    }
}

// MARK: - does not delvier result after instacne has been deallcoated

extension CacheFeedImageUseCasesTests {
    func test_saveDataImageForUrl_doesNotDeliverResultAfterSUTInstacneHasBeenDeallcoated() {
        let store = StoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var recevied = [LocalFeedImageDataLoader.SaveResult]()
        sut?.save(anyData(), for: anyURL(), completion: { recevied.append($0) })
        
        sut = nil
        store.completeInsertion(with: anyError())
        
        XCTAssertTrue(recevied.isEmpty)
    }
}

extension CacheFeedImageUseCasesTests {
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        return .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "wait for save completion...")

        sut.save(anyData(), for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as LocalFeedImageDataLoader.SaveError), .failure(expecetdError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expecetdError, file: file, line: line)
             
            case (.success, .success):
                break
                
            default:
                XCTFail("Expected to complete \(expectedResult) with failure, got \(receivedResult) instead.")
            }
            exp.fulfill()
        }

        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
