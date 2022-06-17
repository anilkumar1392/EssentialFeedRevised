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
1. System deletes cache
2. System delivers error.

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
        
        /*
        let exp = expectation(description: "Wait for load completion")
        var capturedError: Error?
        sut.load { result in
            switch result {
            case .failure(let error):
                capturedError = error
                
            default:
                XCTFail("Expected to complete with error, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        store.completeRetrival(with: retrivalError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as NSError?, retrivalError)
         */
        
        expect(sut, toCompleteWithError: .failure(retrivalError)) {
            store.completeRetrival(with: retrivalError)
        }
    }
    

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        /*
        let exp = expectation(description: "Wait for load completion")

        var capturedImages = [FeedImage]()
        sut.load { result in
            switch result {
            case .success(let images):
                capturedImages = images

            default:
                XCTFail("Expected success, got \(result) instead.")
            }

            exp.fulfill()
        }

        store.completeRetrivalWithEmptyCache()
        wait(for: [exp], timeout: 2.0)

        XCTAssertEqual(capturedImages, [])
        */
        
        expect(sut, toCompleteWithError: .success([])) {
            store.completeRetrivalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedImagesOnNonExpiredCache() {
        // test_load_deliversCachedImagesOnLessThanSevenDaysOldCache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate  })

        expect(sut, toCompleteWithError: .success(feed.models)) {
            store.completeRetrival(with: feed.local, timestamp: nonExpiredTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnExpirationCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWithError: .success([])) {
            store.completeRetrival(with: feed.local, timestamp: expirationTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(days: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWithError: .success([])) {
            store.completeRetrival(with: feed.local, timestamp: expiredTimestamp)
        }
    }
    
    func test_load_hasNoSideEffectsOnRetrivalError() { // test_load_deletesCacheFromRetrivalError
        let (sut, store) = makeSUT()
        
        sut.load(completion: { _ in })
        
        store.completeRetrival(with: anyError())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() { // test_load_doesNotdeletesCacheOnEmptyCache
        let (sut, store) = makeSUT()
        
        sut.load(completion: { _ in })
        store.completeRetrivalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredOldCache() {
        // Evolution over time how name chanegd
        // test_load_doesNotDeletesCacheOnLessThanSevenDaysOldCache
        // test_load_hasNoSideEffectsOnLessThanSevenDaysOldCache
        
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate  })

        sut.load(completion: { _ in })
        store.completeRetrival(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnCacheExpiration() {
        // test_load_deletesCacheOnSevenDaysOldCache
        // test_load_hasNoSideEffectsOnSevenDaysOldCache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate  })

        sut.load(completion: { _ in })
        store.completeRetrival(with: feed.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnExpiredCache() {
        // test_load_deletesCacheOnMoreThanSevenDaysOldCache
        // test_load_hasNoSideEffectOnMoreThanSevenDaysOldCache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate  })

        sut.load(completion: { _ in })
        store.completeRetrival(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstaceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
       
        var capturedResult = [LocalFeedLoader.LoadResult]()
        
        sut?.load(completion: { result in
            capturedResult.append(result)
        })
        
        sut = nil
        store.completeRetrival(with: anyError())
                
        XCTAssertTrue(capturedResult.isEmpty)
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
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)

            case let (.failure(receivedError as NSError?), .failure(expectedError as NSError?)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
            }

            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
