
##  Storyboard vs. Code: Layout, DI and Composition, Identifying the Constrained Construction DI Anti-pattern, and Optimizing Performance by Reusing Cells

To use storyboard we need to use property injection instead of constructor injection.

// Down sides of using storyboards

we loose compile time composition checks we can get with constructor injection.

using objects in storyboard we can confgure FeedRefreshViewController from storyboard.
So whole view configuration now leaves in stroyboard.

## Reusing cell is a new behaviour we are not covering in tests. which can lead to bugs.

Multiple controller may be refering the same cell is controller does not leave the cell when teh cell goes off screen.

when the cell goes off screen the didEndDisplayingCell is called so we should release the cell for reuse here.

## Rethink your assumptions by writing more tests.

1. It's essential to prove a problem with a failing test first
2. Only with a failing test you go ahead and solve the problem.

## In this lecture, you’ll learn how to maintain a clean architecture regardless if you’re using code or Storyboards for your app layout. Additionally, you’ll see extra refactorings, animations in code, and final optimizations, such as reusing cells by identifier.

## Learning Outcomes
Trade-offs of creating the app layout in storyboards vs. programmatically
Dependency Injection and component composition with storyboards
Optimizing UITableView performance by reusing cells

## Storyboard vs. Code: which one is best?


“Storyboard vs. Code” is a long debate, often driven by personal preference. We personally prefer Code over Storyboards.

But, as always, it depends.

Ultimately, code is the most flexible, efficient, and reusable solution (there are things you can do with code that you can’t with storyboards). However, storyboards tend to be more convenient and faster/easier to create simple layouts that support multiple devices and screen sizes.

Starting with storyboards has served us well as it can give an initial boost in productivity. However, it often does not scale well.

The problem with storyboards is that it mixes too many concerns — Layout/View Configuration, Navigation (Flows, Segues, and Unwinding), Presentation and Transition Styles, Composition, DI, etc.

If you use storyboards for only one of those concerns, it will scale much better. We recommend storyboards only for Layout/View Configuration.

We recommend you to make your tests agnostic of if you’re using Storyboards or implementing everything in Code. Your automated tests should help you gather fast feedback about your solution. So when mistakes happen, you’re quickly notified (e.g., forgot to set up an IB connection).

If you can refactor the storyboard solution to code (and vice-versa) without changing the tests, you’ll guarantee no regressions and reduce (or eliminate) debugging time. You don’t even need to run the app to validate the UI composition!

If you decide to go with storyboards, and later on you identify it’s becoming a burden or a productivity bottleneck, then it may be time to start moving some parts to code.

For example, storyboards:

Make views hard to reuse (e.g., the cell layout would be hard to reuse in other storyboards without duplicating the whole view hierarchy with copy/paste)
Make animations with AutoLayout constraints challenging (you must configure and connect constraint IBOutlets)
Have many bugs that require fixes in code (e.g., tintColor doesn’t work for UIImageView with template images since ever, but works fine in code)
Enforce Property Injection instead of Constructor Injection for proper Dependency Injection (DI). That’s a DI anti-pattern called Constrained Construction.

## Storyboards and the Constrained Construction anti-pattern

Choosing storyboards over code introduces trade-offs for your app architecture and components composition.

On the one hand, storyboards offer the ease of use and rapid feedback of creating layouts and emulating how the views and their constraints will look like on multiple screen sizes. On the other, it constrains the creation of objects through the Storyboard instantiation APIs.

Constraining the creation of objects in a particular way is a DI anti-pattern that prevents you from using proper dependency injection.

"Constrained Construction forces all implementations of a certain Abstraction to require their constructors to have an identical signature with the goal of enabling late binding[...] Late binding introduces extra complexity, and complexity increases maintenance costs."—Mark Seemann and Steven van Deursen, “Dependency Injection Principles, Practices, and Patterns”

