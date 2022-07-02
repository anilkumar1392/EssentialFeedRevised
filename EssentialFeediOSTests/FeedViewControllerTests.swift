//
//  FeedViewControllerTests.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 02/07/22.
//

import Foundation
import XCTest
import UIKit
import EssentialFeedRevised

final class FeedViewController: UIViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load(completion: { _ in })
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loaderCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loaderCallCount, 1)
    }    
}

extension FeedViewControllerTests {
    final class LoaderSpy: FeedLoader {
        private(set) var loaderCallCount: Int = 0

        func load(completion: @escaping (LoadFeedResult) -> Void) {
            loaderCallCount += 1
        }
    }
}

