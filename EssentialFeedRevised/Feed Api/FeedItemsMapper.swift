//
//  FeedItemsMapper.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 31/05/22.
//

import Foundation

class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedImage] {
            return items.map { $0.item }
        }
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
    
    private static var ok_200: Int {
        return 200
    }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == ok_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
    }
}
