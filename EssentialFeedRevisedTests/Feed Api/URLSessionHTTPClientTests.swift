//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 05/06/22.
//

import Foundation
import XCTest
import EssentialFeedRevised
/*
 Approach to test HTTPClient
 
 1. End-to-end testing
 2. Subclass based mocking
 2. Protocol based mocking
 */

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class HTTPClientURLSessionHttpClinet {
    let session: HTTPSession //URLSession
    
    init(session: HTTPSession) { // URLSession
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClinetTests: XCTestCase {
    /*
    func test_loadFromURL_createsDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let sut = HTTPClientURLSessionHttpClinet(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(session.requestedURLs, [url])
    } */
    
    func test_loadFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, with: task)
        
        let sut = HTTPClientURLSessionHttpClinet(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // Now test behaviour
    
    func test_loadFromUrl_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "Any error", code: 1)
        session.stub(url: url, error: error)
        
        let sut = HTTPClientURLSessionHttpClinet(session: session)
        
        let exp = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(error, receivedError)
            default:
                XCTFail("Expecetd to comlete with \(error), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
    }
}

extension URLSessionHTTPClinetTests {
    
    class URLSessionSpy: HTTPSession { // URLSession
        var requestedURLs = [URL]()
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask // URLSessionDataTask
            let error: Error?
        }
        
//        func stub(url: URL, with task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
//            stubs[url] = Stub(task: task, error: error)
//        }
        
        func stub(url: URL, with task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask  { // URLSessionDataTask
            requestedURLs.append(url)
            guard let stub = stubs[url] else {
                fatalError("Could not find the stub for given \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: HTTPSessionTask { //URLSessionDataTask
        func resume() {
        }
    }
    
    private class URLSessionDataTaskSpy: HTTPSessionTask { // URLSessionDataTask
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}
