//
//  URLProtocolStub.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 09/07/22.
//

import Foundation

class URLProtocolStub: URLProtocol {
    
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