By using Storyboards, the View Controller classes are constrained to be instantiated by the same constructor: init?(coder: NSCoder). So, when using storyboards, you must use Property Injection (trade-off) instead of Constructor Injection (desired) to enable Dependency Injection.

Such a change doesn’t come at a small cost. With Property Injection, you lose compile-check guarantees about your code composition, and your class must expose its properties as internal or public and handle optional dependencies that may not be available at all times (also leading to temporal coupling).

Ultimately, it’s up to you, the developer, to assess the trade-offs for every state of your project and maintain a low cost of shifting from one paradigm to another.

## Initializer Injection and Storyboards on iOS13+

“Is it possible to use Initializer Injection if I’m using storyboards?” is a popular question we receive.

The answer is… it depends.

You can use Initializer Injection for all ViewController dependencies. But, if you’re using Storyboards, you can’t easily use Initializer Injection in the ViewControllers created by the Storyboard.

However, since iOS 13, you can use new storyboard APIs that allow you to instantiate your ViewControllers from a Storyboard by using a creator closure, instead of letting UIKit do it for you.

This new API makes it possible to use Initializer Injection in ViewControllers when using Storyboards:


let bundle = Bundle(for: FeedViewController.self)
let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
if #available(iOS 13.0, *) { 
    return storyboard.instantiateInitialViewController(creator: { coder in
        // Initializer Injection on iOS13+
        return FeedViewController(coder: coder, delegate: delegate, title: title)
    })
} else {
    // Property Injection on older iOS versions
    let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
    feedController.delegate = delegate
    feedController.title = title
    return feedController
}

If you still support older iOS versions, you can’t use this new API. Also, if you have embedded Storyboard references, you cannot use Initializer Injection for the child ViewControllers (only for the top-level parent!).

But if you move all instantiation to a centralized place, that should not be a big problem as you can cleanly instantiate and compose the ViewController with all its dependencies (e.g., using Property or Method Injection).

To support a modular and loosely coupled codebase, we recommend you strive to find a solution that allows object instantiation and composition to happen in a single place: the Composition Root.

When you move object instantiation and composition to a centralized place, Dependency Injection becomes much easier, simpler, and safer. Additionally, you minimize the shortcomings of DI with Storyboards.

And, of course, if Storyboards become too much of a burden, you can shift to creating your UI programmatically instead.

## Fixing unexpected bugs caused by optimizations

Optimizing your code is usually the final step of the development process after you have asserted that your component works as intended (with a wide range of automated tests) and has a clean and simple design.

 ## “Make it work. Make it right. Make it fast. In that order.”—Kent Beck



  Storyboard vs. Code: Layout, DI and Composition, Identifying the Constrained Construction DI Anti-pattern, and Optimizing Performance by Reusing Cells

Find the git diff with all commits/changes for this episode here.

In this lecture, you’ll learn how to maintain a clean architecture regardless if you’re using code or Storyboards for your app layout. Additionally, you’ll see extra refactorings, animations in code, and final optimizations, such as reusing cells by identifier.

Learning Outcomes
Trade-offs of creating the app layout in storyboards vs. programmatically
Dependency Injection and component composition with storyboards
Optimizing UITableView performance by reusing cells
Architecture overview

Storyboard vs. Code: which one is best?
“Storyboard vs. Code” is a long debate, often driven by personal preference. We personally prefer Code over Storyboards.

But, as always, it depends.

Ultimately, code is the most flexible, efficient, and reusable solution (there are things you can do with code that you can’t with storyboards). However, storyboards tend to be more convenient and faster/easier to create simple layouts that support multiple devices and screen sizes.

Starting with storyboards has served us well as it can give an initial boost in productivity. However, it often does not scale well.

The problem with storyboards is that it mixes too many concerns — Layout/View Configuration, Navigation (Flows, Segues, and Unwinding), Presentation and Transition Styles, Composition, DI, etc.

If you use storyboards for only one of those concerns, it will scale much better. We recommend storyboards only for Layout/View Configuration.

