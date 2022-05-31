//
//  HTTPClient.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 31/05/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
