
### Lecture 1
  URLCache as a Persistence Alternative & Solving The Infamous “But it works on my machine!” Caching Problem
URLCache as a caching/persistence alternative (pros and cons)
Depicting an architecture diagram of implicitly coupled Networking and Caching modules
Improving the test suite integrity by eliminating shared caching artifacts across test executions
Improving test suite integrity with ephemeral configuration


### Lecture 2
  Clarifying Requirements, Enhancing Cross-Team Domain Knowledge, and Iterative vs. Big Upfront Design

### Lecture 3
Dependency Inversion:

For example, in the Cache Feed Use Case, we don't want to let storage frameworks dictate the Use Case interfaces because that would result in tight coupling of the Use Case with storage framework’s needs (e.g., Codable requirements or CoreData managed object contexts and entities as parameters). Instead, we opt to test-drive the interfaces the Use Case needs for communicating with its collaborators, rather than defining the interface upfront to facilitate a specific framework implementation. Then, we can implement the interfaces in a separate component that communicate with the frameworks. This technique is called Dependency Inversion. Instead of depending on framework requirements/details, we make the framework depend on our needs.
Controlling the current time
The ideal number of methods in a protocol


### Lecture 4
  Proper Memory-Management of Captured References Within Deeply Nested Closures + Identifying Highly-Coupled Modules
Checking expected behavior after deallocation.
Identifying highly coupled modules with a visual representation of dependencies.

In modular systems, the goal is to achieve low coupling between modules, and high cohesion within each individual module.



### Lecture 5
  Visualizing and Solving High-Coupling Issues by Decentralizing Components Using Data Transfer Model Representations
### In this module we are writing code and test to save feed in local DB

Visualizing and solving dependency bottlenecks.
Data transfer model representations for achieving modularity.
Decentralizing components to develop and deploy parts of the system in parallel.

Unified vs Segregated Models.
A model should be a simple and consistent representation of a domain concept. When we share models across boundaries, it gets easy to start adding methods and properties that one of the modules need, let's say the API, but the others (e.g., UI, Analytics, and Persistence) don't. When this happens, our models grow in size and start to lose consistency. 

The system's boundaries, based on their specifications, may require multiple model representations. Opting to use a single model across modules may lead to complex, costly-to-maintain, and hard-to-use code. “Trying to solve everyone’s problems at once will solve no one’s.” 

Thus, instead of always passing models across boundaries, consider using a data transfer representation (also known as data transfer objects or DTO).



### Lecture 6. 
### Performing Calendrical Calculations Correctly, Dealing With Coincidental Duplication While Respecting the DRY Principle, Decoupling Tests From Implementation With Tiny DSLs, and Test Triangulation to Increase Coverage & Confidence

1. Duplicating code in different contexts
  like writing same test in diff files but their context is different.
  Before deleting duplication, investigate if it's just a coincidental duplication: code that seems the same but conceptually represents something else. Mixing different concepts makes it harder to reason about separate parts of the system in isolation, increasing its complexity.
2. In this lecture we are writing cases for loading data from store.
3. Handling Triangulation line less than, equal to and more than.
4. Calendrical calculations
When performing date calculation make sure to use system tools that can account for edge cases and scenarios that can be easily missed by developers.

### Lecture 7.
  Test-driving Cache Invalidation + Identifying Complex (Bloated) Functionality With The Command–Query Separation Principle

// The Command–Query Separation Principle :
Seperate query from commands with side-effects.

### Lecture 8 
 Separating Queries & Side-effects for Simplicity and Reusability, Choosing Between Enum Switching Strategies, and Differentiating App-Specific from App-Agnostic Logic
 
 // Adding ValidateFeedCacheUseCaseTests to confirm to Command-query principle

 ### Lecture 9
 Separating App-specific, App-agnostic & Framework logic, Entities vs. Value Objects, Establishing Single Sources of Truth, and Designing Side-effect-free (Deterministic) Domain Models with Functional Core, Imperative Shell Principles

    /*
     Seperate application specifc details from bussiness rules.
     Controller are not business models.
     They communicate with bussiness model to solve application specific bussiness rules.
     By separating bussiness models, controllers and frameworks is key to achieve modularity, freedom.
     */
     
     Bussiness Rule: Policy 
     Applicaiton specifc bussiness logic : Controllers
     Applicaiton specifc logic from concrete framework details: FeedStore protocol protects our controller (LocalFeedLoader) from concrete store implementation (like coredata, realm, filesystem).

     So we separated policy from applicaiton specific logic.
     
     You dictate your architecture.
     Not the framework dictate our architecture.
     
     Side effects happen on the boundaries of the system.
     
     Model make then deterministic as much as you can with no side effects.

 ### Lecture 10
## Dependency Inversion Anatomy (High-level | Boundary | Low-level), Defining Inbox Checklists and Contract Specs to Improve Collaboration and Avoid Side-effect Bugs in Multithreaded Environments
Requirment feed store implementation.

