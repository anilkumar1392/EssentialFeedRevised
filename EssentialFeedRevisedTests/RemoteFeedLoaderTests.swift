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
 
 Stubs can be easily replaced with Capture that is a better one.
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
    
    // Writing test to test cleint failure
    // No connectivity
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError, at: 0)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    // Invalid data error course
    func test_load_deliverErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 210, 300, 400 , 500]
        samples.enumerated().forEach { (index, code) in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0) }
            client.complete(with: code, at: index)
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
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

        private var messages = [(url: URL, completions: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completions(.failure(error))
        }

        func complete(with statusCode: Int, at index: Int = 0) {
            let httpsResponse = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)!
            
            messages[index].completions(.success(httpsResponse))
        }
         
    }
}
