//
//  CoreDataFeedImageDataStoreT.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 10/07/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        let url = anyURL()

        /*
        
        let exp = expectation(description: "wait for retrieval..")
        sut.retrieve(dataFromURL: url) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, .none)

            case .failure:
                XCTFail("Expected success, Got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
         */
        
        expect(sut, toCompleteWith: notFound(), for: url)
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let notMatchingUrl = URL(string: "http://another-url.com")!

        /*
        let exp = expectation(description: "Wait for insert completion...")
        
        sut.insert([image], timestamp: Date()) { error in
            if let error = error {
                XCTFail("Expected to complete with success, Got \(error) instead")
            } else {
                sut.insert(data, forUrl: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("Failed to insert \(data) with error \(error)")
                    }
                }
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        */
        
        insert(anyData(), for: url, into: sut)

        expect(sut, toCompleteWith: notFound(), for: notMatchingUrl)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenTheirIsAStoredImageDataMatchingThatURL() {
        let sut = makeSUT()
        let storedData = anyData()
        let matchingURL = URL(string: "http://a-url.com")!
        
        insert(storedData, for: matchingURL, into: sut)
        
        expect(sut, toCompleteWith: found(storedData), for: matchingURL)
    }
}

extension CoreDataFeedImageDataStoreTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func found(_ data: Data?) -> FeedImageDataStore.RetrievalResult {
        return .success(data)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache insertion")
        let image = localImage(url: url)
        sut.insert([image], timestamp: Date()) { error in
            if let error = error {
                XCTFail("Expected to complete with success, Got \(error) instead")
            } else {
                sut.insert(data, forUrl: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("Failed to insert \(data) with error \(error)")
                    }
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL, file: StaticString = #file, line: UInt = #line) {
       
        let exp = expectation(description: "wait for retrieval..")
        
        sut.retrieve(dataFromURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}


/*
 // Commits
 1. CoreDataFeedStore.retrieveImageData delivers image data not found when empty
 
 2. CoreDataFeedStore.retrieveImageData delivers image data not found when store is not empty but there's no image with matching URL
 */
