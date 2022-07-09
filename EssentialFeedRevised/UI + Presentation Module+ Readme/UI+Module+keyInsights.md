## Key Insights

## Optional force unwrap (!) count
You might have noticed an increase in the Optional force unwrap (!) count metric of the EssentialFeediOS UI module.

That’s because of the dynamic nature of Objective-C classes such as UIViewController and the integration with storyboards. Unfortunately, there’s no easy way around it.

When using storyboards, the objects defined in the Interface Builder will be created and configured at runtime. Thus, we lose compile-time checks.

But that’s not a problem as we’ve created fast, precise and reliable tests. Any storyboard misconfiguration will trigger a test failure, which we can easily fix.

## Assignable var declaration count
You might have also noticed an increase in the Assignable var declaration count metric of the EssentialFeediOS UI module.

That’s also because of the dynamic nature of Objective-C classes such as UIViewController and the integration with storyboards that will create and configure objects at runtime.

Moreover, the UI module is a stateful module. By following the “Functional Core, Imperative Shell” principle, the UI is part of the application shell.

Thus, the “Imperative UI Shell” holds and mutates state over time. When dealing with stateful components, it’s also important to have good coverage, including tests to prevent threading issues with mutable state as shown in the lectures

## Overview of MVC/MVVM/MVP UI design patterns

## MVC (Model-View-Controller)

The Model represents the domain data and services. Models are platform-agnostic and decoupled from the Controller and the View.

The View represents elements that users can see and interact with. Views are reusable components decoupled from the Controller and typically decoupled from Models as well.

The Controller represents a mediator layer between the Model and the View. For example, a Controller can receive user actions from the View and translate it to Model commands. At the same time, a Controller can receive Model notifications/events and update the View accordingly.

To mediate the communication between the Model and View, the Controllers should utilize collaborators to distribute responsibilities. For example, a Model Date property might need to be transformed into a presentable String that can be rendered by the View. Data transformation is not a Controller responsibility, so you should introduce a collaborator to perform the transformation and keep the Controller simple and lean.

You can also use presentation adapters to transform Model values into ViewModels. In MVC, a ViewModel (also called ViewData) has no behavior. It only holds data. That’s different from MVVM where a ViewModel has dependencies and behavior.

## MVVM (Model-View-ViewModel or Model-View-Binder)

The Model represents the domain data and services. Models are platform-agnostic and decoupled from the ViewModel and the View.

The View represents elements that users can see and interact with. Views are reusable components decoupled from Domain Models.

The ViewModel is the bridge between the View and the Model binded by a Binder component. Each ViewModel is a class that translates and exposes the Model in a platform-agnostic (can be used across platforms such as iOS and macOS) or platform-specific (e.g., iOS-only) way.

The Binder connects the View and the ViewModel. There’s no automatic way of binding a View with a ViewModel in Apple’s platforms. You can either do it manually or use a framework.

You can do the binding directly in the View but, in UIKit, ViewControllers are good candidates to act as Binders. This way, the View become agnostic of the binding logic and can be reused in different contexts with distinct binding logic and ViewModels.

Since you must use UIViewControllers to present Views in UIKit, the Controller is considered part of the View layer in MVVM.

## MVP (Model-View-Presenter)

The Model represents the domain data and services. Models are platform-agnostic and decoupled from the View and Presenter.

The View represents elements that users can see and interact with. Views are decoupled from the Domain Models. From the Presenter point of view, the View is represented by an abstract interface (e.g., protocol) that must be implemented by concrete View components.

The Presenter is responsible for transforming/formatting domain values into presentable ViewModels and forwarding them to the abstract View. Each Presenter is a class that translates and exposes the Model in a platform-agnostic (can be used across platforms such as iOS and macOS) or platform-specific (e.g., iOS-only) way.

The ViewModel (also called ViewData or PresentableModel) has no behavior. It only holds presentable data. That’s different from MVVM where a ViewModel has dependencies and behavior.

Since you must use UIViewControllers to present Views in UIKit, the Controller is considered part of the View layer in MVP. Thus, the ViewController is a great candidate to implement the abstract View protocols. This way, the View components can be reused in different contexts with distinct presentation logic.

Variations
In every MV* implementation, you can break down a screen into many MV* sections. As we showed in the lectures, you can also Adapt and Decorate components with the Adapter and Decorator patterns to facilitate loose coupling between the components and make your code more extensible (Open/Closed Principle).

## MVC vs. MVVM vs. MVP: Which one is best?

MVC, MVVM, and MVP are good UI design patterns. There are many variations for implementing them, and overall they are easy to develop, maintain, extend, and test. iOS teams must choose a suitable implementation for their challenges.

When used with the right principles in mind, they all achieve the same goal—distributing UI responsibilities and component communication into loosely coupled layers.

## Regardless of the pattern you choose, focus on the goal: simple, testable, and loosely coupled components. When you achieve this goal, you are free to easily develop, maintain, extend, and test your modules in isolation.

For instance, we were able to refactor the UI module from MVC to MVVM to MVP throughout the lectures without ever changing the Networking, Persistence, and Domain modules. We didn’t even have to change the UI module tests!

By establishing a clear separation of concerns between the types of components and modules, you will create an easily testable, maintainable, and extensible application.

Change is easy, and the cost of change is minimal in a codebase where there are clear boundaries between the Domain Model, Infrastructure, View, Controller, Presenter, and ViewModel components.

