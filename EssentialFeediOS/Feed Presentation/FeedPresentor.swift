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
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    /*
     1. 
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    } */
    
    func didStartLoadingFeed() {
        self.loadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        self.feedView?.display(FeedViewModel(feed: feed))
        self.loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLaodingFeed(with error: Error) {
        self.loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
}

