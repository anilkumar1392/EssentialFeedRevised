//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 04/07/22.
//

import Foundation
import UIKit

// The idea here is one controller per cell.

// replace MVC implementation with MVVM for cell controller.
// MARK: - MVVM Version

public final class FeedImageCellController {
    private var viewModel: FeedImageViewModel<UIImage>
    private var task: FeedImageDataLoaderTask?
    
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }
    
    private func binded(_ cell: FeedImageCell) -> UITableViewCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageData

        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }

        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }

        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }

        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelLoad()
    }
}


// MARK: - MVC Version
/*
public final class FeedImageCellController {
    private var task: FeedImageDataLoaderTask?
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.locationContainer.isHidden = (model.location == nil)
        cell.feedImageView.image = nil
        cell.feedImageContainer.startShimmering()
        cell.feedImageRetryButton.isHidden = true

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.task = self.imageLoader.loadImageData(from: self.model.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    func preload() {
        task = self.imageLoader.loadImageData(from: self.model.url) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
 */
