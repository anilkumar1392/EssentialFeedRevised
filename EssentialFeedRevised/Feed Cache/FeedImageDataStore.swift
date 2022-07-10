//
//  FeedImageDataStore.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 10/07/22.
//

import Foundation

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func retrieve(dataFromURL url: URL, completion: @escaping (Result) -> Void)
    func insert(_ data: Data, forUrl url: URL, completion : @escaping (InsertionResult) -> Void)
}