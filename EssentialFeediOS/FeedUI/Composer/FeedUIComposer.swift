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
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: presenter)
        let feedContoller = FeedViewController(refereshController: refreshController)
        
        // Compose the presenter
        
        presenter.loadingView = refreshController
        presenter.feedView =  FeedViewAdapter(controller: feedContoller, loader: imageLoader)
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
        return feedContoller
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
//            controller?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: loader) }
            
            controller?.tableModel = feed.map { FeedImageCellController(viewModel: FeedImageViewModel(model: $0, imageLoader: loader, imageTransformer: UIImage.init)) }

        }
    }
}

// Same adapter now has been change to an objects as a method can not confirm to a delegate.
// so moving our adapter to an object.

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map { FeedImageCellController(viewModel: FeedImageViewModel(model: $0, imageLoader: loader, imageTransformer: UIImage.init)) }
    }
}
