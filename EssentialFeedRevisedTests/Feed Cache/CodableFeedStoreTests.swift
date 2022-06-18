//
//  CodableFeedStoreTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 17/06/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

// We dont know the error that can be thrown by do catch do not matching them just check failure.
/*
Requirment feed store implementation.

- Retrieve
    - Empty cache
    - Empty cache twice return empty (no side effects)
    - Non empty cache
    - Non - empty cache twice returns same data (no side effects)
    - Error return error (if applicable, e.g, Invalid Data)
    - Error twice returns same error (if applicable, e.g, Invalid Data)

- Insert
    - To empty cache Stores data
    - To non empty cache overrides previous data with new data
    - Error (if applicable, if not write permission)
    
- Delete
    - Empty cache does nothing (Cache tays empty and does not fail)
    - Non empty cache leaves cache empty
    - Error (if applicable, if delete permission)
    
- Side effects must run serially to avoid race conditions.
*/

typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
 
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliverEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        /*
        let exp = expectation(description: "Wait for cache retrival")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected empty result, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
         */
        
        // expect(sut, toRetrieve: .empty)
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        /*
        let exp = expectation(description: "Wait for cache retrival")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected retriving twice from empty cache return same empty result, got \(firstResult) and \(secondResult) instead")
                }
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
         */
        
        // expect(sut, toRetrieveTwice: .empty)
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    // Retrieve after inserting showuld return inserted result
    // Changeing the shape of code
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        // test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues
        let sut = makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)

        
        /*
        let exp = expectation(description: "Wait for cache retrival")
        sut.insert(feed, timestamp: timestamp, completion: { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
           
            /*
            sut.retrieve { result in
                switch result {
                case .found(let receivedFeed, let receivedTimestamp):
                    XCTAssertEqual(receivedFeed, feed)
                    XCTAssertEqual(receivedTimestamp, timestamp)

                default:
                    XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp), got \(result) instead.")
                }
            } */
            
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
         */
        
        /*
        let feed = uniqueImageFeed().local
        let timestamp = Date()
         
        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp ))
         */
        
    }
    
    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)

        /*
        let exp = expectation(description: "Wait for cache retrival")
        sut.insert(feed, timestamp: timestamp, completion: { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
           
            /*
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult) {
                    case let (.found(firstFeed, firstTimestamp), .found(secondFeed, secondTimestamp)):
                        XCTAssertEqual(firstFeed, feed)
                        XCTAssertEqual(firstTimestamp, timestamp)

                        XCTAssertEqual(secondFeed, feed)
                        XCTAssertEqual(secondTimestamp, timestamp)
                        
                    default:
                        XCTFail("expectd retriving twice from non empty cache to deliver sam result with \(feed) and \(timestamp), got \(firstResult) and \(secondResult) instead.")
                    }
                }
            } */
            
            exp.fulfill()
        })

        wait(for: [exp], timeout: 1.0)
        */
        
        /*
         let feed = uniqueImageFeed().local
         let timestamp = Date()
         
         insert((feed, timestamp), to: sut)
         
         expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
         */

    }
    
    func test_retrieve_deliversFailureOnRetrivalError() {
        let storeUrl = testSpecificStoreURL()
                
        let sut = makeSUT(storeURL: storeUrl)

        try! "Invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnRetrivalError() {
        let storeUrl = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeUrl)

        try! "Invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        // let feed = uniqueImageFeed().local
        let sut = makeSUT()
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
        /*
        let timestamp = Date()
        let sut = makeSUT()

        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
         */
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        // let feed = uniqueImageFeed().local
        let sut = makeSUT()

        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
        /*
        let timestamp = Date()
        let sut = makeSUT()
        insert((feed, timestamp), to: sut)
        
        let insertionError = insert((feed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
         */
    }
    
    func test_insert_overridesPreviouslyInsertedCachedValues() {
        let sut = makeSUT()
        
        /*
        insert((feed: uniqueImageFeed().local, timestamp: Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        
        insert((feed: latestFeed, timestamp: latestTimestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp)) */
        
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let storeURL = URL(string: "Invalid://store-url")!
        let sut = makeSUT(storeURL: storeURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed: feed, timestamp: timestamp), to: sut)
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_insert_hasNoSideEffectOnInsertionError() {
        let storeURL = URL(string: "Invalid://store-url")!
        let sut = makeSUT(storeURL: storeURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed: feed, timestamp: timestamp), to: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        /*
        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty) */
        
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
        /*
        let exp = expectation(description: "wait for delete compeltion")
        sut.deleteCachedFeed { deletionError in
            XCTAssertNil(deletionError, "Expected empty cache deletion to complete successfully.")
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
         */
        
        /*
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to complete successfully.")
        
        expect(sut, toRetrieve: .empty) */
    }
        
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
        /*
        insert((uniqueImageFeed().local, Date()), to: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed") */
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
        /*
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        /*
        let exp = expectation(description: "wait for cache deletion")
        sut.deleteCachedFeed { deletionError in
            XCTAssertNil(deletionError, "Expected non-empty cache deletion to complete successfully.")
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
         */
        
        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty) */
        
        
    }
    
    func test_delete_deliverErrorOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        
        /*
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected to complete with error.") */
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
 
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        assertThatSideEffectsRunSerially(on: sut)
        /*
        var completedQperationInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Wait for op1 to complete")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedQperationInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Wait for op2 to complete")
        sut.deleteCachedFeed { _ in
            completedQperationInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Wait for op3 to complete")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedQperationInOrder.append(op3)
            op3.fulfill()
        }
        
        wait(for: [op1, op2, op3], timeout: 5.0)
        
        XCTAssertEqual(completedQperationInOrder, [op1, op2, op3], "Expected to complete operation in order") */
    }
}

// MARK: - Helper methods

extension CodableFeedStoreTests {
    private func makeSUT(storeURL: URL? = nil) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut)
        return sut
    }
    // Replace production store url with a test specific store url.
    
    private func testSpecificStoreURL() -> URL {
        let storeURL = cacheDirectory().appendingPathComponent("\(type(of: self)).store")
        return storeURL
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func noDeletePermissionURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
}

// Reusable code moved to tests helper
/*
extension CodableFeedStoreTests {
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file : StaticString = #file, line: UInt = #line) -> Error? {
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
    private func deleteCache(from sut: FeedStore, file : StaticString = #file, line: UInt = #line) -> Error? {
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
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file : StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file : StaticString = #file, line: UInt = #line) {
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
 */
