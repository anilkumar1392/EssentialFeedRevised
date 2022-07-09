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
    
    public enum Error: Swift.Error {
        case invalidData
        case clientError
    }
    
//    private struct HTTPTaskWrapper: FeedImageDataLoaderTask {
//        let wrapped: HTTPClientTask
//
//        func cancel() {
//            wrapped.cancel()
//        }
//    }
    
    // @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case let .success(_, _):
                completion(.failure(Error.invalidData))
            case .failure:
                completion(.failure(Error.clientError))
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
        let clientError = NSError(domain: "a client error", code: 0)
        let (sut, loader) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.clientError)) {
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
    
    // Invalid data on non 200 Https response
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorONNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut: sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
    }
    
    func test_loadImageDataFromURL_deliversErrorOn200HttpsResponseWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut: sut, toCompleteWith: failure(.invalidData)) {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        }
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
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private func expect(sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "Wait for load completion...")
        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
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
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        var cancelledURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
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
