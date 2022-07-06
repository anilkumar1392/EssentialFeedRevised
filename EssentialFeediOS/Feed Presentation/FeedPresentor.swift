//
//  FeedPresentor.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 06/07/22.
//

import Foundation

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var feedView: FeedView?
    var loadingView: FeedLoadingView?

    func loadFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.feedView?.display(FeedViewModel(feed: feed))
            case .failure:
                break
            }
            self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
