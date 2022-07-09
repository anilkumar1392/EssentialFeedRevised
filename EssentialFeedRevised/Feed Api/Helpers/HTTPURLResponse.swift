//
//  HTTPURLResponse.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 09/07/22.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
