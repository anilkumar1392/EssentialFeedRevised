//
//  CodableFeedStoreTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 17/06/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
        completion(.empty)
    }
}
 
class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliverEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrival")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected empty result, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
