//
//  CoreDataFeedImageDataStoreT.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 10/07/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

extension CoreDataFeedStore: FeedImageDataStore {
    func insert(_ data: Data, forUrl url: URL, completion: @escaping (InsertionResult) -> Void) {
    }
    
    func retrieve(dataFromURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}

class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        let url = anyURL()
        
        let exp = expectation(description: "wait for retrieval..")
        sut.retrieve(dataFromURL: url) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, .none)

            case .failure:
                XCTFail("Expected success, Got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

extension CoreDataFeedImageDataStoreTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
}
