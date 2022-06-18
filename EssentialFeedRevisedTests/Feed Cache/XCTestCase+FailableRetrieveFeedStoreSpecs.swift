//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 18/06/22.
//

import Foundation
import XCTest
import EssentialFeedRevised

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyError()), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .failure(anyError()), file: file, line: line)
    }
}
