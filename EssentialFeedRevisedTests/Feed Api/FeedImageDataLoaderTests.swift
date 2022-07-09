//
//  FeedImageDataLoaderTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 09/07/22.
//

import Foundation
import XCTest
import EssentialFeedRevised
import EssentialFeediOS

final class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case let .failure(error): completion(.failure(error))
            default: break
            }
        })
    }
}

class FeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_ , loader) = makeSUT()
        
        XCTAssertEqual(loader.requestedURLs, [])
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = anyURL()
        let (sut, loader) = makeSUT(url: url)
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requetsDataFromURLTwice() {
        let url = anyURL()
        let (sut, loader) = makeSUT(url: url)
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(loader.requestedURLs, [url, url])
    }
    
    // Connectivity error
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let clientError = anyError()
        let (sut, loader) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .failure(clientError)) {
            loader.complete(with: clientError)
        }
        
        /*
        let exp = expectation(description: "Wait for load completion...")
        sut.loadImageData(from: anyURL()) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got \(result) instead.")
                
            case let .failure(error):
                XCTAssertEqual(error as NSError, clientError)
            }
            
            exp.fulfill()
        }
        
        loader.complete(with: clientError)

        wait(for: [exp], timeout: 1.0)
         */
    }
}

extension FeedImageDataLoaderTests {
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, loader: HTTPClientSpy){
        let loader = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }
    
    private func expect(sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "Wait for load completion...")
        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expeceted to complete with \(expectedResult), Got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}


extension FeedImageDataLoaderTests {
    class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var completions = [(HTTPClientResult) -> Void]()

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            requestedURLs.append(url)
            completions.append(completion)
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}
 

/*
---

### Load Feed Image Data From Remote Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System delivers image data.

#### Cancel course:
1. System does not deliver image data nor error.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

---
*/
