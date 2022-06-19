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
        
        expect(sut: sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnDifferentThread() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models

        save(feed, with: sutToPerformSave)

        expect(sut: sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnSeparateInstacne() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformSecondSave = makeSUT()
        let sutToPerformLoad = makeSUT()

        let firstFeed = uniqueImageFeed().models
        let secondFeed = uniqueImageFeed().models
        
        save(firstFeed, with: sutToPerformFirstSave)
        save(secondFeed, with: sutToPerformSecondSave)

        expect(sut: sutToPerformLoad, toLoad: secondFeed)
    }
}

// MARK: - Helper methods
extension EssentialFeedCacheIntegrationTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store =  try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle) // CodableFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return sut
    }
    
    private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for save completion")
        loader.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected save to complete successfully.")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
    
    private func expect(sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case .success(let loadedFeed):
                XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)

            case .failure(let error):
                XCTFail("Expected successfull feed result, got \(error) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
