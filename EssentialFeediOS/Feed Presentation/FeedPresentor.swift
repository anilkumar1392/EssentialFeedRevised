//
//  FeedPresentor.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 06/07/22.
//

import Foundation

protocol FeedLoadingView: AnyObject {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var feedView: FeedView?
    weak var loadingView: FeedLoadingView?

    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.feedView?.display(feed: feed)
            case .failure:
                break
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
