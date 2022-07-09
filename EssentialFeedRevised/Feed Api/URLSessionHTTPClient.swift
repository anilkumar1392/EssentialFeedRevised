//
//  URLSessionHTTPClient.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 05/06/22.
//

import Foundation

public final class HTTPClientURLSession: HTTPClient {
    private let session : URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct UnexpectedValueRepresentation: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapper: URLSessionTask

        func cancel() {
            wrapper.cancel()
        }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }
        task.resume()
        return URLSessionTaskWrapper(wrapper: task)
    }
    
    /*
    public func get(from urlRequest: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: urlRequest) { data, response, error in
            print("Inside HTTPClientURLSession class implemenation")
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }
    } */
}
