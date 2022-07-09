//
//  FeedImageDataLoaderTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 09/07/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

final class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (Any) -> Void) {
        client.get(from: url, completion: { _ in })
    }
}

class FeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_ , loader) = makeSUT()
        
        XCTAssertEqual(loader.requestedURLs, [])
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = anyURL()
        let (sut , loader) = makeSUT(url: url)
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requetsDataFromURLTwice() {
        let url = anyURL()
        let (sut , loader) = makeSUT(url: url)
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(loader.requestedURLs, [url, url])
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
}


extension FeedImageDataLoaderTests {
    class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            requestedURLs.append(url)
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
