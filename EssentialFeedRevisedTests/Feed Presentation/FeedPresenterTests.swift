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

/*
 Just to capture the received value we can create an enum.
 */

/*
 First behaviour tested but now their are two things happening so now add second behaviour in to it.
 */

/*
 we have no temporal coupling the order does not matter
 So chaning order should not break the tests.
 */

/*
 Moving code from one module to another is an delicate process we need to do it step by step.
 fi you don't have test for your code usign this TDD approach to existing code it's going to help you mistakes.
 */

/*
 Now we have isolated tests in cross paltform module
 and integration test in the iOS module.
 */

class FeedPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title
                       , localized("FEED_VIEW_TITLE"))
    }
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages.")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: nil),
            .display(isLoading: true)])
    }
    
    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSUT()
        let feed = uniqueFeedImage()
        
        sut.didFinishLoadingFeed(with: [feed])
        
        XCTAssertEqual(view.messages, [
            .display(feed: [feed]),
            .display(isLoading: false)])
    }
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLaodingFeed(with: anyError())
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
            .display(isLoading: false)])
    }
}


// MARK: - factory methods

extension FeedPresenterTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    func uniqueFeedImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "Any description", location: "A location", url: URL(string: "Http://any-url.com")!)
    }
    
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("MIssing loclized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

// MARK: - Spy Helper methods

extension FeedPresenterTests {
    private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
        
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])

        }
        
        private(set) var messages = [Message]() // Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
            // messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.append(.display(feed: viewModel.feed))
        }
    }
}
