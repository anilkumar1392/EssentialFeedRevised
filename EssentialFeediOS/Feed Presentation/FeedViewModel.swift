//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 05/07/22.
//

import Foundation

struct FeedViewModel {
    let feed: [FeedImage]
}

/*
final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?

    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                 self?.onFeedLoad?(feed)
            case .failure:
                break
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
*/
