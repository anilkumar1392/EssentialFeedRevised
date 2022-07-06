
## MVP: Creating a Reusable and Cross-Platform Presentation Layer, Implementing Service Adapters, and Solving Cyclic Dependencies & Memory Management issues with the Proxy Pattern

## MVP
1. Separate UI from presentation layer.
2. Create reuable cross platform presentation layer.


JUst like MVC the MVP has presenter in between and presentar holds a reference to view however the dependency is inverted.
1. IN MVC contoller holds reference to concrete view type.
2. In MVP the controller holds reference to abstract view type in the form of a protocol.
3. The View protocol is in the presentation layer.
4. IN MVP the view talks woth the controller directly creatign a two way communication channel between view and presenter.

5. Presenter transforms model values before transforming it to the view.

## The goal is to refactor from MVVM to MVP.

Presentator has a ref to the view through a protocol.
1. Remove observable properties with the feedView properties.

protocol FeedView {
    func display(isLoading: Bool)
    func display(feed: [FeedImage])
}

Refctoring a ViewModel to a presentor is fast and simple.

The change from two obserable to one protocol pocess a threat as it voilates interface segragation principle.
now we only need to nake our view confirm to protocols

Configuring Presenter.

1. we can't make a method confirm to a protocol.
to do that we can use a FeedViewAdapter

## The two way communication between the view and the presenter can lead to retain cycle.
1. Presenter holds a string ref to view
2. and the view also holds a strgin ref to the presenter.

A common solution is to make the presenter ref to the view weak.

To make protocol weak in presenter weak we need to make protocol as class only as only calss can be weakly referenced.

So test are passing but I don't like how the composition detail amde us change the implementation of the Presentar component. 

## Memory management is a responsibilty that belong to composer not your component.
otherwise you will be leaking infrastrucutre detail in to your componenets.

## So let's move memroy management away from presenter. 

This can be done through composer

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

This way we can safely forward the message to weak instance with compile check guaranted.
So retain cycle is now solved and memory management now leave in composer.
away from MVP component.

So presenter translates modelValues in to view Data.
however we are representing ore loading state as a simple boolean. this not the ideal. as it lacks content we are not just passing a boolean. 
we are passign a model required for FeedLoadingView rendering.

SO instead of Bool we can pass a model.
Bool -> 
struct FeedLoadingViewModel {
    var isLoading: Bool
} 

## Add presentable ViewModel to clarify communication between presentation and UI 

InMVp a viewModel is also called viewData or presentableModel, and it only holds the necessary data for the view rendering it has no behaviour.
so it is differnt form ViewModel as a viewModel has dependency and behaviour.

To decouple Controller from presenter we can use a adapter in between.


2. In Presenter remove feedLoader dependency from presenter.
3. Sicne we dont have a reference to feedLoader we need a mechanism to know when the loading begins and finishes.
4. To do so we can use delegation instead of current closure approach.

    replace this with this.
    /*
     1. 
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    } */
    
    func didStartLoadingFeed() {
        self.loadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        self.feedView?.display(FeedViewModel(feed: feed))
    }
    
    func didFinishLaodingFeed(with error: Error) {
        self.loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }

and now we need a adapter component to delegate this responsibility.
