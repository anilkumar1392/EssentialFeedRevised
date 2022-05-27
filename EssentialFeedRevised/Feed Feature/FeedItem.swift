//
//  FeedItem.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 26/05/22.
//

import Foundation

public struct FeedImage: Equatable {
    public var id: UUID
    public var description: String?
    public var location: String?
    public var imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

extension FeedImage: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
