//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 10/07/22.
//

import Foundation

public class LocalFeedImageDataLoader {
    let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader {
    public typealias SaveResult = Swift.Result<Void, Swift.Error>
    
    public enum SaveError: Swift.Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url, completion: { [weak self] result in
            guard self != nil else { return }
            
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
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
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

