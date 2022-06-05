//
//  URLSessionClientWithURLProtocolTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 05/06/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

/*
 URLProtocol stub based test.
 */

class HTTPClientURLSession {
    let session : URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValueRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }.resume()
    }
}


class URLSessionHTTPClinetURLProtocolTests: XCTestCase {
    
    override func setUp() {
        URLProtocolStub.startInterseptingRequest()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterseptingRequest()
    }
    
    // Request data form the provided URL.
    // 1. Requested URl
    func test_loadFromURL_performGetRequestWithURL() {
        
        let url = anyURL()
        let exp = expectation(description: "Wait for load completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")

            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }

        wait(for: [exp], timeout: 5.0)
    }
    
    /*
     We can use the same technique to test POST requests and also investigate the body of the request and query.
     */
    
    
    // failed request with an error
    // 2. handling the requested error.
    func test_loadFromUrl_failsOnRequestError() {
        let url = anyURL()
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
                
        let exp = expectation(description: "Wait for load completion")
        
        makeSUT().get(from: url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError.localizedDescription, error.localizedDescription)
                XCTAssertEqual(receivedError.code, error.code)
                XCTAssertEqual(receivedError.domain, error.domain)


            default:
                XCTFail("Expected to complete with \(error), got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
    
    /*
     Data = nil
     URLResponse = nil
     Error = nil
     */
    func test_loadFromUrl_failsOnAllNilValues() {
        let url = anyURL()
        let sut = makeSUT()
        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.get(from: url) { result in
            switch result {
            case .failure:
                break
                
            default:
                XCTFail("Expected to complete with error got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
}
 
//MARK: - Helper methods

extension URLSessionHTTPClinetURLProtocolTests {
    func makeSUT() -> HTTPClientURLSession {
        let sut = HTTPClientURLSession()
        trackForMemoryLeak(sut)
        return sut
    }
    
    func anyURL() -> URL {
        return URL(string: "Http://any-url.com")!
    }
}

extension URLSessionHTTPClinetURLProtocolTests {
    private class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub? // [URL: Stub]()
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func startInterseptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterseptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            // stub = [:]
            stub = nil
            requestObserver = nil
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            // stub[url] = Stub(data: data, response: response, error: error)
            stub = Stub(data: data, response: response, error: error)
        }
        
        // Return status if you can handle it.
        /*
         we never want to make any api calls so we are intercepting all the calls.
         and second we wnat to ake assertion very precise
         */
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
            /*
            guard let url = request.url else { return false }
            
            return stub[url] != nil */
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            // guard let url = request.url, let stub = URLProtocolStub.stub[url] else { return }
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
}
