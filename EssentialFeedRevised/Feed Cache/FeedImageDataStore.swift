//
//  FeedImageDataStore.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 10/07/22.
//

import Foundation

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataFromURL url: URL, completion: @escaping (Result) -> Void)
}
