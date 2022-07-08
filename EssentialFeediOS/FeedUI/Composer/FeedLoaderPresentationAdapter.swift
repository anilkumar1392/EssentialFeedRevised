//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 08/07/22.
//

import Foundation

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case let.success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)

            case let .failure(error):
                self?.presenter?.didFinishLaodingFeed(with: error)
            }
        }
    }
}
