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
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.sore")
    
    
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
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.sore")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.sore")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliverEmptyOnEmptyCache() {
        let sut = makeSUT()
        
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
    }

    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
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
    }
    
    // Retrieve after inserting showuld return inserted result
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues () {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for cache retrival")
        sut.insert(feed, timestamp: timestamp, completion: { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
           
            sut.retrieve { result in
                switch result {
                case .found(let receivedFeed, let receivedTimestamp):
                    XCTAssertEqual(receivedFeed, feed)
                    XCTAssertEqual(receivedTimestamp, timestamp)

                default:
                    XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp), got \(result) instead.")
                }
            }
            
            exp.fulfill()
        })

        wait(for: [exp], timeout: 1.0)
    }
}

// MARK: - Helper methods

extension CodableFeedStoreTests {
    private func makeSUT() -> CodableFeedStore {
        return CodableFeedStore()
    }
}
