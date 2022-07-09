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

class FeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_ , loader) = makeSUT()
        
        XCTAssertEqual(loader.requestedURLs, [])
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = anyURL()
        let (sut, loader) = makeSUT(url: url)
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requetsDataFromURLTwice() {
        let url = anyURL()
        let (sut, loader) = makeSUT(url: url)
        
        _ = sut.loadImageData(from: url) { _ in }
        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(loader.requestedURLs, [url, url])
    }
    
    // Connectivity error
    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
        let clientError = NSError(domain: "a client error", code: 0)
        let (sut, loader) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.connectivity)) {
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
    
    func test_loadImageDataFromURL_delviersReceivedNonEmptyDataOn200HttpResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("any data".utf8)

        expect(sut: sut, toCompleteWith: .success(nonEmptyData)) {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }
}

// MARK: - Deallocated after instance has been deallocated

extension FeedImageDataLoaderTests {
    func test_loadImageDataFromURL_doesNotDelviverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var capturedResults = [FeedImageDataLoader.Result]()
        
        _ = sut?.loadImageData(from: anyURL(), completion: { capturedResults.append($0) })
        
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
}

// MARK: - Cancel get from URLTask cancels URL request

extension FeedImageDataLoaderTests {
    func test_canceLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()

        let task = sut.loadImageData(from: anyURL()) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expeceted no cancelled url until task are cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expeceted cancelled url after task is cancelled")
    }
    
    func test_cancelLoadImageDataTask_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()
        
        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyError())

        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }
}

extension FeedImageDataLoaderTests {
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, loader: HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private func expect(sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "Wait for load completion...")
        
        _ = sut.loadImageData(from: url) { receivedResult in
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


/*
extension FeedImageDataLoaderTests {
    
    class HTTPClientSpy: HTTPClient {
        private struct Task: HTTPClientTask {
            let callback: () -> Void
            func cancel() { callback() }
        }
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        private(set) var cancelledURLs = [URL]()

        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
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
 */
 

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
 {
 1. Delivers error on non 200 HTTPResponse
 2. Delivers error on emptyData with 200 HTTP response
 }

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

---
*/
