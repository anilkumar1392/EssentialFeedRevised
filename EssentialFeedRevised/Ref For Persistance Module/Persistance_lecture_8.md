########
# Lecture 8

## In this lecture, we extract the cache validation from the Load Feed Cache Use Case to its own use case (Validate Feed Cache Use Case), separating the loading from the invalidation (deletion) logic and respecting the Command–Query Separation principle.

- Separarte query from commands with side effects.
In this case by using the Command - Query principle we are Separating All tests with side effects in different file.

- we are separating the concerns here.
    - Separating loading from the invalidation logic.


Learning Outcomes
Separating queries and side-effects by following the Command-Query Separation principle
Choosing between enum switch strategies: Explicit Cases vs. default vs. @unknown default
Producing a reliable codebase history (always in a working state)
Identifying Application-specific vs. Application-agnostic logic


#######
### Command–Query Separation (CQS)
As discussed in the previous lecture, the Command-Query Separation is a programming principle that can help you identify functions/methods that do too much. The idea is simple:

A Query should only return a result and should not have side-effects (does not change the observable state of the system).

A Command changes the state of a system (side-effects) but does not return a value.

By following the principle, we identified that the action of loading the feed from cache is a Query, and ideally should have no side-effects. However, deleting the cache as part of the `load` alters the state of the system (which is a side-effect!).

Thus, in this lecture, we separate loading and validation into two use cases, implemented in distinct methods: load() and validateCache().

A great benefit of separating the functionality is that now we can [re]use both actions in distinct contexts.

For example, we can schedule cache validation every 10 minutes or every time the app goes to (or gets back from) the background (instead of only performing it when the user requests to see the feed).


### Should we keep the old tests after extracting the side-effects to a new method?
If a new functionality makes the old one irrelevant, we don’t have to keep old tests (or even the old functionality!).

We could have deleted the side-effect tests from the load method. However, in our case, the load method is still relevant to the application. What we did instead was to replace the old load method tests, regarding deletion side-effects, with new assertions to guarantee there are no side-effects.

In our opinion, it still makes sense to keep the tests, as it also serves as documentation about the intention: there should never be side effects in the load method.

#######

Application-specific vs. Application-agnostic logic/rules
Use Cases describe application-specific logic. But Use Cases derive from business requirements, so they inherently describe business logic. Thus, Use Cases describe application-specific business logic!

Inside Use Case requirements, you can also find application-agnostic logic. This kind of logic is application-independent, also known as core business logic. Core business logic is often reused across Use Cases within the same application and even across other applications.

When we identify core business logic (e.g., high-level rules and policies), we should strive to separate it from application-specific logic.

Rules and Policies (e.g., validation logic) are better suited in a Domain Model that is application-agnostic (so they can be [re]used across context/applications).

In short, a specific Use Case may not suit every application, but the Core Business Models/Rules/Policies do.

The LocalFeedLoader collaborates with other types to solve Use Case requirements. It is a Controller type (aka Interactor/Model Controller) and should encapsulate application-specific logic only. When needed, it communicates with Domain Models to perform core business logic.

In the next lecture, we’ll extract the application-agnostic rules (validation policy) out of the LocalFeedLoader into a new reusable Domain Model.
