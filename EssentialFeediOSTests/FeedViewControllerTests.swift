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
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loaderCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loaderCallCount, 1)
    }    
}

extension FeedViewControllerTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
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

