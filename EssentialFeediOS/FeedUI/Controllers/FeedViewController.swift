//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 02/07/22.
//

import Foundation
import UIKit

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    // private var feedLoader: FeedLoader?
    
    // var refreshController: FeedRefreshViewController?
    // FeedRefreshViewController is created by the storyboard as well.
    // we need to create an outlet as well we need to create an outler.
    // @IBOutlet var refreshController: FeedRefreshViewController?
    var delegate: FeedViewControllerDelegate?
    
    // private var imageLoader: FeedImageDataLoader?
    // private var cellControllers = [IndexPath: FeedImageCellController]()

    /*
    private var tableModel = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    } */
    
    var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
    /*
    convenience init(refereshController: FeedRefreshViewController) {
        self.init()
        self.refreshController = refereshController
        // self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        // self.imageLoader = imageLoader
        /*
        self.refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: imageLoader) }
        } */
    } */
    
    public override func viewDidLoad() {
        super.viewDidLoad()
         
        // refreshControl = refreshController?.view
        // tableView.prefetchDataSource = self
        refresh()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // cellController(forRowAt: indexPath).view()
        return tableModel[indexPath.row].view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // cancelTask(forRowAt: indexPath) // responsibilty moved to cellController
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            // Passing this responsibilty to cell controlelr
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
        
        /*
        let cellModel = tableModel[indexPath.row]
        let cellController =  FeedImageCellController(model: cellModel, imageLoader: self.imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController */
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        // cellControllers[indexPath] = nil
        cellController(forRowAt: indexPath).cancelLoad()
    }
}

// MARK: - MARGING feedRefreshViewController with FeedViewCOntroller

extension FeedViewController: FeedLoadingView {
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}
