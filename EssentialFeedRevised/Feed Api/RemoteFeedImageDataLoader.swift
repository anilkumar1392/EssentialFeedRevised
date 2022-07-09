//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 09/07/22.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
        case clientError
    }
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompeltions()
            wrapped?.cancel()
        }
        
        func preventFurtherCompeltions() {
            self.completion = nil
        }
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                if response.statusCode == 200, !data.isEmpty {
                    task.complete(with: .success(data))
                    // completion(.success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                    // completion(.failure(Error.invalidData))
                }
            case .failure:
                task.complete(with: .failure(Error.clientError))
                // completion(.failure(Error.clientError))
            }
        })

        return task
    }
}
