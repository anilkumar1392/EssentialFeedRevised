//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 04/07/22.
//

import Foundation
import UIKit

// MARK: - MVP

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) public lazy var view = loadView()

    private let presenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }

    @objc func refresh() {
        presenter.loadFeed()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

// MARK: - MVVM
/*
public final class FeedRefreshViewController: NSObject {
    private(set) public lazy var view = binded(UIRefreshControl())

    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    // var onRefresh: (([FeedImage]) -> Void)?
    // Moving on refresh to viewModel to make FeedRefreshViewController decouple from FeedImage.
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }

        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
        
        // We are not doing this because this will lead to viewModel confirm to NSObject and thatis a leaky implementation.
        // view.addTarget(viewModel, action: #selector(loadFeed), for: .valueChanged)

    }
}
 */



// MARK: - MVC VERSION

/*
public final class FeedRefreshViewController: NSObject {
    private(set) public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.onRefresh?(feed)
                
            case .failure:
                break
            }
            self?.view.endRefreshing()
        }
    }
}
*/
