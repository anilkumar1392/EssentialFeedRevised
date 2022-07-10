//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 10/07/22.
//

import Foundation

class LocalFeedImageDataLoader {
    let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader {
    typealias SaveResult = Swift.Result<Void, Swift.Error>
    
    public enum SaveError: Swift.Error {
        case failed
    }
    
    func insert(_ data: Data, forUrl url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, forUrl: url, completion: { result in
            completion(result
                .mapError { _ in SaveError.failed }
            )
        })
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    typealias LoadResult = FeedImageDataLoader.Result

    private class LoadImageDataTask: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompeltions()
        }
        
        private func preventFurtherCompeltions() {
            completion = nil
        }
    }

    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        store.retrieve(dataFromURL: url, completion: { result in
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                })
        })
        return task
    }
}
