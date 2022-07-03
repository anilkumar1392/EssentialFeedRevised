
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

So we have three view four models and one controller.
So our controller is already doing too much so in this way this will not sustain in future.

View: 
UIRefreshControl
UITableViewController
UITableViewCell

Model:
FeedLoader,
FeedImage,
FeedImageDataLoader,
FeedImageDataLoaderTask

all this is handled by one controller it has quite a little bit responsibilities.

So Using classic MVC approach we have FeedViewController controlling bunch of view and models.

We can see we have less line of code but is we look at the dependency we can say FeedViewController may be not sustainable in future.

The problem is we have loading, task state and model three view and multiple models all mamagedn by One controller.

So we can have many contollers many view and many models.
By having many contoller we can share responsibilities.

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

## Inside-out vs Outside-in approach

We’ve been developing this application with an Inside-Out design approach. That’s because we started building the application for its “inside” core logic.

We started by defining the core domain with the <FeedLoader> abstraction and the FeedImage data model.

From that initial abstract core, we started implementing the Application Logic via Use Cases in an outer layer.

The application logic must interact with external services, such as the feed backend and local store. Thus, we have defined infrastructure the abstractions <HTTPClient> and <FeedStore>. The implementation of the infrastructure abstractions lives in an even outer layer.

And this is the Inside-Out approach. You start by implementing Core functionality (Inside) and move to Outer layers (Out) as you go.

However, that’s not the only or “the best” way to build an application. An Outside-In approach is just as valid!

In fact, if you have the application UI layout upfront, it can pay off to follow an Outside-In approach by developing the UI first as you can more rapidly deliver interactable apps and prototypes.

In our case, we didn’t have the UI layout until later stages of development. So an Inside-Out approach helped us not be stuck.

But since we’ve received the UI sketches from the designers, we’ve switched to an Outside-In approach.

For example, as we test-drove the UI, we created the <FeedImageDataLoader> abstraction. Since loading image data is crucial for our application, implementations of that abstraction should probably live in an Inner Layer, closer to the application logic.

So we designed our first Outside-In abstraction!

## The start of a massive FeedViewController

The FeedViewController ended up with less than a hundred lines of code, a satisfactory number for a view controller, however, as you can see in the diagram below, it has accumulated a lot of dependencies and responsibilities.

The FeedViewController is currently responsible for:

Managing the table view’s lifecycle
Handling the table view’s data source and delegate needs
Creating and configuring the UIRefreshControl
Creating, configuring and managing the state of FeedImageCells
Communicating with the <FeedLoader>
Managing the state of feed loading
Communicating with the <FeedImageDataLoader>
Managing the state of feed image data loading
Keeping track of all the feed image data loading tasks
The FeedViewController, is currently coordinating three views:

UITableView
UIRefreshControl
FeedImageCell
And four models:

The <FeedLoader> state - isLoading: Bool
The Table Model - Array<FeedImage>
The Cell Models - FeedImage
The <FeedImageDataLoaderTask> state for all visible cells - isLoading: Bool
Although the FeedViewController looks simple so far, when you look at the number dependencies and responsibilities, it has you should be able to recognize it’s already doing too much. This should signal a potentially unsustainable future for this component as we add more features to the app (e.g., ability to like, comment, and share photos).

Keeping too many responsibilities in a single MVC Controller is an anti-pattern usually known as Massive View Controller.

To alleviate the FeedViewController from the excess of its dependencies, we can proactively move some of its responsibilities to other components, and share the complexity to many places instead of one.

Finally, since we have the tests stating the specs for the feature, we can start refactoring and change the design of our system without worrying of breaking its behavior.

## Respecting the Open Closed Principle in the FeedViewController
The Open Closed Principle states that a component should be open for extension and closed for modification, meaning that the behavior of a component can be extended without making any changes to it.

In this lecture, one of the requirements we implemented was the loading of the feed images when the cells were visible. To do so, we introduced the <FeedImageDataLoader> protocol that was responsible for loading the image data from a specific URL.

Introducing the <FeedImageDataLoader> for loading the image data wasn’t a trivial decision. We could have just used the concrete URLSession class to perform image requests, however, we would couple the controller with the URLSession.

## Using URLSession directly would be easy, but not simple. It would make the controller less extensible and harder to test. For example, if we decide to cache images to disk and in-memory for better performance and efficient data usage, how would we be able to do it?

Now, what if you want to add logging and network request monitoring? Or switch to lower image resolutions on low bandwidth? Or downsampling images for better memory consumption?

By coupling the FeedViewController with the URLSession implementation, every new feature would force us to add more logic to the controller. Certainly, that’s not a sustainable approach.

The solution is to create a good abstraction.

In this case, the <FeedImageDataLoader> protocol decoupled the FeedViewController from any concrete ways of loading the feed image data.

That’s because the controller doesn’t need to care where the image data comes from (e.g., cache or network). By hiding concrete implementations, the FeedViewController is now open for extension and closed for modification (Open/Closed principle) as we can now add new behavior by plugging different implementations of the <FeedImageDataLoader>, without needing to edit any code in FeedViewController.

We can create any kind of feed image data loader, e.g., loading the feed image data remotely, from a disk cache, from an in-memory cache, etc. Of course, you can also add logging and monitoring as well and compose all of those functionalities easily without having to change the controller. The important thing is that the FeedViewController is oblivious of how the feed image data loading works.


The FeedViewController conforms to the Open Closed Principle (OCP) because of the application of two other extremely important principles, the Interface Segregation and the Dependency Inversion principles.

For example, we could have rationalized that since we already have a reference to a loader, the <FeedLoader>, and the feed image data is “feed loading related,” we could have added the loadImageData(from: URL) method to the <FeedLoader> protocol .

In fact, adding many methods to a protocol is a common behavior we see in many iOS codebases. The problem is that is leads to bloated and leaky abstractions.

The first problem with such an approach is that it would break all the components conforming to the <FeedLoader> protocol, as they would have to implement this extra mandatory method now. This is especially cumbersome on large codebases, as it’s typical (and desired) to have many components conforming to the same protocol.

Second, not all components will have a clear reason or the means to implement all methods. When this happens, the number of changes (and duplication!) will cascade as you add more dependencies and copy/paste implementations into many components. To avoid the cascading effect, developers may decide to add faulty implementations or fatalError(“not implemented”), a clear violation of the Liskov Substitution Principle.

Third, the <FeedLoader> would lose its Single Responsibility.

Fourth, it would expose methods that not all clients need, a clear violation of the Interface Segregation Principle.

Fifth, it passes a message to the iOS dev team that “it’s ok to add many methods to this protocol,” potentially giving the green light for dumping any feed image related method to it and amplifying the problems mentioned above.

So adding more methods to a protocol should be considered a red flag. However, you do need a place to add this new method. Instead of trying to find an existing protocol to include the new method, you should create a new protocol. In this case, the <FeedImageDataLoader>.

