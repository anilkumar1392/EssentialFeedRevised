//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 15/06/22.
//

import XCTest
import EssentialFeedRevised

/*
 ### Save Feed Items Use Case
 ### Cache Feed Use Case

 #### Data:
 - Feed items

 #### Primary course (happy path):
 1. Execute "Save Feed Items" command with above data.
 2. System deletes old cache data.
 3. System encodes feed items.
 4. System timestamps the new cache.
 5. System saves new cache data.
 6. System delivers success message.

 #### Deleting error course (sad path):
 1. System delivers error.

 #### Saving error course (sad path):
 1. System delivers error.
 */

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageUponCreation() {
        let (_ , store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut , store) = makeSUT()
        
        sut.save(uniqueImageFeed().models) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed ])
    }
    
    /*
     Protecting against calling the wrong method at wrong time.
     */
    func test_save_doesNotRequestCacheInsertionOnCacheDeletionError() {
        let (sut , store) = makeSUT()
        let deletionError = anyError()
        
        sut.save(uniqueImageFeed().models) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }

    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfullDeletion() {
        let timestamp = Date()
        let (sut , store) = makeSUT(currentDate: { timestamp })
        let feed = uniqueImageFeed()
        
        sut.save(feed.models) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(feed .local, timestamp)])
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
        let items = [uniqueImage(), uniqueImage()]

        var capturedError = [LocalFeedLoader.SaveResult]()
        sut?.save(items) { receivedError in
            capturedError.append(receivedError)
        }
        sut = nil
        store.completeDeletion(with: anyError())
        
        XCTAssertTrue(capturedError.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstacneHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        let items = [uniqueImage(), uniqueImage()]

        var capturedError = [LocalFeedLoader.SaveResult]()
        sut?.save(items) { receivedError in
            capturedError.append(receivedError)
        }
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyError())
        
        XCTAssertTrue(capturedError.isEmpty)
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
        sut.save([uniqueImage()]) { receivedError in
            capturedError = receivedError
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let items = [uniqueImage(), uniqueImage()]
        let localItems = items.map {LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
        return (items, localItems)
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "Any description", location: "A location", url: anyURL())
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
            case insert([LocalFeedImage], Date)
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
        
        func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(feed, timestamp))
        }
        
        func completeInsertion(with error: NSError, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }
}
