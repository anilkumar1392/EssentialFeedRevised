//
//  FeedPresenterTests.swift
//  EssentialFeedRevisedTests
//
//  Created by 13401027 on 08/07/22.
//

import Foundation
import XCTest
@testable import EssentialFeediOS

/*
 What does feed presenter do it receives events
 and translate those events in to presentable viewData or viewModels.
 So it's a translation layer it sends message to the view.
 
 View is the collaborator but now we need the action the initializer.

 */

// So if we create a feed Presenter with that view the view should not receive any messages.
/*
 We recommend you to start from the degenerate simple and trival behaviour first.
*/


final class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages.")
    }
}

// MARK: - factory methods

extension FeedPresenterTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
    }
}

// MARK: - Spy Helper methods

extension FeedPresenterTests {
    private class ViewSpy {
        let messages = [Any]()
    }
}
