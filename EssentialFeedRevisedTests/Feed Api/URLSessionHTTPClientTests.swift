//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 05/06/22.
//

import Foundation
import XCTest

class HTTPClieURLSessionHttpClinet {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

class URLSessionHTTPClinetTests: XCTestCase {
    func test_loadFromURL_createsDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let sut = HTTPClieURLSessionHttpClinet(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.requestedURLs, [url])
    }
    
    func test_loadFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, with: task)
        
        let sut = HTTPClieURLSessionHttpClinet(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
}

extension URLSessionHTTPClinetTests {
    class URLSessionSpy: URLSession {
        var requestedURLs = [URL]()
        private var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, with task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {
        }
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}