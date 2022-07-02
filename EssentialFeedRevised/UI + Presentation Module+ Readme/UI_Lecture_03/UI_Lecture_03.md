 # Apple MVC, Test-driving UIViewControllers, Dealing with UIKit’s Inversion of Control & Temporal Coupling, and Decoupling Tests from UI Implementation Details
 
## UX goals for the Feed UI experience
[] Load feed automatically when view is presented
[] Allow customer to manually reload feed (pull to refresh)
[] Show a loading indicator while loading feed
[ ] Render all loaded feed items (location, image, description)
[ ] Image loading experience
    [ ] Load when image view is visible (on screen)
    [ ] Cancel when image view is out of screen
    [ ] Show a loading indicator while loading image (shimmer)
    [ ] Option to retry on image download error
    [ ] Preload when image view is near visible

## MVC is a UI Architectural Design pattern

SO we just need to create views and controllers.

One of the biggest misconception with MVC is their is only one Model one view and one controller per screen.
Infact a screen can be composed of many small MVC's.

// UIKIt is a third party framework because, even though it's part of the platform, it's private.

// We have no access to the source code. We can't change it or even see the implementation.
// We need to learn how the frame work works.

so while writing tests will not write test for viewDidLoad is actually invoked instead we just test what our implementation does when the framework tells us that the view is loaded.

We arre coupling our code with specific UIControl the UIRefreshControl if we ever decide to change the control and add button on navigation to refresh we will have to rewrite the tests.

The refresh control is an implementation detail it would be better to hide it from the tests.
As always it's always a good idea to decouple implementation details from tests.

// Now after changes if we ever decide to change this we do not need to change tests but we just need to change the DSL implementations.

This way we can guarante clean, felixible, and reliable behaviour tests that also serves as a great documentations.

## Temporal Coupling

Requiring certain methods of a class to be called in specific order.

Usually it is desired to have a single assertion per test.
however when working with frameworks temporal coupling is dangerous.
YOu don't have much control over the framework events.
So when testing framwork events that have temporal coupling or in other words a specific order it's offen a good idea to unify the related events and assertions in one test.

While combining assertion be sure to add good assertion messages to document the steps better.

While you have more than one assertion it's critical to give more context of what was expected.

## Learning Outcomes
Validating UX experiences and exploring solutions through prototyping
Introduction to the MVC UI architectural design pattern
Test-driving MVC implementations
Testing effectively with 3rd-party frameworks
Preventing bugs caused by 3rd-party framework’s Inversion of Control and Temporal Coupling
Decoupling tests from UI implementation details

## Model-View-Controller (MVC)

Model-View-Controller is a UI architectural design pattern that classifies the participants of the UI of the app into three parts: Model, View, and Controller.

There are many different implementations of MVC. Apple has implemented their version of MVC in UIKit with UIViews and UIViewControllers, which is a simple solution to organizing your UI layer in logical parts:

The Model represents the business logic. Models are decoupled from the Controller and the View.

The View represents elements that users can see and interact with. Views are decoupled from the Controller and typically decoupled from Models as well.

The Controller represents a mediator layer between the Model and the View. For example, a Controller can receive user actions from the View and translate it to Model commands. At the same time, a Controller can receive Model notifications and update the View accordingly.

One of the biggest misconceptions with MVC is that there’s only one Model, one View and one Controller per screen. In fact, it’s advised that a screen should be composed of many MVCs!

## Testing effectively with 3rd-party frameworks

Test-driving 3rd-party frameworks like UIKit is different from test-driving your implementations because you need to know how to use the framework upfront.

We call UIKit a “3rd-party” framework because, even though it’s part of the platform, it’s private. We have no access to the source code. We can’t change it or even see its implementation.

When testing with 3rd-party frameworks in the mix, you shouldn’t have to “test that the framework works.” You should trust that 3rd-party frameworks work as intended.

If you don’t trust a 3rd-party framework, you should probably not use it in the first place. However, of course, if you must use a framework you don’t trust, you better write tests against it!

So, ideally, you should only test the interaction with the framework. Reading the documentation along with experimentation with a spike/prototype goes a long way in giving you confidence on how to the 3rd-party framework operates so that you can test/use it correctly.

## 3rd-party Frameworks, Inversion of Control and Temporal Coupling

When frameworks are responsible for calling your code (e.g., to notify events and callbacks), the framework gains control over the application flow.

“The term Inversion of Control originally meant any sort of programming style where an overall framework or runtime controlled the program flow.”—Dependency Injection: Principles, Practices, and Patterns by Mark Seemann & Steven van Deursen"

UIKit relies heavily on Inversion of Control to notify user input, touch events, and view lifecycle events, for example.

In the case of our UIViewController subclass, UIKit calls our code to notify us about view lifecycle events, rather than us calling UIKit.

The result of the Inversion of Control that UIKit introduces is that we don’t have much control over the view lifecycle events. We can only react to them.

Moreover, view lifecycle events happen in a specific order. This leads to Temporal Coupling, a code smell where events must occur in a particular order; otherwise, it generates unexpected behavior.

