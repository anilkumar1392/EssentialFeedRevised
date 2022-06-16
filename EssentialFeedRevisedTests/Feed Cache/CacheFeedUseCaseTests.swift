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
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedImage], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }

            if error == nil {
                self.store.insert(items, timestamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
}


class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageUponCreation() {
        let (_ , store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut , store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed ])
    }
    
    /*
     Protecting against calling the wrong method at wrong time.
     */
    func test_save_doesNotRequestCacheInsertionOnCacheDeletionError() {
        let (sut , store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyError()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }

    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfullDeletion() {
        let timestamp = Date()
        let (sut , store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let timestamp = Date()
        let (sut , store) = makeSUT(currentDate: { timestamp })
        let deletionError = anyError()

        /*
        let items = [uniqueItem(), uniqueItem()]
        let exp = expectation(description: "Wait for save completion")
        
        var capturedError: Error?
        sut.save(items) { receivedError in
            capturedError = receivedError
            
            exp.fulfill()
        }
        
        store.completeDeletion(with: deletionError)

        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as NSError?, deletionError)
        */
        
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)

        }
    }
    
    func test_save_failsOnInsertionError() {
        let timestamp = Date()
        let (sut , store) = makeSUT(currentDate: { timestamp })

        let insertionError = anyError()

        /*
        let items = [uniqueItem(), uniqueItem()]
        let exp = expectation(description: "Wait for save completion")
        
        var capturedError: Error?
        sut.save(items) { receivedError in
            capturedError = receivedError

            exp.fulfill()
        }

        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError, at: 0)

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(capturedError as NSError?, insertionError)
         */
  
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError, at: 0)
        }
    }
    
    func test_save_succeedsOnSuccessfullCacheInsertion() {
        let timestamp = Date()
        let (sut , store) = makeSUT(currentDate: { timestamp })
        
        /*
        let items = [uniqueItem(), uniqueItem()]
        let exp = expectation(description: "Wait for save completion")
        
        var capturedError: Error?
        sut.save(items) { receivedError in
            capturedError = receivedError
            
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNil(capturedError)
         */
        
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstacneHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        let items = [uniqueItem(), uniqueItem()]

        var capturedError: NSError?
        sut?.save(items) { receivedError in
            capturedError = receivedError as NSError?
        }
        sut = nil
        store.completeDeletion(with: anyError())
        
        XCTAssertNil(capturedError)
    }
}

// MARK: - Helepr methods

extension CacheFeedUseCaseTests {
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        
        var capturedError: Error?
        sut.save([uniqueItem()]) { receivedError in
            capturedError = receivedError
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as NSError?, expectedError, file: file, line: line)
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

extension CacheFeedUseCaseTests {
    class FeedStoreSpy: FeedStore {
        // 1. var insertions = [(items: [FeedImage], timestamp: Date)]()
        
        enum ReceivedMessage: Equatable {
            case deleteCacheFeed
            case insert([FeedImage], Date)
        }
        
        private(set) var receivedMessages = [ReceivedMessage]()
        
        // 2. Effective techique to test the sequence
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCacheFeed)
        }
        
        func completeDeletion(with error: NSError, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func insert(_ items: [FeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(items, timestamp))
        }
        
        func completeInsertion(with error: NSError, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }
}
