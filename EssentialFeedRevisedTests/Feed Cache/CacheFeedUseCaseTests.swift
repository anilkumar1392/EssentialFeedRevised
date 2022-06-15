//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 15/06/22.
//

import XCTest
import EssentialFeedRevised

class FeedStore {
    var deleteCachedFeedcallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedcallCount += 1
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedImage]) {
        store.deleteCachedFeed()
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_ , store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedcallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut , store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedcallCount, 1)
    }
}

// MARK: - Helepr methods

extension CacheFeedUseCaseTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedImage {
        return FeedImage(id: UUID(), description: "Any description", location: "A location", imageURL: anyURL())
    }
    
    func anyURL() -> URL {
        return URL(string: "Http://any-url.com")!
    }

}
