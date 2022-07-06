
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

The tow way communication between the view and the presenter can lead to retain cycle.
1. Presenter holds a string ref to view
2. and the view also holds a strgin ref to the presenter.

A common solution is to make the presenter ref to the view weak.

To make protocol weak in presenter weak we need to make protocol as class only as only calss can be weakly referenced.

