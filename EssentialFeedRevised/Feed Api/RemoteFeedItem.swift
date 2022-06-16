//
//  RemoteFeedItem.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 16/06/22.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal var id: UUID
    internal var description: String?
    internal var location: String?
    internal var image: URL
}
