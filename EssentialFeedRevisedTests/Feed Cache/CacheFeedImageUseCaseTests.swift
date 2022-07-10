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

        sut.insert(data, forUrl: url, completion: { _ in })
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, forUrl: url)])
    }
    
    func test_saveImageDataForURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()

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
}
