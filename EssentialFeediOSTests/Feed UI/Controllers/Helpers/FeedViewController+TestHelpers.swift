//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 08/07/22.
//

import Foundation
import UIKit

// MARK: - DSL Helpers

extension FeedViewController {
    var errorMessage: String? {
        return errorView.message
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToReferesh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    private var feedImageSection: Int {
        return 0
    }
    
    func feedImageView(at index: Int = 0) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: index, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)

        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
}
