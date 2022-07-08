//
//  FeedViewController+Localization.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 08/07/22.
//

import Foundation
import XCTest

extension FeedViewControllerTests {
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("MIssing loclized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