- Retrieve
    - Empty cache
    - Empty cache twice return empty (no side effects)
    - Non empty cache 
    - Non - empty cache twice returns same data (no side effects)
    - Error return error (if applicable, e.g, Invalid Data)
    - Error twice returns same error (if applicable, e.g, Invalid Data)

- Insert
    - To empty cache Stores data
    - To non empty cache overrides previous data with new data
    - Error (if applicable, if not write permission)
    
- Delete
    - Empty cache does nothing (Cache tays empty and does not fail)
    - Non empty cache leaves cache empty
    - Error (if applicable, if delete permission)
    
- Side effects must run serially to avoid race conditions.

## Lecture 11
## Persisting/Retrieving Models with Codable+FileSystem, Test-driving in Integration with Real Frameworks Instead of Mocks & Measuring Test Times Overhead with `xcodebuild`

- Retrieve
    ✅ Empty cache returns empty
    ✅ Empty cache twice returns empty (no side-effects)
    ✅ Non-empty cache returns data
    - Non-empty cache twice returns same data (no side-effects)
    - Error returns error (if applicable, e.g., invalid data)
    - Error twice returns same error (if applicable, e.g., invalid data)

- Insert
    ✅ To empty cache stores data
    - To non-empty cache overrides previous data with new data
    - Error (if applicable, e.g., no write permission)

- Delete
    - Empty cache does nothing (cache stays empty and does not fail)
    - Non-empty cache leaves cache empty
    - Error (if applicable, e.g., no delete permission)

- Side-effects must run serially to avoid race-conditions

## Lecture 12
## Deleting Models and Handling Errors with Codable+FileSystem, Making Async Code Look Sync in Tests to Eliminate Arrow Anti-Pattern, and More Essential Test Guidelines to Improve Code Quality and Team Communication
✅ Retrieve
    ✅ Empty cache returns empty
    ✅ Empty cache twice returns empty (no side-effects)
    ✅ Non-empty cache returns data
    ✅ Non-empty cache twice returns same data (no side-effects)
    ✅ Error returns error (if applicable, e.g., invalid data)
    ✅ Error twice returns same error (if applicable, e.g., invalid data)
✅ Insert
    ✅ To empty cache stores data
    ✅ To non-empty cache overrides previous data with new data
    ✅ Error (if applicable, e.g., no write permission)
✅ Delete
    ✅ Empty cache does nothing (cache stays empty and does not fail)
    ✅ Non-empty cache leaves cache empty
    ✅ Error (if applicable, e.g., no delete permission)
- Side-effects must run serially to avoid race-conditions

## Lecture 13
Designing and Testing Thread-safe Components with DispatchQueue, Serial vs. Concurrent Queues, Thread-safe Value Types, and Avoiding Race Conditions

✅ Retrieve
    ✅ Empty cache returns empty
    ✅ Empty cache twice returns empty (no side-effects)
    ✅ Non-empty cache returns data
    ✅ Non-empty cache twice returns same data (no side-effects)
    ✅ Error returns error (if applicable, e.g., invalid data)
    ✅ Error twice returns same error (if applicable, e.g., invalid data)
✅ Insert
    ✅ To empty cache stores data
    ✅ To non-empty cache overrides previous data with new data
    ✅ Error (if applicable, e.g., no write permission)
✅ Delete
    ✅ Empty cache does nothing (cache stays empty and does not fail)
    ✅ Non-empty cache leaves cache empty
    ✅ Error (if applicable, e.g., no delete permission)
✅ Side-effects must run serially to avoid race-conditions

## Lecture 14
## Protocol vs Class Inheritance, Composite Reuse Principle, and Extracting Reusable Test Specs with Protocol Inheritance, Extensions and Composition

We are going to extract reusable 'FeedStore' SPECS to feclitate implementation of databases such as CoraData, realm.

One assertion per test keeps the test clean.
1. Breakdown 'CodableFeedStore' tests to guarantee that their is only one assertion per test. The Goal is to clarify the behavior under test unser test in small units. so we can extract the behaviour test in to reusable specs.

2. Extract reusable 'FeedStoreSpecs' helper method in to a shared scope so it can be reused by other 'FeedStore' implementation

Liskov Substitution Principle.
Interface Segregation Principle (ISP): No client should be forced to depend on methods it does not use.

Liskov Substitution Principle (LSP): Objects in a program should be replaceable with instances of their subtypes without altering the correctness of the program.

Objects in a program should be replaceable with instance of their subtypes with out altering the correctness of the program.

Implementation of feedStrore are subtypes of 'FeedStore' interface.

And any implementation of FeedStore can be passed to those assertion methods which makes thos assertion and helepr methods reusable.

## Lecture 15
## Core Data Overview, Implementation, Concurrency Model, Trade-offs, Modeling & Testing Techniques, and Implementing Reusable Protocol Specs


Since we have all the businees logic in the core type the infrastructure implementaation is quite simple.

Codabase will be more complex when we mix both bussiness logic and infrastructure (Framework) logic details.

Thats why this seperation between them is so important.
You end up with less complexity and less mistakes.
