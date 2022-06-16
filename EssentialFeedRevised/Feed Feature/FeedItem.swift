//
//  FeedItem.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 26/05/22.
//

import Foundation

public struct FeedItem: Equatable {
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


struct Images: Codable, Equatable {
    let name: String?
    let age: Int?
    let custom: Custom
}

struct Custom: Codable, Equatable {
    let data: String?
}
