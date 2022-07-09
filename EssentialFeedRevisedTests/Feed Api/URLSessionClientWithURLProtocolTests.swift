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

class URLSessionHTTPClinetURLProtocolTests: XCTestCase {
    
//    override func setUp() {
//        URLProtocolStub.startInterseptingRequest()
//    }
//
//    override func tearDown() {
//        URLProtocolStub.stopInterseptingRequest()
//    }
    
    override func tearDown() {
        super.tearDown()

        URLProtocolStub.removeStub()
    }
    
    // Request data form the provided URL.
    // 1. Requested URl
    func test_loadFromURL_performGetRequestWithURL() {
        
        let url = anyURL()
        // let urlRequest = URLRequest(url: anyURL())

        let exp = expectation(description: "Wait for load completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")

            exp.fulfill()
        }

        makeSUT().get(from: url) { _ in }

        wait(for: [exp], timeout: 1.0)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?

        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
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
    func test_getFromURL_failsOnRequestError() {
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

        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError)) as NSError?

        XCTAssertEqual(receivedError?.code, requestError.code)
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
        
        XCTAssertNotNil(resultErrorFor(_:taskHandler:file:line:))
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
        
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse, error: nil)))

        /*
         Handled saperately
         */
        /*
        XCTAssertNotNil(resultErrorFor(anyData, nil, nil))
        XCTAssertNotNil(resultErrorFor(anyData, nil, anyError))
        XCTAssertNotNil(resultErrorFor(nil, nonHTTPURLResponse, anyError))
        XCTAssertNotNil(resultErrorFor(nil, anyHTTPURLResponse, anyError))
        XCTAssertNotNil(resultErrorFor(anyData, nonHTTPURLResponse, anyError))
        XCTAssertNotNil(resultErrorFor(anyData, anyHTTPURLResponse, anyError))
        XCTAssertNotNil(resultErrorFor(anyData, nonHTTPURLResponse, nil))
        */
        
        XCTAssertNotNil(resultErrorFor((data: anyData, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: nil, error: anyError)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse, error: anyError)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse, error: anyError)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: nonHTTPURLResponse, error: anyError)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: anyHTTPURLResponse, error: anyError)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: nonHTTPURLResponse, error: anyError)))

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
        
        // let receivedValues = resultValuesFor(anyData, anyHTTPURLResponse, nil)
        let receivedValues = resultValuesFor((data: anyData, response: anyHTTPURLResponse, error: nil))

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
        
        let response = anyHTTPURLResponse()
        // let receivedValues = resultValuesFor(nil, anyHTTPURLResponse, nil)
        let receivedValues = resultValuesFor((data: nil, response: response, error: nil))

        let emptyData = Data()

        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)

    }
}
 
//MARK: - Helper methods

extension URLSessionHTTPClinetURLProtocolTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClientURLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = HTTPClientURLSession(session: session)
        trackForMemoryLeaks(sut)
        return sut
    }

    func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(values, file: file, line: line)
        
        switch result {
        case .success(let data, let response):
            return (data, response)
            
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #file, line: UInt = #line) -> Error? {

        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)

        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in },  file: StaticString = #file, line: UInt = #line) -> HTTPClient.Result {

        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }

        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClient.Result!
        taskHandler(sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    func anyNonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}

extension URLSessionHTTPClinetURLProtocolTests {
    private class URLProtocolStub: URLProtocol {
        
//        private static var stub: Stub? // [URL: Stub]()
//        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestReceiver: ((URLRequest) -> Void)?
        }
        
        private static var _stub: Stub?
        private static var stub: Stub? {
            get { return queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }
        
        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

//        static func startInterseptingRequest() {
//            URLProtocol.registerClass(URLProtocolStub.self)
//        }
//
//        static func stopInterseptingRequest() {
//            URLProtocol.unregisterClass(URLProtocolStub.self)
//            // stub = [:]
//            stub = nil
//            // requestObserver = nil
//        }
        
        static func removeStub() {
            stub = nil
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            // stub[url] = Stub(data: data, response: response, error: error)
            // stub = Stub(data: data, response: response, error: error)
            stub = Stub(data: data, response: response, error: error, requestReceiver: nil)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            // requestObserver = observer
            stub = Stub(data: nil, response: nil, error: nil, requestReceiver: observer)
        }
        
        // Return status if you can handle it.
        /*
         we never want to make any api calls so we are intercepting all the calls.
         and second we wnat to ake assertion very precise
         */
        override class func canInit(with request: URLRequest) -> Bool {
            // requestObserver?(request)
            print("request -----\(request)")
            return true
            
            /*
            guard let url = request.url else { return false }
            
            return stub[url] != nil */
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            print("request -----\(request)")
            return request
        }
        
        override func startLoading() {
            // guard let url = request.url, let stub = URLProtocolStub.stub[url] else { return }
            
//            if let requestObserver = URLProtocolStub.requestObserver {
//                client?.urlProtocolDidFinishLoading(self)
//                return requestObserver(request)
//            }
            
            guard let stub = URLProtocolStub.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
            
            stub.requestReceiver?(request)
        }
        
        override func stopLoading() {
            
        }
    }
}
