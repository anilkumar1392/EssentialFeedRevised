//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 18/06/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file : StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for cache retrival")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp, completion: { receivedInsertionError in
            // XCTAssertNil(receivedInsertionError, "Expected feed to be inserted successfully", file: file, line: line)
            insertionError = receivedInsertionError
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore, file : StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for cache deletion")
        
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            //XCTAssertNil(deletionError, "Expected non-empty cache deletion to complete successfully.")
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file : StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file : StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                (.failure, .failure):
                // We dont know the error that can be thrown by do catch do not matching them just check failure.
                break
                
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
