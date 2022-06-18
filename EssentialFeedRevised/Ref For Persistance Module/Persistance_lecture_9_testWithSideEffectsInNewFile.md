
 ### Separating App-specific, App-agnostic & Framework logic, Entities vs. Value Objects, Establishing Single Sources of Truth, and Designing Side-effect-free (Deterministic) Domain Models with Functional Core, Imperative Shell Principles

// Use cases incapsulate application specific bussiness logic
LocalFeedLoader implements use cases.
By collaborating with other types.
so it acts like a controller, or control boundary, or interactor or a model contoller.

another appliaiton detail is how to get curretn date.

This are all applicaiton detail and are irrelavent with core doamin model.

Caching policy is a policy is a bussiness rule.
Depending on bussiness rule this cache policy may be so important and need to be shared.
// So it may be shread among so it is applicaiton agnostic.


Learning Outcomes
Application-specific vs. Application-agnostic vs. Framework (Infrastructure) Logic
Entities vs. Value objects
Designing side-effect free (deterministic) core business rules
Establishing Functional Core, Imperative Shell 
Promoting reusability and reducing cost, duplication, and defects with single sources of truth

##Application-specific vs. Application-agnostic business logic

In software development, there are two common types of business logic. If you don’t distinguish between them when discussing with other developers, the lack of context can lead to miscommunication: two people talking about the same words (business logic) but referring two entirely different concepts.

Use Cases describe application-specific business logic and is often implemented by a Controller (aka Interactor/ModelController/Service...) type collaborating with other components (coordinating domain models and application infrastructure abstractions). Controllers deal with application interactions (e.g., coordinating asynchronous operations from collaborators) with strict boundaries (protocol/closure) to protect the application from depending on low-level details (e.g., 3rd-party frameworks). It should not depend on concrete (specific) framework details. 

Domain Models describe application-agnostic business logic. This kind of logic is application-independent, also known as core business logic. Core business logic is often reused across Use Cases within the same application and even across other applications. It should not depend on any application or framework details. Domain Models are usually tiny little objects when compared with the size of the system. But its importance is much greater than its size. Domain Models implement the essential business logic (the code that really matters to the business), so we don’t lose sight of the domain within the technical and infrastructure complexities. Notice how, for example, we strive to keep our models simple, with no asynchronous or impure behavior (application detail) leaking into the domain models.

## Framework (Infrastructure) logic

Framework (Infrastructure) logic should not implement any business rules. Mixing business logic with infrastructure details is one of the most common (and one of the biggest mistakes) we find in codebases (e.g., Database and Network clients implementing validation or business rules operations or Domain Models inheriting from framework types, e.g., CoreData’s NSManagedObject). Doing so will scatter business logic across your code with no central source of truth. Tangled business rules and infrastructure code is harder to use, reuse, maintain, and test. 

Imagine how bad it can be if a database driver change (infrastructure detail) forced you to rewrite/migrate (costly/risky) all business rules for the new driver.

The more we separate code (the less a piece of code knows/does), the easier it is to develop, use, reuse, maintain, and test (because it will naturally depend on less context).

Infrastructure interface implementations should be as simple (dumb) as possible. It should only fulfill infrastructure commands sent by the Controller types through the abstract interface (protocol/closure). For example, Fetch something from the cache, Store purchase order or Download an image from a remote URL.

So far, we’ve defined two Infrastructure interfaces: HTTPClient and FeedStore. Which our two Controller types, RemoteFeedLoader and LocalFeedLoader use respectively.

## Entities vs. Value Objects

Entities are models with intrinsic identity. Value Objects are models with no intrinsic identity. Both can hold business rules.

In Swift, we don’t need objects (class instances) to represent types. So Value Object is often called Value Type or “just data” in Swift. Entities and Value Types can be represented by classes, structs or enums.

If a Value Type holds no state (in our case, the FeedCachePolicy only encapsulates the feed cache validation policy/rules), it can be replaced by static or free functions.

If a model has an identity or not, it depends on your domain. For example, a Money model may be a Value Object in some systems, representing a simple monetary amount (data) with its respective currency (data). 

struct Money {
    let amount: Decimal
    let currency: Currency
}
Money is a Value Object because it has no identity. It can be compared to other Money by comparing its values.

However, if you work on a system that prints and tracks money, there might be an identity to the printed bills to make sure it can be traced back.

struct Money {
    let id: MoneyID
    let amount: Decimal
    let currency: Currency
}
Money is an Entity because it has an identity.

## Side-effect free core business rules

Side-effect free logic seems more popular now with FP getting more attention, but such a concept has been around for a long time in OO land too. Keeping our core domain free from side-effects makes it extremely easy to build, maintain and test.

Side-effects (e.g., I/O, database writes, UI updates…) do need to happen, but not at the core of the application. The side-effects can happen at the boundary of the system, in the Infrastructure implementations.

This separation is also known as Functional Core, Imperative Shell.


Since there are no side-effects in the Functional Core components, they are deterministic (always return the same output for a given input).

For example, when we first extracted the cache validation code to the new FeedCachePolicy type, we allowed for side-effects to exist through the currentDate closure dependency. The currentDate closure is not a pure function since it will return a different result every time you call it. Core concepts like a policy are much more reliable when they have no side-effects (when they are pure functions). To remove side-effects in this case, we passed an actual Date value (immutable data), instead of passing an impure function that yields a non-deterministic Date. We shifted from initializer injection init(currentDate: () -> Date) to method injection with func validate(_ timestamp: Date, against date: Date) -> Bool where we pass a date value that can never change (immutable).

Now, it’s the LocalFeedLoader (Controller type) responsibility to fetch the current date and pass to the cache validation policy method to perform the business rules.

## A single source of truth
To reduce the cost of change, duplication and risk of making mistakes, we strive to create reusable components while hiding implementation details (from production code and tests) as much as we can. This includes constant values such as 7 days max age in the cache policy.

In this lecture, we first hide the 7 days max age detail from production by making it a private concept within the reusable FeedCachePolicy.

Then, we found out that many of the ValidateFeedCacheUseCaseTests and LoadFeedFromCacheUseCaseTests tests were specifying the cache expiration date (7 days) in their name and implementations. In case the expiration date changes (e.g., the business decided to change the date for legal reasons), we would have to make multiple edits in our system which is costly and error-prone.

To protect the codebase from such an event, we introduced the Date.minusFeedCacheMaxAge DSL. An interface that abstracts the notion of the cache max-age by hiding its actual value and at the same time make the function's clients agnostic to the date units used e.g., seconds, days, months. By doing so, we are free to safely and easily change the max cache age value from a centralized point on the system without having to replace other parts (clients).