“Temporal Coupling is a common problem in API design. It occurs when there’s an implicit relationship between two or more members of a class, requiring clients to invoke one member before the other. This tightly couples the members in the temporal dimension.”—Dependency Injection: Principles, Practices, and Patterns by Mark Seemann & Steven van Deursen"

The lack of control you have over events introduced by UIKit’s Inversion of Control combined with Temporal Coupling poses a serious threat to the tests as you must invoke events in a specific order to get the desired behavior. For that, you need upfront knowledge about how UIKit works. Requiring a specific order of events makes your tests more error-prone and fragile (a simple method reordering might break all expectations/assumptions!).

To enhance the integrity and validity of your tests with 3rd-party frameworks in the mix, you can combine all events and assertions that have Temporal Coupling in a single test. By doing so, you can more easily spot mistakes as the progression of events and expectations are contained in the same short scope. Also, it documents the expected behavior making it easier for the reader to understand the whole chain of events in one place.

Although the practice of grouping events with Temporal Coupling into one test is optional, it can save you from (common) mistakes like the one we showed you in the lecture video, where the tests were passing, but there was a bug in the code.

When combining assertions into one test, make sure to add good assertion messages to improve the documentation of the steps. Otherwise, it’ll be hard to debug failures or reason about the code later on.

Finally, you should separate the tests in logical units still. For example, we are only testing the loading indicator logic in one test, and the load feed actions in another test, as we don’t want to mix concepts.

## Decoupling tests from implementation details, a step-by-step breakdown

Decoupling tests from implementation details is an invaluable technique we’ve been advocating throughout the course.

You should strive to test behaviors instead of implementations.

Low coupling between tests and implementation details makes tests resilient to changes in production. This way, you’re free to change production implementation without breaking tests.

Of course, you can achieve the same degree of low-coupling in the UI layer tests!

For example, the highlighted portion of the following image contains a test implementation checking that the “pull to refresh” action triggers a feed reload.

Although the test was passing and asserting the correct behavior, it ended up exposing the target-action pattern used by UIControl for triggering actions based on events. In other words, the test is coupled with implementation details of how the system under test triggers the loading of the feed, through a UIRefreshControl .valueChanged event.

The first step to mitigating the coupling of how we trigger the “pull to refresh” is to extract and hide the nested iterations behind a new interface. You can do so by creating a DSL method in an extension on UIRefreshControl. We deemed that a sensible name describing the intent of the function would be func simulatePullToRefresh().

The test became much lighter, but it is still leaking implementation details as it references the refreshControl of the system under test. The reference to the refreshControl creates a coupling between the test and the implementation detail for updating the feed. If we ever decide to change the controls, for example, by adding a refresh button to the navigation bar instead of using a UIRefreshControl, we will have to rewrite the test.

To eliminate the coupling between the test and the refresh control, we can introduce a new DSL func simulateUserInitiatedFeedReload() on a private extension of the FeedViewController to hide the specific control from the test method. Also, since we removed all references of “pull to refresh” and refreshControl from the test, we can rename the test method to reflect the expected behavior rather than implementation details.

## Simulating UIControl events
In this lecture, we showed how to programmatically trigger actions for every target added to a UIControl by iterating through the UIControl.allTargets property.

If you’re running tests with a Host Application, another easy way to fire actions in a UIControl during tests is to call sendActions(for: UIControl.Event).

For example, to simulate ‘pull to refresh’ on a UIRefreshControl, you can use the .valueChanged event:

refreshControl.sendActions(for: .valueChanged)

To simulate a ‘tap’ on a UIButton, you can use the .touchUpInside event:

button.sendActions(for: .touchUpInside)

## UX goals for the Feed UI experience
[✅] Load feed automatically when view is presented
[✅] Allow customer to manually reload feed (pull to refresh)
[✅] Show a loading indicator while loading feed
[ ] Render all loaded feed items (location, image, description)
[ ] Image loading experience
    [ ] Load when image view is visible (on screen)
    [ ] Cancel when image view is out of screen
    [ ] Show a loading indicator while loading image (shimmer)
    [ ] Option to retry on image download error
    [ ] Preload when image view is near visible

## References
MVC, MVVM, and MVP (UI Design Patterns) https://www.essentialdeveloper.com/articles/clean-ios-architecture-pt–5-mvc-mvvm-and-mvp-ui-design-patterns
Apple MVC https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html
Target-Action pattern https://developer.apple.com/library/archive/documentation/General/Conceptual/Devpedia-CocoaApp/TargetAction.html
UIControl.addTarget(_:action:for:) docs https://developer.apple.com/documentation/uikit/uicontrol/1618259-addtarget
UIControl.sendActions(for:) docs https://developer.apple.com/documentation/uikit/uicontrol/1618211-sendactions
Inversion of Control https://martinfowler.com/bliki/InversionOfControl.html
More about required and convenience initializers — Initialization in Swift https://docs.swift.org/swift-book/LanguageGuide/Initialization.html
