### Decoupling Use-Case Business Logic From Framework Details + Controlling Time + Multi-Method Abstractions Following The Interface Segregation and Single Responsibility Principles

Learning Outcomes
Decoupling business logic encapsulated in use cases from framework details.
Test-driving and discovering collaborator interfaces without abstracting too early.
Enriching test coverage by asserting the presence, the order, and values of method invocations.
Disciplined application of the Interface Segregation and Single Responsibility Principles.
Controlling the current date/time during tests.
Emerging behaviors
In our quest for designing and maintaining flexible systems, we strive to decouple business logic from any framework implementation details. 

When we refer to the term “business logic” or “business rules” encapsulated in use cases, you can think of them as what the system must do; leaving the framework implementations to perform the how to do it. Notice how the dependency is from the framework towards the business logic, since the "how it's done" needs to conform to the "what should be done". While the what is agnostic of the how.

It’s important to understand the distinction between the notions of “business logic” and “implementation details” and how to properly separate them. This distinction is imperative for achieving a level of freedom that allows us to change parts of the system without affecting the whole. A clear separation of concerns allows us to create decentralized components that are agnostic of the internals of their collaborators and have access only to essential-for-their-functionality behaviors. Such a degree of freedom makes changes in the codebase easier and cheaper, allowing the team to welcome new requirements. Also, it makes the codebase more resilient as it decreases the number of places that can break when a code change is required (avoiding component, modular and even systemic level breakage). 

For example, in the Cache Feed Use Case, we don't want to let storage frameworks dictate the Use Case interfaces because that would result in tight coupling of the Use Case with storage framework’s needs (e.g., Codable requirements or CoreData managed object contexts and entities as parameters). Instead, we opt to test-drive the interfaces the Use Case needs for communicating with its collaborators, rather than defining the interface upfront to facilitate a specific framework implementation. Then, we can implement the interfaces in a separate component that communicate with the frameworks. This technique is called Dependency Inversion. Instead of depending on framework requirements/details, we make the framework depend on our needs.

The main difference that you might have noticed is that, while test-driving the use case, we represented the framework side with the FeedStore helper class. Doing so helped us define the abstract interface the Use Case needs for its collaborator while making sure not to leak framework details into the Use Case. By creating a class, instead of starting with a protocol, we have the flexibility to change its behaviors and properties without breaking a contract introduced by a (maybe too early) protocol abstraction. It wasn’t until the end of the lecture that we extracted the final production interface in a new FeedStore protocol and renamed the class to FeedStoreSpy conforming to the newly made protocol. Thus, creating the necessary dependency inversion between the LocalFeedLoader and lower-level caching mechanisms. 

Controlling the current time
“Why is time passing so quickly these days?!”

The Date.init() is not a pure function because every time you create a Date instance, it has a different value–the current date/time. And as we all know, “time flies!”

Instead of letting the Use Case produce the current date via the impure Date.init() function directly, we can move this responsibility to a collaborator (a simple closure in our case) and inject it as a dependency. Then, we can easily control the current date/time during tests!

The ideal number of methods in a protocol
Ideally, one! It’s much easier to deal with dependencies that do only one thing. The more methods, the more possible paths there are in the code. In this lecture, we faced some of the difficulties of dealing with abstractions with more than one possible way when we had to also check the order of method invocations in our tests. Breaking down methods in separate protocols can solve this problem, while also allowing us to decentralize implementations. However, there are times where it makes sense to add multiple method declarations to a protocol. The Single Responsibility Principle (SRP) is a great guideline. Ask yourself: are all methods related and responsible for one and only one responsibility (e.g., cache management)? If it’s a no, you should probably create a new protocol unless you have a better reason not to. In our case, it's a yes, as the action of inserting and deleting a cache are related. For instance, their side-effects affect each other's results.

Applying such discipline on your protocol definitions is also supported by the Interface Segregation Principle (ISP): no client should be forced to depend on methods it does not use. So, in the FeedStore protocol, we decided to, for the first time in this course, add more than one method to the protocol since they’re related and responsible for one responsibility and the client depends on both methods.

But what about Sequence and Collection, for example, in the standard library? Don’t they have many methods and a long inheritance hierarchy?! Yes, they do, but the methods are all related in solving universal abstractions on the types they represent! Additionally, the inheritance hierarchy combined with conditional conformance allows the decomposability (and composability) of those types to make them useful to the library clients (us, Swift developers!).