As a result, the app should also be easy to extend for other platforms like iPadOS/macOS/watchOS, etc. reusing components that are not bound to UIKit or other platform-specific frameworks.

An excellent example of a reusable layer is the Presentation module. As a cross-platform module (no dependencies to low-level frameworks such as UIKit) it could be reused to any other platform. Thus, allowing your app to reach customers in multiple platforms while reducing the cost of system design and development significantly.

Even if the requirements for supporting a new platform deviate slightly from the original Presentation implementation, you can still leverage the Adapter pattern to extend the behavior of the existing Presenter components.

## ViewControllers free of conditional logic

As you may have noticed throughout the course, we pay a lot of attention to where to place any conditional logic. That’s because conditional logic implies procedural rules that make your code more brittle, rigid, coupled, and less composable.

The conditional logic should be encapsulated and concentrated in specific components instead of being dispersed throughout the codebase.

As with all other modules, the UI is no different. A useful indicator that you should consult periodically is the number of if/guard statements included in particular types of UI classes, e.g., ViewControllers and Views.

We advise you to strive for a very low number of if/guard statements in your ViewControllers. Conditional statements in Controllers are a sign that you might have either View logic or Model logic in the Controller. Instead, move any view-related logic in the View components (such as auto layout constraints or animations). And any model-related logic should be done in Model components.

For example, the FeedViewController and FeedImageCellController have no if/guard statements. Thus, proving the ViewControllers don’t encapsulate any kind of view or model logic.

At the same time, a high level of conditional logic in the Views indicate that the View is performing Presentation or Model logic. If that’s the case, move the logic to the respective components and modules.

As a result, the UI module will be composed of single-purpose SOLID components that are maintainable, extensible, testable, composable, and replaceable.

## Be careful with Frankenstein architecture (mixing too many MV* patterns)

It can be fine to choose a specific MV* pattern for the app UI, e.g., MVC but use a different one in another part of the codebase, e.g., MVVM.

However, consistency is important in a team. Mixing UI patterns in the same codebase can be confusing to team members, especially newcomers. There’s no clear path.

It’s common to see multiple distinct ways being used for achieving a goal when a dev team is divided and lack proper leadership or a collaborative mindset. For example, when the senior developers are unable to agree on, understand, teach, and express adequately the purpose, ideas, design or technology behind their decisions to others.

The lack of homogeneity in tools, personal preferences, and processes can lead to many different architectural patterns used in the same project, also known as Frankenstein Architecture.

A classic example of Frankenstein architecture in iOS is the use of conflicting implementations of MVVM and MVP in the codebase. Both patterns describe “ViewModel” components. However, ViewModel implementations and responsibilities differ in MVVM (ViewModel has dependencies and behavior) and MVP (ViewModel is only data). When this happens, it’s natural for developers to be confused. Conflicts will emerge (e.g., in code reviews) regarding the diverging implementations because of the unclear path the team has taken.

Frankenstein architecture is the result of a lack of:

Clear and transparent communication
Pairing
Training
Effective refactoring and codebase maintenance.
To avoid such scenarios, dev teams must decide on the desired implementation, document their decisions, and make sure that everyone understands how to proceed.

As a lead developer, you should strive for consistency in your team by making sure everyone, including yourself, is on the same page with the agreed plans and fully understand the steps to follow along.

Everyone should feel comfortable and confident to ask and reply to any questions regarding the design decisions. When a team member is deviating from the plan, help them get back on track by pairing with them or assigning a senior developer to pair with them.

Remember that such design decisions are never final. It might change as the requirements change, so you must keep the conversation open.

## What about UI Testing?

There’s a tremendous cost that comes with testing through the UI (either with the simulator or real devices).

UI Tests are slow, flaky, and unreliable, so we recommend you to avoid them as much as possible. We much prefer following faster and more reliable strategies.

We recommend you to only test through the UI when there’s no other choice (which is rare).

The cost of running UI tests comes from the extremely slow execution times of the tests and the lousy feedback they provide.

Slow test times and unreliable/flaky feedback will negatively affect your QA process, perhaps even making your team abandon an automated testing strategy. When tests take too long to run, they’re not going to be run less often (probably only overnight!). Moreover, flaky tests will soon be ignored. That’s when the real problems (e.g., regressions) start to pass unnoticed. When this happens, the tests turned into a liability that the team would prefer not to have at all.

## Instead, we suggest you follow faster and more reliable automated testing strategies. Reside only to UI testing when there’s no other choice.

“One of the most frustrating things about larger tests is that we can have error localization if we run our tests more often, but it is very hard to achieve. If we run our tests and they pass, and then we make a small change and they fail, we know precisely where the problem was triggered. It was something we did in that last small change. We can roll back the change and try again. But if our tests are large, execution time can be too long; our tendency will be to avoid running the tests often enough to really localize errors.”— Michael C. Feathers, Working Effectively with Legacy Code

Finally, you may be wondering if there are any valid and rewarding reasons for including UI tests in your projects.

UI tests can be helpful when composing and testing your app as a whole. In this scenario, UI tests are classified as End-to-end or Acceptance Tests.

When you need this kind of testing strategy, your UI tests should live in a separate test target that is run less often in order not to add any performance overhead to the development process. Don’t forget to include the UI test target in the CI scheme, so to run them before merging branches to guarantee the system behaves as expected now and in the future.

We’re now ready to start the Main module.
