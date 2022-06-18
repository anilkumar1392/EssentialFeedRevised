//
//  CodableFeedStoreTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 17/06/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private var id: UUID
        private var description: String?
        private var location: String?
        private var url: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}
 
class CodableFeedStoreTests: XCTestCase {
    
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
        
        expect(sut, toRetrieve: .empty)
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
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    // Retrieve after inserting showuld return inserted result
    // Changeing the shape of code
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues () {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
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
        
        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp ))
    }
    
    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
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
        
        insert((feed, timestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
}

// MARK: - Helper methods

extension CodableFeedStoreTests {
    private func makeSUT() -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore, file : StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrival")
        sut.insert(cache.feed, timestamp: cache.timestamp, completion: { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully", file: file, line: line)
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file : StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file : StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty):
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
    
    // Replace production store url with a test specific store url.
    
    private func testSpecificStoreURL() -> URL {
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
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
}
