//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 15/06/22.
//

import XCTest
import EssentialFeedRevised

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedImage]) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if error == nil {
                self.store.insert(items)
            } else {
                
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCachedFeedcallCount = 0
    var insertCallCount = 0
    
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedcallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedImage]) {
        insertCallCount += 1
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
    
    /*
     Protecting against calling the wrong method at wrong time.
     */
    func test_save_doesNotRequestCacheInsertionOnCacheDeletionError() {
        let (sut , store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestNewCacheInsertionOnSuccessfullCacheDeletion() {
        let (sut , store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
}

// MARK: - Helepr methods

extension CacheFeedUseCaseTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedImage {
        return FeedImage(id: UUID(), description: "Any description", location: "A location", imageURL: anyURL())
    }
    
    func anyURL() -> URL {
        return URL(string: "Http://any-url.com")!
    }
    
    func anyError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    

}
