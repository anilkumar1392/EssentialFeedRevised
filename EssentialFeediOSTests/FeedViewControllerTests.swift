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

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load(completion: { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        })
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    // MARK: - Load feed automatically when view is presented
    
    /*
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loaderCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loaderCallCount, 1)
    }
     */
    
    //MARK: - Allow customer to manually reload feed (pull to refresh)
    
    /*
     The refresh control is an implementation detail it would be better to hide it from the tests.
     As always it's always a good idea to decouple implementation details from tests.
     */
    
    /*
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loaderCallCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loaderCallCount, 3)
    } */
    
    // We are merging them because they are creating temporal coupling.
    /*
     like our third test depends on viewDidLoad to call loadFeed()
     because of which we are checking for loaderCallCount from 2, because we know loaderCallCount is 1 in previous test this is called temporal coupling.
     
     So to remove temporal coupling we have merged similar kind of tests.
     */
    
    func test_userInitiatedFeedReload_loadsFeed() {
        // test_pullToRefresh_loadsFeed
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loaderCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loaderCallCount, 1)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loaderCallCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loaderCallCount, 3)
    }

    //MARK: - Show a loading indicator while loading feed
    
    // Same temporal coupling is in the loading indicator so let;s couple them to.
    func test_loadingFeedIndicator_isVisibleWhenLoadingFeed() {
        //test_viewDidLoad_showsLoadingIndicator
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoading(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    /*
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_userInitiatedFeedReload_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    }
    
    func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
     */
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
        private var completions = [(LoadFeedResult) -> Void]()
        
        var loaderCallCount: Int {
            return completions.count
        }

        func load(completion: @escaping (LoadFeedResult) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int = 0) {
            completions[index](.success([]))
        }
    }
}

private extension FeedViewController {
    // DSL's
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToReferesh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
}

extension UIRefreshControl {
    func simulatePullToReferesh() {
        allTargets.forEach({ target in
            actions(forTarget: target,
                    forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        })
    }
}
