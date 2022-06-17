
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

     So we separated policy from applicaiton specific bu
     
     You dictate your architecture.
     Not the framework dictate our architecture.
     
     Side effects happen on the boundaries of the system.
     
     Model make then deterministic as much as you can with no side effects.
