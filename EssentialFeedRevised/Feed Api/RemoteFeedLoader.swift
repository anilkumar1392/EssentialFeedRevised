//
//  RemoteFeedLoader.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 26/05/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedImage])
        case failure(Error)
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if response.statusCode == 200,
                   let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items.map( { $0.item } )))
                } else {
                    completion(.failure(.invalidData))
                }
                
            case .failure(_):
                completion(.failure(.connectivity))
            }

        }
    }
}

private struct Root: Decodable {
    let items: [Item]
}

private struct Item: Decodable {
    public var id: UUID
    public var description: String?
    public var location: String?
    public var image: URL
    
    var item: FeedImage {
        return FeedImage(id: id, description: description, location: location, imageURL: image)
    }
}
