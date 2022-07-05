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
    
//    private enum State {
//        case pending
//        case loading
//    }
//
//    private var state = State.pending {
//        didSet { onChange?(self) }
//    }
    
    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
//    var feed: [FeedImage]? {
//        switch state {
//        case .loaded(let feed): return feed
//        default: return nil
//        }
//    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                 self?.onFeedLoad?(feed)
            case .failure:
                break
            }
            self?.isLoading = false
        }
    }
}
