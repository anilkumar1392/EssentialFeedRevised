//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 04/07/22.
//

import Foundation

final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let viewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: viewModel)
        let feedContoller = FeedViewController(refereshController: refreshController)
        /*
        refreshController.onRefresh = { [weak feedContoller] feed in
            feedContoller?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: imageLoader) }
        } */
        
        // can be done
        // refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedContoller, loader: imageLoader)
        viewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedContoller, loader: imageLoader)
        
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
            
            controller?.tableModel = feed.map { FeedImageCellController(viewModel: FeedImageViewModel(model: $0, imageLoader: loader)) }

        }
    }
}
