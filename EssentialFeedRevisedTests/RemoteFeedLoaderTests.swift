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
 Learning Outcomes
 Handling network errors
 Differences between stubbing and spying when unit testing
 How to extend code coverage by using samples of values to test specific test cases
 Design better code with enums to make invalid paths unrepresentable
 
 */

/*
 Lecture 4.
 A Classicist TDD Approach (No Mocking) to Mapping JSON with Decodable + Domain-Specific Models
 Learning Outcomes
 Differences and trade-offs between mocking vs. testing collaborators in integration
 Mapping JSON data to native models using the Decodable protocol
 How to protect your architecture abstractions by working with domain-specific models
 How to simplify tests leveraging factory methods and test helper functions
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
    
    // Writing test to test client failure
    // Handling all the HTTP client errors.
    
    // No connectivity
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError, at: 0)
        }
    }
    
    // Invalid data error course
    func test_load_deliverErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 210, 300, 400 , 500]
        samples.enumerated().forEach { (index, code) in
            expect( sut, toCompleteWith: .failure(.invalidData)) {
                let json = makeItemJson([])
                client.complete(with: code, data: json, at: index)
            } 
        }
    }
    
    // Writing test for Parsing json
    
    func test_load_deliversErrorOn200HttpsReponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJson = Data(bytes: "Invalid json".utf8)
            client.complete(with: 200, data: invalidJson, at: 0)
        }
    }
    
    func test_load_deliversNoItemsOn200HttpsResponseWithEmptyJsonList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([])) {
            let emptyListJson = Data(bytes: "{\"items\": []}".utf8)
            client.complete(with: 200, data: emptyListJson)
        }
    }
    
    func test_load_deliversFeedImagesOn200HttpsResponseWithjsonList() {
        let (sut, client) = makeSUT()
        
        let (item1, item1json) = makeItem(
            id: UUID(),
            image: URL(string: "https://a-url.com")!)

        let (item2, item2json) = makeItem(
            id: UUID(),
            description: "a description",
            location: "a lcoation",
            image: URL(string: "https://a-url.com")!)
        
        expect(sut, toCompleteWith: .success([item1, item2])) {
            let json = makeItemJson([item1json, item2json])
            client.complete(with: 200, data: json)
        }
    }
    
    // Thread
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader?  = RemoteFeedLoader(url: url, client: client)
        
        var capturedResult = [RemoteFeedLoader.Result]()
        sut?.load { result in
            capturedResult.append(result)
        }
        
        sut = nil
        client.complete(with: 200, data: makeItemJson([]))
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
}

//MARK:- Helper methods

extension RemoteFeedLoaderTests {
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeak(sut)
        trackForMemoryLeak(client)
        return (sut, client)
    }
    
    private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, Potential memory leak.", file: file, line: line)
        }
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
    
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, image: URL) -> (model: FeedImage, json: [String: Any]){
        let item = FeedImage(id: id, description: description, location: location, imageURL: image)
        let json = [
            "id" : id.uuidString,
            "description": description,
            "location": location,
            "image": image.absoluteString
        ].reduce(into: [String: Any]()) { dict, e in
            if let value = e.value { dict[e.key] = value }
        }
        return (item, json)
    }
    
    private func makeItemJson(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
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

        func complete(with statusCode: Int, data: Data, at index: Int = 0) {
            let httpsResponse = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)!
            
            messages[index].completions(.success(data, httpsResponse))
        }
         
    }
}