We recommend you to make your tests agnostic of if you’re using Storyboards or implementing everything in Code. Your automated tests should help you gather fast feedback about your solution. So when mistakes happen, you’re quickly notified (e.g., forgot to set up an IB connection).

If you can refactor the storyboard solution to code (and vice-versa) without changing the tests, you’ll guarantee no regressions and reduce (or eliminate) debugging time. You don’t even need to run the app to validate the UI composition!

If you decide to go with storyboards, and later on you identify it’s becoming a burden or a productivity bottleneck, then it may be time to start moving some parts to code.

For example, storyboards:

Make views hard to reuse (e.g., the cell layout would be hard to reuse in other storyboards without duplicating the whole view hierarchy with copy/paste)
Make animations with AutoLayout constraints challenging (you must configure and connect constraint IBOutlets)
Have many bugs that require fixes in code (e.g., tintColor doesn’t work for UIImageView with template images since ever, but works fine in code)
Enforce Property Injection instead of Constructor Injection for proper Dependency Injection (DI). That’s a DI anti-pattern called Constrained Construction.
Storyboards and the Constrained Construction anti-pattern
Choosing storyboards over code introduces trade-offs for your app architecture and components composition.

On the one hand, storyboards offer the ease of use and rapid feedback of creating layouts and emulating how the views and their constraints will look like on multiple screen sizes. On the other, it constrains the creation of objects through the Storyboard instantiation APIs.

Constraining the creation of objects in a particular way is a DI anti-pattern that prevents you from using proper dependency injection.

"Constrained Construction forces all implementations of a certain Abstraction to require their constructors to have an identical signature with the goal of enabling late binding[...] Late binding introduces extra complexity, and complexity increases maintenance costs."—Mark Seemann and Steven van Deursen, “Dependency Injection Principles, Practices, and Patterns”
By using Storyboards, the View Controller classes are constrained to be instantiated by the same constructor: init?(coder: NSCoder). So, when using storyboards, you must use Property Injection (trade-off) instead of Constructor Injection (desired) to enable Dependency Injection.

Such a change doesn’t come at a small cost. With Property Injection, you lose compile-check guarantees about your code composition, and your class must expose its properties as internal or public and handle optional dependencies that may not be available at all times (also leading to temporal coupling).

Ultimately, it’s up to you, the developer, to assess the trade-offs for every state of your project and maintain a low cost of shifting from one paradigm to another.

Initializer Injection and Storyboards on iOS13+
“Is it possible to use Initializer Injection if I’m using storyboards?” is a popular question we receive.

The answer is… it depends.

You can use Initializer Injection for all ViewController dependencies. But, if you’re using Storyboards, you can’t easily use Initializer Injection in the ViewControllers created by the Storyboard.

However, since iOS 13, you can use new storyboard APIs that allow you to instantiate your ViewControllers from a Storyboard by using a creator closure, instead of letting UIKit do it for you.

This new API makes it possible to use Initializer Injection in ViewControllers when using Storyboards:

let bundle = Bundle(for: FeedViewController.self)
let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
if #available(iOS 13.0, *) { 
    return storyboard.instantiateInitialViewController(creator: { coder in
        // Initializer Injection on iOS13+
        return FeedViewController(coder: coder, delegate: delegate, title: title)
    })
} else {
    // Property Injection on older iOS versions
    let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
    feedController.delegate = delegate
    feedController.title = title
    return feedController
}
view rawVC_InitializerInjection_With_Storyboards_iOS13+.swift hosted with ❤ by GitHub
If you still support older iOS versions, you can’t use this new API. Also, if you have embedded Storyboard references, you cannot use Initializer Injection for the child ViewControllers (only for the top-level parent!).

But if you move all instantiation to a centralized place, that should not be a big problem as you can cleanly instantiate and compose the ViewController with all its dependencies (e.g., using Property or Method Injection).

To support a modular and loosely coupled codebase, we recommend you strive to find a solution that allows object instantiation and composition to happen in a single place: the Composition Root.

