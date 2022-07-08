//
//  FeedPresentor.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 06/07/22.
//

import Foundation

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    var feedView: FeedView
    var loadingView: FeedLoadingView
    private let errorView: FeedErrorView

    /*
     1. 
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    } */
    
    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
             tableName: "Feed",
             bundle: Bundle(for: FeedPresenter.self),
             comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    func didStartLoadingFeed() {
        errorView.display(FeedErrorViewModel(message: nil))
        self.loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        self.feedView.display(FeedViewModel(feed: feed))
        self.loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLaodingFeed(with error: Error) {
        errorView.display(FeedErrorViewModel(message: feedLoadError))
        self.loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}

