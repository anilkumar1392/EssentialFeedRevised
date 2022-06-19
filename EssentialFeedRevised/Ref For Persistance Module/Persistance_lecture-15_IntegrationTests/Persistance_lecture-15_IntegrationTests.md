## Finishing the Cache Implementation with Business Logic + Core Data Integration Tests—Unit vs. Integration: Pros/Cons, Performance, Complexity & How to Achieve The ideal Testing Pyramid Distribution

1. How to create and separate integration test from Unit(Isolated) tests.

Goal: To keep isolated test as fast as possible.

Unit Test: are the primary feedback mechanism.
Unit Test(Isolated test): Should be fast, so you can run them several times a day without affecting productivity.
Isolated test give us fast and continuous feedback and also confidence that our components work as intended.

##Integration Tests:

Give us confidence that components collaborate as intended.
With no mocks and any other ttpes of testables.

However Integration tests can be slow so you won't be running them as often as fast as isolated tests.

While calling api
Interacting with databases or filesystems.

All tests (isolated & Integartion) hould run in your continuous integration pipeline.


## The Goal

The idea is to integrate all the cache model objects and see how they behave in collaboration or in integration.

In Unit/isolated tests, we preper to run operations in memory when possible, which should be ultra fast.

In Integration tests, we prefer to use a stack of production instances, with no test doubles.
This includes a physical file URL to make sure we can create and load the CoreData SQLLite artifacts to disk, which can slow down the tests.

When we isolate the components we have the cost of integrating them.
and if we don't manage, this create a mess in the codebase.

## we have written test for happy path what about error cases.

We are testing all possible scenarios on a component level in unit test cases.
If we were to test all the edge cases in integration tests the number of tests will grow exponentially depending on the number of components that participate in integration.


More components, more tests and more edge cases.
### When you test the edge cases in unit when you compose them together. 

we can only test happy path in integration.

For eg: we can't force an error at the integration level but I can mock an error at the unit level.

Test all the edge cases in unit test
and then integrate all the components and see how they behave.


## We can directly replace CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle) with CodableFeedStore(storeURL: storeURL)

This is possible because of powerful techiques we have used like,
1. Dependency Inversion
2. Liskov subsitution principle
3. Interface segregation principle
4. Dependency Injection

So we have two implementation that behave exactly the same but they are having completely different framework behid the scenes.


## In this lecture, you’ll learn how to create and separate integration tests from the unit or, as also known, isolated tests. The goal is to keep the isolated tests as fast as possible, as they are the primary feedback mechanism for developing our applications. On the other hand, integration tests give us confidence that our isolated components work well when collaborating together, with no mocks or any other type of test doubles.

Learning Outcomes
Unit/Isolated vs. Integration Tests: pros/cons, performance, complexity, and how to make the most out of both.
Achieving a healthy distribution of testing strategies (the ideal testing pyramid).

##Anatomy of an integration test
There are many different types of tests, i.e., unit, integration, performance, UI, etc. but no agreed definitions in the industry.

In this course, we will define an integration test as any test that checks two or more components collaborating without mocks, stubs, spies, or any other test double. That is opposed to a single behavior being checked by a single component in a unit or isolated test.

So far in this course, we have adopted unit/isolated testing as the primary testing strategy, and we strive to shape the behavior of the components through our unit tests (always writing a test before writing production code).

A critical difference between integration and unit/isolated tests as the primary testing strategy is how much you need to know or how many decisions you have to make up front. Integration tests often require us to make many more upfront decisions!

For example, when we first started test-driving the LocalFeedLoader class with isolated tests, we didn’t have any knowledge of what persistence solution we would end up using in production (no need for upfront decision).

Without an initial persistence framework choice, we focused on defining the LocalFeedLoader persistence needs via an abstract interface (the protocol). So while test-driving the LocalFeedLoader we defined the <FeedStore> protocol methods (a contract) that any persistence mechanism implementation has to conform to.

By introducing the <FeedStore> protocol boundary between these two components and using stubbing and spying techniques we could check that the LocalFeedLoader behave correctly with a test-specific implementation of the <FeedStore>: the FeedStoreSpy class.

We are confident the LocalFeedLoader works as intended even though we didn’t have a real persistence store implementation at the time we developed it!

The following figure illustrates the visibility of the LocalFeedLoader while being developed in isolation:

## On the other hand, if we were to test-drive the LocalFeedLoader in integration with a real infrastructure implementation, the LocalFeedLoader tests would include the CoreDataFeedStore for example.

## 1. A tendency for tight coupling and lousy design decisions
Implementing business logic (e.g., LocalFeedLoader use cases) based on a concrete framework (e.g., Core Data) opens the door for making wrong design decisions up front, potentially creating a tight coupling between the LocalFeedLoader and Core Data.

As we’ve seen in many codebases, a clean boundary would not even be created between the business logic (high-level) and infrastructure details (low-level).

Such design decisions could yield short-term results, but with potentially substantial long-term loss (e.g., high complexity as Core Data has a complex architecture and set of features that would be pushed to the business logic layer, immobility or lack of flexibility due to high coupling, test performance penalties…). Which can lead to a decrease in productivity and, of course, frustration to the team and customers.

The need for too many upfront decisions also leads to issues such as:

Analysis paralysis: can’t decide on actions for lack of information or fear of negative impacts of the decision.
Burnout: working in big batches and not often merging, leading to nightmarish merge conflicts, inability to estimate work, missed deadlines, development & product bottlenecks, and eventually low morale and high turnover.
Bugs & Regressions: inability to write good tests, leading to faulty software.

## 2. Limited team collaboration
If you need a real implementation to develop and test another component, then you lose the ability to efficiently allocate resources, such as breaking down tasks and assigning them to many devs. In other words, independent development within a team.

If you don’t create a contract boundary between the LocalFeedLoader (business logic) and the CoreDataFeedStore (infrastructure implementation), you would need to create both components at once. As a result, your team’s productivity slows down as it would be impossible to develop in parallel effectively.

More importantly, tight coupling makes tiny/isolated changes hard (or impossible), meaning many nightmarish merge conflicts when working in a team (the bigger the team, the worse the merges become!).

Apart from merge conflicts, a good indicator (that you can automate) to check tight coupling is to measure the number of files changed per commit/pull request. A high number of files changed indicates tight coupling or lousy abstractions that lead to a massive decrease in productivity.

If the complexity introduced by the integration tests isn’t contained and handled correctly, it can quickly and easily result in an unmaintainable test suite (which eventually the team will be forced to abandon).

3. Testing can quickly become an unsustainable/costly liability for the team and the company
The number of tests required when testing in integration is equivalent to at least the amount of combination of states the components participating in the integration can be at.

For example, if component A has 4 possible states, and component B has 5 possible states, you need 20 tests (4x5) to guarantee correctness when relying on integration tests as the primary testing strategy. In contrast, if you were to test A and B in isolation, you’d need 9 isolated tests (4 tests for A and 5 tests for B, or 4+5), which indicates a 50% decrease in testing effort in this case (even when you add and one or two integration tests as recommended).

Additionally, the growing number of integrated components will result in a significantly larger setup code for each test and increasing test times.

Remember that integration tests usually combine real implementations (instead of mocks or test doubles) which means the tests will perform behavior checkings through stateful operations on infrastructure implementations such as UI, Network, Databases, etc.

As you scale to systems with hundreds or thousands of possible states, these drawbacks quickly accumulate to an unsustainable/unmaintainable level.
