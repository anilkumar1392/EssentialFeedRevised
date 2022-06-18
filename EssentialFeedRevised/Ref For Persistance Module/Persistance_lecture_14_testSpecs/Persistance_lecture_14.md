
## Lecture 14
## Protocol vs Class Inheritance, Composite Reuse Principle, and Extracting Reusable Test Specs with Protocol Inheritance, Extensions and Composition

One assertion per test keeps the test clean.
1. Breakdown 'CodableFeedStore' tests to guarantee that their is only one assertion per test. The Goal is to clarify the behavior under test unser test in small units. so we can extract the behaviour test in to reusable specs.

2. Extract reusable 'FeedStoreSpecs' helper method in to a shared scope so it can be reused by other 'FeedStore' implementation

Liskov Substitution Principle.
Interface Segregation Principle (ISP): No client should be forced to depend on methods it does not use.

Liskov Substitution Principle (LSP): Objects in a program should be replaceable with instances of their subtypes without altering the correctness of the program.

Objects in a program should be replaceable with instance of their subtypes with out altering the correctness of the program.

Implementation of feedStrore are subtypes of 'FeedStore' interface.

And any implementation of FeedStore can be passed to those assertion methods which makes thos assertion and helepr methods reusable.


we are leveraging protocol Inheritance and extension which makes the specs composable by dictating the minimum requirment. 

##In this lecture, you’ll learn how to extract reusable test specs to facilitate the correct/expected implementation of protocols as we extract the <FeedStore> protocol specs. To do so, you’ll learn how to leverage Swift’s protocol inheritance, extensions, composition, and conditional conformance to create clean & reusable abstractions. You’ll also learn how such concepts strongly relate to the Liskov Substitution (LSP) and Interface Segregation (ISP) principles.

Learning Outcomes
Forming good abstractions by following the Liskov Substitution and Interface Segregation principles
Protocol vs. Class inheritance
Composite Reuse Principle (aka “Prefer composition over inheritance”)
Extracting reusable test specs to facilitate the correct/expected implementation of protocols
Using Swift’s protocol inheritance, extensions, composition, and conditional conformance to create clean & reusable abstractions
Creating explicit and straightforward test contexts

##Forming good abstractions by following the ISP and LSP
“To achieve concise and reusable abstractions, we should avoid stuffing all method declarations into a single protocol. Thus, we should aim to separate the interface/protocol’s methods into as many interfaces as needed by their specific clients. By doing so, we can avoid concrete implementations having to implement any unnecessary methods, the Liskov Substitution Principle (LSP), while decoupling clients from methods they do not need, the Interface-Segregation Principle (ISP).”– The Lead Developer Essentials, Part 3: The Codebase

When we declared the FeedStoreSpecs we could have included all test methods in the protocol, including the ones asserting the failure cases, of CodableFeedStoreTests. After all, they are “feed store specs” as well. Although that’s true, future implementations of the FeedStoreSpecs protocol that can’t fail, e.g., an in-memory store, would end up with empty implementations for these methods.

Adding optional/unnecessary methods to a protocol not only can confuse other developers but also damage the modular and reusable nature of components, by violating the Interface Segregation (ISP) and Liskov Substitution (LSP) principles.

Interface Segregation Principle (ISP): No client should be forced to depend on methods it does not use.

Liskov Substitution Principle (LSP): Objects in a program should be replaceable with instances of their subtypes without altering the correctness of the program.

Following the ISP and LSP requires discipline. Before declaring a protocol with more than one method, take some time to think if all implementations of the protocol should implement all of its methods. If not, then you should consider a way for segmenting the methods into more than one protocol, respecting the ISP and LSP.

## Class vs. Protocol Inheritance
It’s not advised to use class inheritance to reuse/share code and functionality. Class inheritance is better used to extend functionality (additive changes to an existing implementation).

To reuse/share functionality, composition is often a better choice. That’s where the famous “Prefer composition over inheritance” quote comes from (aka Composite Reuse Principle).

Class composition is achieved by containing other classes (e.g., as properties) that implement the desired functionality, rather than relying on inheritance (subclassing) for sharing functionality.

Furthermore, in Swift, class composition through inheritance is not possible because a class can only inherit from one class.

Instead of relying on class inheritance for sharing functionality, Swift has better alternatives to achieve composition, polymorphic behavior, and code reuse: protocol inheritance, extensions, type constraints, and conditional conformance.

## “A protocol can inherit one or more other protocols and can add further requirements on top of the requirements it inherits.”—Apple Inc., The Swift Programming Language

In this lecture, we decided to break down the specs into separate protocols and make the failable specs protocols: <FailableRetrieveFeedStoreSpecs>, <FailableInsertFeedStoreSpecs>, <FailableDeleteFeedStoreSpecs>, conform to the main <FeedStoreSpecs> protocol.

The failable protocols are specialized cases of the main <FeedStoreSpecs> protocol. This means that any components implementing the failable specs must also implement the main <FeedStoreSpecs> protocol. Swift offers a way to enforce such a constraint with protocol inheritance.

##Aiming for a single assertion per test
After declaring the failable spec protocols we realized an inconsistency with the number of methods declared in these protocols:

<FailableRetrieveFeedStoreSpecs> had two test methods.
<FailableInsertFeedStoreSpecs> had one test method.
<FailableDeleteFeedStoreSpecs> had one test method.

Upon further investigation we discovered that FailableInsertFeedStoreSpecs.test_insert_deliversErrorOnInsertionError() was asserting both that the insert method implementation:

delivers error on insertion error
has no side effects on insertion error
Visualizing the test methods through the interface overview made visible the fact that some tests were asserting two behaviors instead of just one, breaking the single assertion per test guideline.

Although the double-assertion tests yielded full coverage, they were asserting distinct behaviors within the same context, which is often an anti-pattern.

For example, we were mixing the “should deliver error behavior” with the “should have no side effects behavior” in one single test. By separating these two behaviors in separate test methods, we create explicit and straightforward contexts that can serve as clear documentation and facilitate further implementations and maintenance!

You should strive to create explicit and straightforward test contexts.

The test method count inconsistency became apparent after breaking and grouping the specs into separate protocols. Observing your code through different points of view (e.g., dependency diagrams, flowcharts, interface overview, etc.) is essential as it can help you validate your design and identify potential issues before they become critical.
