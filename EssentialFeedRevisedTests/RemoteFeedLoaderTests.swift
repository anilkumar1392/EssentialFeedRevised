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
 Lecture 1.
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

/*
 Lecture 2.
 Asserting a Captured Value Is Not Enough + Cross-Module Access Control
 
 Learning Outcomes
 Understand the trade-offs of access control for testing purposes
 Expand behavior checking (and coverage) using test spy objects
 
 Test visibility: public vs @testable (internal)
 We start by moving the RemoteFeedLoader class and the HTTPClient protocol to a new production file to facilitate our development workflow. By doing so, our test target doesn’t have access to our internal types anymore; thus we need to decide whether we will make our types public or leave them as internal and add the @testable attribute when importing our production module in the tests. We decided the former as we can test the Feed API module through the public interfaces it contains so that we can test the expected behavior as a client of the module. Another benefit of this approach is that we can now make changes to any internal or private implementation details without breaking our tests.
 
 */

/*
 Lecture 3.
 Handling Errors + Stubbing vs. Spying + Eliminating Invalid Paths
 */

class RemoteFeedLoaderTests: XCTestCase {
    
    /* test_method_behaviorWeExpect */
    
    func test_init_doesNotRequestDataFormURL() {
        let client = HTTPClientSpy()
        _ = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty, "Expected to return nil")
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    // When things are working in collabaration we need to make sure about order, count and equality.
    
    func test_loadTwice_requestsDataFromUrlTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)
        
        var capturedError: RemoteFeedLoader.Error?
        
        sut.load { error in
            capturedError = error
        }
        
        XCTAssertEqual(capturedError, .connectivity)
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
        
        var requestedURLs = [URL]()
        var error: Error?

        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requestedURLs.append(url)
        }

    }
}
