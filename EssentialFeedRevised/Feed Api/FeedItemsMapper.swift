//
//  FeedItemsMapper.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 31/05/22.
//

import Foundation

class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static var ok_200: Int {
        return 200
    }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == ok_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
