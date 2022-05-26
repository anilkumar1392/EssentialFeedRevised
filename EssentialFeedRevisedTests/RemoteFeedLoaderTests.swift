//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 26/05/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

/*
 Tecture 1.
 From Singletons and Globals to Proper Dependency Injection
 
 Learning Outcomes
 How to test-drive an API layer implementation
 Modular Design
 Singletons: When and Why
 Singletons: Better alternatives
 Singletons: Refactoring steps to gradually remove tight coupling created by singletons
 Controlling your dependencies: Locating globally shared instances (Implicit) vs. Injecting dependencies (Explicit)
 Controlling your dependencies: Dependency injection
 
 */

class RemoteFeedLoaderTests: XCTestCase {
    
    /* test_method_behaviorWeExpect */
    
    func test_init_doesNotRequestDataFormURL() {
        let client = HTTPClientSpy()
        _ = makeSUT()

        XCTAssertNil(client.requestedURL, "Expected to return nil")
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // When things are working in collabaration we need to make sure about order, count and equality.
    
    func test_loadTwice_requestsDataFromUrlTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
}

//MARK:- Helper methods

extension RemoteFeedLoaderTests {
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        var requestedURLs = [URL]()

        func get(from url: URL) {
            requestedURL = url
            requestedURLs.append(url)
        }
    }
}
