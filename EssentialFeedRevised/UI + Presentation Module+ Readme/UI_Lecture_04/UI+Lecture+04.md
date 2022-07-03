
# Effectively Test-driving MVC UI with Multiple Views/Models/State, Efficiently Loading/Prefetching/Cancelling Image Requests, Inside-Out vs. Outside-In Development, and Identifying the Massive View Controller Anti-pattern by Following Design Principles



## Learning Outcomes
Inside-Out vs. Outside-In development approaches
Efficiently loading images in UITableView cells
Efficiently prefetching images when cells are near visible
Efficiently canceling image loading requests to avoid excessive data usage
Managing multiple views, models, and state
Moving state management responsibility to clients with Return Values
Identifying the Massive View Controller antipattern
Test-driving UI components
Testing UIKit components without mocking
Creating in-memory UIImage representations for fast and reliable tests
Following the Open Closed, Interface Segregation, and Dependency Inversion Principles

// We are hiding all the implementation of tableView from the tests using DSL's.

// Every time we test in collection we test in 
1. zero case 
2. one element
3. Many element

This is a classic triangulation.


## To load image from URl for a cell.

To decouple loading from url session we are using an abstraction of 'FeedIamgeDataLoader'

 By adding the 'FeedIamgeDataLoader' protocol abstraction, we decouple the 'FeedViewController' from concrete implementation like URLSession.
 
 The controller does not care where the image data comes from (e.g, Cache or network.) This way we are free to change the implementation or add more functionality (e.g, In memory caching, logging, monitoring) on demand without having to modify the controller (open/close principle).
 
 of Course it also facilitates testing as we do not need to make network call. 

## Dependency injection + Interface segregration principle unleashes the power of composition.

We can ether pass two different instances or only one that implements both protocol.
This means we can add, remove, change features just by composing. 

// Two methods in a protocol will force it's impementation to crete a state.
public protocol FeedImageDataLoader {
    func loadImageData(from url: URL)
    func cancelFeedImageDataLoad(from url: URL)
}

it needs to be state ful because to be able to cancel from url you need to hold a state of a previous request to load an image from an url.
So we are forcing the implementation of this protocol to be statefull.


we can pass this responsibilty to the client to hold the state by returning something.

e.g:
public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) -> FeedImageDataLoaderTask
}

## So this is the technique to move state mamagement to the client.