When you move object instantiation and composition to a centralized place, Dependency Injection becomes much easier, simpler, and safer. Additionally, you minimize the shortcomings of DI with Storyboards.

And, of course, if Storyboards become too much of a burden, you can shift to creating your UI programmatically instead.

Fixing unexpected bugs caused by optimizations
Optimizing your code is usually the final step of the development process after you have asserted that your component works as intended (with a wide range of automated tests) and has a clean and simple design.

“Make it work. Make it right. Make it fast. In that order.”—Kent Beck
Ideally, optimizations should not change the system behavior. However, there are times where optimizing your code might require design changes you hadn’t anticipated before. And non-trivial design changes may affect the system behavior and lead to mistakes, bugs, and regressions.

We faced a non-trivial design change in this lecture with the reuse optimization of FeedImageCell instances.

Previously, every FeedImageCellController created and managed its own unique cell instance throughout its lifecycle.

However, when reusing cells, this behavior changed. Reusable cells are not unique instances per controller. Multiple controllers may reuse the same cell instance once it goes off-screen.

So, if the controllers don’t release the cell after it goes off-screen, multiple controllers might be referencing and mutating the same cell instance. This will cause the UI to get out of sync.

The fix is easy, the controller just needs to release the cell for reuse. However, when you identify a faulty or potential faulty behavior, we highly suggest you prove your hypothesis by writing a failing test first.

Even though you’ll be writing the test after the fact (the faulty behavior is already implemented!), a failing test will prove that:

There’s indeed a faulty behavior
You understand and can replicate the faulty behavior
Once the test pass, the problem has been fixed
Once fixed, you have an automated way to prevent regressions
In our hypothesis, the faulty behavior is: if the controller doesn’t release the cell when it goes off-screen, it might update the cell even though it might belong to another controller and represent another model on the screen.

For example, the UI will display the wrong image (be out of sync) if the controller tells the cell to render an asynchronously loaded image after the cell has moved out of the screen and been reused by another controller.

From that hypothesis, we can derive the test case name and structure for the correct behavior:

“Feed image view does not render loaded image when not visible anymore”

With a failing test in place, we proved there was indeed a faulty behavior. Then, it’s time to fix the faulty behavior by releasing the cell for reuse when the table view invokes the didEndDisplaying cell delegate method.

## Increase productivity by reusing prototype resources


Prototypes are quick discardable implementations used to validate ideas with your peers and customers.

Since prototypes are not production-ready solutions, code should probably be discarded. However, the layout and other assets (e.g., images and translations) used in a prototype are great candidates for reuse in real products.

## Responsibilities

The responsibilities for creating and configuring views have been moved from the View Controllers to the Storyboard.

## References
UIStoryboard reference https://developer.apple.com/documentation/uikit/uistoryboard
UIStoryboard.instantiateInitialViewController(creator:) reference https://developer.apple.com/documentation/uikit/uistoryboard/3213988-instantiateinitialviewcontroller
UIStoryboard.instantiateViewController(identifier:creator:) reference https://developer.apple.com/documentation/uikit/uistoryboard/3213989-instantiateviewcontroller
Composing View Controllers pt.2: Testing Storyboards https://www.essentialdeveloper.com/articles/composing-view-controllers-part–2-testing-storyboards
Composing View Controllers pt.3: Lifecycle Observers in Swift https://www.essentialdeveloper.com/articles/composing-view-controllers-part–3-lifecycle-observers-in-swift
Designing with Storyboards https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/DesigningwithStoryboards.html#//apple_ref/doc/uid/TP40010215-CH43-SW1
Adding Images (Assets) https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/AddingImages.html#//apple_ref/doc/uid/TP40010215-CH50-SW1
UITableView reference https://developer.apple.com/documentation/uikit/uitableview
Creating reusable table-view cell objects located by their identifier https://developer.apple.com/documentation/uikit/uitableview/1614891-dequeuereusablecell
