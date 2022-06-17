
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
