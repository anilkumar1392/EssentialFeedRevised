//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by 13401027 on 19/06/22.
//

import XCTest
import EssentialFeedRevised

class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case .success(let feed):
                XCTAssertEqual(feed, [], "Expected to complete with empty list")

            case .failure(let error):
                XCTFail("Expected to complete with success got, \(error) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnDifferentThread() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        let saveExp = expectation(description: "wait for save completion")
        sutToPerformSave.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected save to complete successfully.")
            
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 3.0)
        
        let loadExp = expectation(description: "wait for load completion")

        sutToPerformLoad.load { result in
            switch result {
            case .success(let feedImages):
                XCTAssertEqual(feedImages, feed, "Expected to completed with saved feed")
                
            default:
                XCTFail("Expected to get \(feed), got \(result) instead.")
            }
            
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 3.0)
    }
}

// MARK: - Helper methods
extension EssentialFeedCacheIntegrationTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
