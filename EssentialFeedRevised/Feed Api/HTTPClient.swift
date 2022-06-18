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
    /// Completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate thread, if needed.
    /// 
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
    // func get(from urlRequest: URLRequest, completion: @escaping (HTTPClientResult) -> Void)
}

