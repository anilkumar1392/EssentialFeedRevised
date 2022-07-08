//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 04/07/22.
//

import Foundation
import UIKit

final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        // let refreshController = FeedRefreshViewController(loadFeed: presentationAdapter.loadFeed)
        // let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        // Create refresh control With Storyboard

        
        // With code
        // let feedContoller = FeedViewController(refereshController: refreshController)
        let feedController = FeedViewController.makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title)
        
        //feedContoller.refreshController = refreshController
        
        // Compose the presenter
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(
                controller: feedController,
                imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            loadingView:  WeakRefVirtualProxy(feedController))

        /*
        refreshController.onRefresh = { [weak feedContoller] feed in
            feedContoller?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: imageLoader) }
        } */
        
        // can be done
        // refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedContoller, loader: imageLoader)
        // viewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedContoller, loader: imageLoader)
        
        // closure here we may fine it odd but that'a the adapter pattern. it is very common in composer types to adapt unmatching types.
        
        //1. Refresh controller delegates array of 'FeedImages' but the 'FeedViewController' ecpects array of 'FeedImageCellController'
        // So while composing types the adapter pattern conenct a matching api's.
        
        // [FeedImages] -> Adapts -> [FeedImageCellController]
        
        // To keep the responsibilty of creating dependencies away from types that uses the dependencies.
        
        // We can even move it to a separate function to clarify the intent.
        return feedController
    }
    
    /*
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
//            controller?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: loader) 
            
            controller?.tableModel = feed.map { FeedImageCellController(viewModel: FeedImageViewModel(model: $0, imageLoader: loader, imageTransformer: UIImage.init)) }

        }
    } */
}

extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        // With Storyboard
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedContoller = storyboard.instantiateInitialViewController() as! FeedViewController
        // let refreshController = feedContoller.refreshController!
        // refreshController.delegate = presentationAdapter
        
        feedContoller.delegate = delegate
        feedContoller.title = title
        return feedContoller
    }
}

// Same adapter now has been change to an objects as a method can not confirm to a delegate.
// so moving our adapter to an object.

/*
final class FeedViewAdapter: FeedView { 
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { FeedImageCellController(viewModel: FeedImageViewModel(model: $0, imageLoader: loader, imageTransformer: UIImage.init)) }
    }
} */

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    // Here FeedImageDataLoaderAdapter is an adapter
    // 1. it has ref to a presenter and some load image api call.
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)

            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)

            return view
        }
    }
    
}


