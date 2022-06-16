//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 16/06/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

/*
#### Data:
- Max age
### Load Feed From Cache Use Case

#### Primary course:
1. Execute "Load Feed Items" command with above data.
2. System fetches feed data from cache.
3. System validates cache is less than seven days old.
4. System creates feed items from cached data.
5. System delivers feed items.

#### Error course (sad path):
1. System delivers error.

#### Expired cache course (sad path):
1. System delivers no feed items.
1. System deletes cache.
2. System delivers no feed items.

#### Empty cache course (sad path):
1. System delivers no feed items.
*/

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    // Doing the same thing but in diff context here we are loading.
    // Currently saving and loading are in same type or class but in future we can sepearte them so we don't want to break our test.
    func test_init_doesNotMessageUponCreation() {
        let (_ , store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrival() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrivalError() {
        let (sut, store) = makeSUT()
        let retrivalError = anyError()
        
        let exp = expectation(description: "Wait for load completion")
        var capturedError: Error?
        sut.load { receivedError in
            capturedError = receivedError
            
            exp.fulfill()
        }
        
        store.completeRetrival(with: retrivalError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNotNil(capturedError)
    }
}

// MARK: - Helepr methods

extension LoadFeedFromCacheUseCaseTests {
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