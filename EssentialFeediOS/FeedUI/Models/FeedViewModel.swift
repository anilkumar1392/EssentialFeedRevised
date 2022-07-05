//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 05/07/22.
//

import Foundation

final class FeedViewModel {
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    private enum State {
        case pending
        case loading
        case loaded([FeedImage])
        case failed
    }
    
    private var state = State.pending {
        didSet { onChange?(self) }
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    
    var isLoading: Bool {
        switch state {
        case .loading: return true
        default: return false
        }
    }
    
    var feed: [FeedImage]? {
        switch state {
        case .loaded(let feed): return feed
        default: return nil
        }
    }
    
    func loadFeed() {
        state = .loading
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.state = .loaded(feed)
            case .failure:
                self?.state = .failed
            }
        }
    }
}
