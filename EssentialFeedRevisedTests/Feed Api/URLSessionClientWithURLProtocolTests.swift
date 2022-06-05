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
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let url = URL(string: "http://wrongurl.com")!
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}


class URLSessionHTTPClinetURLProtocolTests: XCTestCase {
    
    // failed request with an error
    
    func test_loadFromUrl_failsOnRequestError() {
        URLProtocolStub.startInterseptingRequest()
        let url = URL(string: "Http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let sut = HTTPClientURLSession()
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.get(from: url) { result in
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
        URLProtocolStub.stopInterseptingRequest()
    }
}
 
extension URLSessionHTTPClinetURLProtocolTests {
    private class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub? //[URL: Stub]()
        
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
