//
//  FeedImageDataLoaderTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 09/07/22.
//

import Foundation
import XCTest
import EssentialFeediOS

final class RemoteFeedImageDataLoader {

    init(client: Any) {
        
    }
    
}

class FeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_ , loader) = makeSUT()
        
        XCTAssertEqual(loader.requestedURLs, [])
    }
}

extension FeedImageDataLoaderTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, loader: HTTPClientSpy){
        let loader = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }
}


extension FeedImageDataLoaderTests {
    class HTTPClientSpy {
        var requestedURLs = [URL]()
    }
}
 

/*
---

### Load Feed Image Data From Remote Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System delivers image data.

#### Cancel course:
1. System does not deliver image data nor error.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

---
*/
