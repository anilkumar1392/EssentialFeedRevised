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
    public var url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
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
