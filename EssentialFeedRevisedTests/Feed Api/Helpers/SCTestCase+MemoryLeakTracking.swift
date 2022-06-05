//
//  SCTestCase+MemoryLeakTracking.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 05/06/22.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, Potential memory leak.", file: file, line: line)
        }
    }
}
