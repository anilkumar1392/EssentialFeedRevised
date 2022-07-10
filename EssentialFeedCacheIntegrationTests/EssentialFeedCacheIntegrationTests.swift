//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by 13401027 on 19/06/22.
//

import XCTest
import EssentialFeedRevised
// @testable import EssentialFeediOS

// Intergration test to test load and save in collobaration.

class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_loadFeed_deliversNoItemsOnEmptyCache() {
        let sut = makeFeedLoader()
        
        expect(sut: sut, toLoad: [])
    }
    
    func test_loadFeed_deliversItemsSavedOnDifferentThread() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let feed = uniqueImage()

        save([feed], with: feedLoaderToPerformSave)

        expect(sut: feedLoaderToPerformLoad, toLoad: [feed])
    }
    
    func test_saveFeed_overridesItemsSavedOnSeparateInstacne() {
        let feedLoaderToPerformFirstSave = makeFeedLoader()
        let feedLoaderToPerformLastSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()

        let firstFeed = uniqueImage()
        let secondFeed = uniqueImage()
        
        save([firstFeed], with: feedLoaderToPerformFirstSave)
        save([secondFeed], with: feedLoaderToPerformLastSave)

        expect(sut: feedLoaderToPerformLoad, toLoad: [secondFeed])
    }
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueImage()
        let dataToSave = Data("any data".utf8)

        save([image], with: feedLoader)
        save(dataToSave, for: image.url, with: imageLoaderToPerformSave)

        expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
    }
    
    func test_saveImageData_overridesSavedImageDataOnASeparateInstacne() {
        let imageLoaderToPerformFirstSave = makeImageLoader()
        let imageLoaderToPerformLastSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueImage()
        let firstImageData = Data("first".utf8)
        let lastImageData = Data("last".utf8)
        
        save([image], with: feedLoader)
        save(firstImageData, for: image.url, with: imageLoaderToPerformFirstSave)
        save(lastImageData, for: image.url, with: imageLoaderToPerformLastSave)
        
        expect(imageLoaderToPerformLoad, toLoad: lastImageData, for: image.url)
    }
    
    func test_validateFeedCache_doesNotDeleteRecentlySavedFeed() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformValidation = makeFeedLoader()
        let feed = uniqueImageFeed().models

        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)

        expect(sut: feedLoaderToPerformSave, toLoad: feed)
    }
}

// MARK: - Helper methods
extension EssentialFeedCacheIntegrationTests {
    /*
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store =  try! CoreDataFeedStore(storeURL: storeURL) // CodableFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return sut
    } */
    
    func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "Any description", location: "A location", url: URL(string: "Http://any-url.com")!)
    }
    
    private func makeFeedLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedImageDataLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func validateCache(with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.validateCache() { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to validate feed successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for save completion")

        loader.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected to save feed successfully, got error: \(String(describing: saveError))", file: file, line: line)
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

// MARK: - FeedImageDataLoader helper

extension EssentialFeedCacheIntegrationTests {
    private func save(_ data: Data, for url: URL, with loader: LocalFeedImageDataLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save image data successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(loadedData):
                XCTAssertEqual(loadedData, expectedData, file: file, line: line)

            case let .failure(error):
                XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
