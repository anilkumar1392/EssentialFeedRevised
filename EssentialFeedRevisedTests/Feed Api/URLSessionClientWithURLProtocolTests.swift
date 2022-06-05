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
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
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
    
    /*
     Data = nil
     URLResponse = nil
     Error = value
     result: delivers failure
     */
    func test_loadFromUrl_failsOnRequestError() {
        /*
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
         */
        
        let requestError = anyError()

        let receivedError = resultErrorFor(nil, nil, requestError) as? NSError
        
        XCTAssertEqual(receivedError?.localizedDescription, requestError.localizedDescription)
        XCTAssertEqual(receivedError?.code, requestError.code)
        XCTAssertEqual(receivedError?.domain, requestError.domain)
    }
    
    /*
     Data = nil
     URLResponse = nil
     Error = nil
     result: delivers failure
     */
    func test_loadFromUrl_failsOnAllNilValues() {
        /*
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
        */
        
        XCTAssertNotNil(resultErrorFor(nil, nil, nil))
    }
    
    /*
     Data = nil
     URLResponse = Value
     Error = nil
     result: delivers failure
     */
    func test_loadFromUrl_failsForAllInvalidCases() {
        let anyData = anyData()
        let anyError = anyError()
        let nonHTTPURLResponse = anyNonHTTPURLResponse()
        let anyHTTPURLResponse = anyHTTPURLResponse()
        
        XCTAssertNotNil(resultErrorFor(nil, nonHTTPURLResponse, nil))
        // XCTAssertNotNil(resultErrorFor(nil, anyHTTPURLResponse, nil))
        /*
         Handled saperately
         */
        XCTAssertNotNil(resultErrorFor(anyData, nil, nil))
        XCTAssertNotNil(resultErrorFor(anyData, nil, anyError))
        XCTAssertNotNil(resultErrorFor(nil, nonHTTPURLResponse, anyError))
        XCTAssertNotNil(resultErrorFor(nil, anyHTTPURLResponse, anyError))
        XCTAssertNotNil(resultErrorFor(anyData, nonHTTPURLResponse, anyError))
        XCTAssertNotNil(resultErrorFor(anyData, anyHTTPURLResponse, anyError))
        XCTAssertNotNil(resultErrorFor(anyData, nonHTTPURLResponse, nil))
    }
    
    func test_loadFromURL_suceedsOnHTTPSURLResponseWithData() {
        /*
        let anyData = anyData()
        let anyHTTPURLResponse = anyHTTPURLResponse()
        let anyUrl = anyURL()
        URLProtocolStub.stub(data: anyData, response: anyHTTPURLResponse, error: nil)

        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load complettion")
        
        sut.get(from: anyUrl) { result in
            switch result {
            case .success(let receivedData, let receivedResponse):
                XCTAssertEqual(receivedData, anyData)
                XCTAssertEqual(receivedResponse.url, anyHTTPURLResponse.url)
                XCTAssertEqual(receivedResponse.statusCode, anyHTTPURLResponse.statusCode)

            default:
                XCTFail("Expected to complete with success, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
         */
        
        let anyData = anyData()
        let anyHTTPURLResponse = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(anyData, anyHTTPURLResponse, nil)
        
        XCTAssertEqual(receivedValues?.data, anyData)
        XCTAssertEqual(receivedValues?.response.url, anyHTTPURLResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, anyHTTPURLResponse.statusCode)
    }
    
    func test_loadFromURL_suceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        /*
        let anyHTTPURLResponse = anyHTTPURLResponse()
        let anyUrl = anyURL()
        URLProtocolStub.stub(data: nil, response: anyHTTPURLResponse, error: nil)

        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load complettion")
        
        sut.get(from: anyUrl) { result in
            switch result {
            case .success(let receivedData, let receivedResponse):
                let emptyData = Data()
                XCTAssertEqual(receivedData, emptyData)
                XCTAssertEqual(receivedResponse.url, anyHTTPURLResponse.url)
                XCTAssertEqual(receivedResponse.statusCode, anyHTTPURLResponse.statusCode)

            default:
                XCTFail("Expected to complete with success, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        */
        
        let anyHTTPURLResponse = anyHTTPURLResponse()
        let receivedValues = resultValuesFor(nil, anyHTTPURLResponse, nil)
        let emptyData = Data()

        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, anyHTTPURLResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, anyHTTPURLResponse.statusCode)

    }
}
 
//MARK: - Helper methods

extension URLSessionHTTPClinetURLProtocolTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClientURLSession {
        let sut = HTTPClientURLSession()
        trackForMemoryLeak(sut)
        return sut
    }
    
    func anyURL() -> URL {
        return URL(string: "Http://any-url.com")!
    }
    
    func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    func anyError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    func anyNonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func resultErrorFor(_ data: Data?, _ response: URLResponse?, _ error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        /*
        let url = anyURL()
        let sut = makeSUT(file: file, line: line)
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedError: Error?
        sut.get(from: url) { result in
            switch result {
            case .failure(let error):
                receivedError = error
                
            default:
                XCTFail("Expected to complete with error got \(result) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
         */
        
        
        let receivedResult = resultFor(data, response, error)
        var receivedError: Error?

        switch receivedResult {
        case .failure(let error):
            receivedError = error
            
        default:
            XCTFail("Expected to complete with error got \(receivedResult) instead", file: file, line: line)
        }
        
        return receivedError
    }
    
    func resultValuesFor(_ data: Data?, _ response: URLResponse?, _ error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        /*
        let url = anyURL()
        let sut = makeSUT(file: file, line: line)
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedData: (data: Data, response: HTTPURLResponse)?
        sut.get(from: url) { result in
            switch result {
            case .success(let data, let response):
                receivedData = (data, response)

            default:
                XCTFail("Expected to complete with error got \(result) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0) */
        
        let receivedResult = resultFor(data, response, error)
        var receivedData: (data: Data, response: HTTPURLResponse)?

        switch receivedResult {
        case .success(let data, let response):
            receivedData = (data, response)
        case .failure(let error):
            XCTFail("Expected success got \(error) instead", file: file, line: line)
        }
        return receivedData
    }
    
    func resultFor(_ data: Data?, _ response: URLResponse?, _ error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)

        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: HTTPClientResult!
        sut.get(from: anyURL()) { result in
            receivedResult = result
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
        return receivedResult
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
