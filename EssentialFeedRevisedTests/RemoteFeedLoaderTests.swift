//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 26/05/22.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFormURL() {
        let client = HTTPClient()
        let _ = RemoteFeedLoader()
                
        XCTAssertNil(client.requestedURL, "Expected to return nil")
    }
}
