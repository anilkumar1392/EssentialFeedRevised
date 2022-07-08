//
//  FeedViewController+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 08/07/22.
//

import Foundation

class LoaderSpy: FeedLoader, FeedImageDataLoader {
    
    // MARK: - FeedLoader
    
    private var feedRequests = [(LoadFeedResult) -> Void]()
    
    var loadFeedCallCount: Int {
        return feedRequests.count
    }
    
    func load(completion: @escaping (LoadFeedResult) -> Void) {
        feedRequests.append(completion)
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index](.success(feed))
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        feedRequests[index](.failure(anyError()))
    }
    
    // MARK: - FeedImageDataLoader
    
    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallBack: () -> Void
        func cancel() {
            cancelCallBack()
        }
    }
    
    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }
    
    private(set) var cancelledImageURLs = [URL]()
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy { [weak self] in
            self?.cancelledImageURLs.append(url)
        }
    }
    
    func cancelFeedImageDataLoad(from url: URL) {
        cancelledImageURLs.append(url)
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int) {
        let error = NSError(domain: "an error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}
