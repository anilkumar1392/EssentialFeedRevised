//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 26/05/22.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    private init() {}
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFormURL() {
        let client = HTTPClient.shared
        let _ = RemoteFeedLoader()
                
        XCTAssertNil(client.requestedURL, "Expected to return nil")
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
