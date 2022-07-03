//
//  FeedViewControllerTests.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 02/07/22.
//

import Foundation
import XCTest
import UIKit
import EssentialFeedRevised
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    // MARK: - Load feed automatically when view is presented
    
    /*
     func test_init_doesNotLoadFeed() {
     let (_, loader) = makeSUT()
     
     XCTAssertEqual(loader.loaderCallCount, 0)
     }
     
     func test_viewDidLoad_loadsFeed() {
     let (sut, loader) = makeSUT()
     
     sut.loadViewIfNeeded()
     
     XCTAssertEqual(loader.loaderCallCount, 1)
     }
     */
    
    //MARK: - Allow customer to manually reload feed (pull to refresh)
    
    /*
     The refresh control is an implementation detail it would be better to hide it from the tests.
     As always it's always a good idea to decouple implementation details from tests.
     */
    
    /*
     func test_loadFeedActions_requestFeedFromLoader() {
     let (sut, loader) = makeSUT()
     sut.loadViewIfNeeded()
     
     sut.simulateUserInitiatedFeedReload()
     XCTAssertEqual(loader.loaderCallCount, 2)
     
     sut.simulateUserInitiatedFeedReload()
     XCTAssertEqual(loader.loaderCallCount, 3)
     } */
    
    // We are merging them because they are creating temporal coupling.
    /*
     like our third test depends on viewDidLoad to call loadFeed()
     because of which we are checking for loaderCallCount from 2, because we know loaderCallCount is 1 in previous test this is called temporal coupling.
     
     So to remove temporal coupling we have merged similar kind of tests.
     */
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    //MARK: - Show a loading indicator while loading feed
    
    // Same temporal coupling is in the loading indicator so let;s couple them to.
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    /*
     func test_viewDidLoad_showsLoadingIndicator() {
     let (sut, _) = makeSUT()
     
     sut.loadViewIfNeeded()
     
     XCTAssertEqual(sut.isShowingLoadingIndicator, true)
     }
     
     func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
     let (sut, loader) = makeSUT()
     
     sut.loadViewIfNeeded()
     loader.completeFeedLoading()
     
     XCTAssertEqual(sut.isShowingLoadingIndicator, false)
     }
     
     func test_userInitiatedFeedReload_showsLoadingIndicator() {
     let (sut, _) = makeSUT()
     
     sut.simulateUserInitiatedFeedReload()
     
     XCTAssertEqual(sut.isShowingLoadingIndicator, true)
     }
     
     func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoaderCompletion() {
     let (sut, loader) = makeSUT()
     
     sut.simulateUserInitiatedFeedReload()
     loader.completeFeedLoading()
     
     XCTAssertEqual(sut.isShowingLoadingIndicator, false)
     }
     */
    
    // MARK: - Render all loaded feed items (location, image, description)
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    // If we have already validated the current feed we don't want to invalidata the current feed.
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "a description", location: "a location")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    // MARK: - Load image experience
    
    // 1. Load when image view is visible (on screen)
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURls, [], "Expected no image url requests until views become visible.")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURls, [image0.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURls, [image0.url, image1.url], "Expected second image URL request once first view becomes visible")
    }
    
    // 2. Cancel when image view is out of screen
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    // 3. Show a loading indicator while loading image (shimmer)
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loadiong indicator for the first view while loading the first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true ,"Expected loadiong indicator for the first view while loading the second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected loadiong indicator for the first view while loading the first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true ,"Expected loadiong indicator for the first view while loading the second image")
        
        loader.completeImageLoading(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected loadiong indicator for the first view while loading the first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false ,"Expected loadiong indicator for the first view while loading the second image")
    }
    
    // On success full response renders image from URL.
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        // simulate cell visible but image loading not completed.
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        // Image loading completed for first cell
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no ima¸ge state change for second view once first image loading completes successfully")
        
        // Image loading completed for second cell
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
}

extension FeedViewControllerTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image  view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
}

extension FeedViewControllerTests {
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: - FeedLoader
        
        private var feedRequests = [(LoadFeedResult) -> Void]()
        
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        func load(completion: @escaping (LoadFeedResult) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            feedRequests[index](.failure(anyError()))
        }
        
        // MARK: - FeedImageDataLoader
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallBack: () -> Void
            func cancel() {
                cancelCallBack()
            }
        }
        
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedImageURls: [URL] {
            return imageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func cancelFeedImageDataLoad(from url: URL) {
            cancelledImageURLs.append(url)
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }
}

// MARK: - DSL Helpers

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToReferesh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func simulateFeedImageViewNotVisible(at row: Int) {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    private var feedImageSection: Int {
        return 0
    }
    
    func feedImageView(at index: Int = 0) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: index, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
}

extension UIRefreshControl {
    func simulatePullToReferesh() {
        allTargets.forEach({ target in
            actions(forTarget: target,
                    forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        })
    }
}

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
