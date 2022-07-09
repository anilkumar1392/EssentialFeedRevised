//
//  HTTPClient.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 31/05/22.
//

import Foundation

//public enum HTTPClientResult {
//    case success(Data, HTTPURLResponse)
//    case failure(Error)
//}

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<((Data, HTTPURLResponse)), Error>
    /// Completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate thread, if needed.
    ///
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

