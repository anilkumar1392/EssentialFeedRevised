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
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        // let refreshController = FeedRefreshViewController(loadFeed: presentationAdapter.loadFeed)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)

        let feedContoller = FeedViewController(refereshController: refreshController)
        
        // Compose the presenter
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedContoller, imageLoader: imageLoader),
            loadingView:  WeakRefVirtualProxy(refreshController))

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
    
    /*
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
//            controller?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: loader) 
            
            controller?.tableModel = feed.map { FeedImageCellController(viewModel: FeedImageViewModel(model: $0, imageLoader: loader, imageTransformer: UIImage.init)) }

        }
    } */
}

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
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

final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case let.success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)

            case let .failure(error):
                self?.presenter?.didFinishLaodingFeed(with: error)
            }
        }
    }
}


// MVP for FeedImageDataLoader

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    var presenter: FeedImagePresenter<View, Image>?

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)

        let model = self.model
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)

            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }

    func didCancelImageRequest() {
        task?.cancel()
    }
}
