## Core Data Overview, Implementation, Concurrency Model, Trade-offs, Modeling & Testing Techniques, and Implementing Reusable Protocol Specs


Since we have all the businees logic in the core type the infrastructure implementaation is quite simple.

Codabase will be more complex when we mix both bussiness logic and infrastructure (Framework) logic details.

Thats why this seperation between them is so important.
You end up with less complexity and less mistakes.

## Learning Outcomes
Core Data overview, implementation, concurrency model, trade-offs, modeling, and testing techniques
Implementing reusable protocol specs


## Core Data overview
Core Data is a persistence solution framework developed and maintained by Apple, available on iOS, macOS, tvOS, and watchOS. Core Data is designed to work in a multithreaded environment allowing developers to save their application’s permanent data for offline use and cache temporary data.

To define your schema data types and relationships, you use the Data Model editor, which also allows you to generate the respective class definitions if you wish.

One of the most significant advantages of Core Data is that it abstracts the details of mapping objects to a store, so you don’t have to interact with a database directly.

Core Data offers an undo manager for tracking changes and rolling back, making it easy to add undo and redo support to the app. It also includes mechanisms for versioning the data model and migrating user data as the app evolves.

The framework makes use of batch processes allowing you to manage large data changes efficiently.

Top Upsides:

Model relationships
Efficient storage and caching strategies
Lightweight migrations
Offers multiple ways for dealing with concurrency
Undo capabilities
Efficient batch processing
Offers high-level API for not dealing with complex database operations directly
Top Downsides:

Steep learning curve
Complex architecture
Backing stores are plain-text (e.g., SQLite or XML), so there is no out-of-the-box/easy way to encrypt the data yet (apart from regular Data Protection which requires touch/face id or password).

## Core Data concurrency model
“Core Data has a straightforward concurrency model: the managed object context and its managed objects must be accessed only from the context’s queue. Everything below the context — i.e. the persistent store coordinator, the persistent store, and SQLite — is thread-safe and can be shared between multiple contexts.”—Florian Kugler. “Core Data”

When performing operations on an NSManagedObjectContext instance make sure to execute the operations on the queue specified for the context by enclosing in them in a perform(_:) closure block. NSManagedObjectContext.perform executes the block on its own thread, which is imperative for not causing possible multi-thread concurrency issues.

NSManagedObjectContext.perform returns immediately, executing the closure asynchronously. The synchronous variation of the perform method comes with the NSManagedObjectContext.performAndWait method. In this case, the context still executes the closure block on its own thread, but the method doesn’t return until the block is executed.

## Fetching small datasets
Since our dataset is small, we decided to load the full dataset and then operate on it in memory. You can do so with a single fetch request by setting fetchBatchSize to 0 (the default) and returnsObjectsAsFaults to false.

## “Why not use Core Data models everywhere?”
The reason we don’t recommend using Core Data models everywhere is that we value a clean separation from business logic and frameworks.

By establishing a boundary (e.g., the <FeedStore> protocol) between the business logic and the infrastructure implementations, we isolated and decoupled core business logic from frameworks, like Core Data. More importantly, this separation has led to extremely simple production code and fast and reliable test code.

As another benefit, the cost and effort of switching the persistent store solution (e.g., to Realm) would be extremely low.

If it weren’t for this separation and we were to use Core Data models everywhere, the system would be tightly coupled with Core Data and its complex architecture, forcing us to try and fit our domain challenges into the Core Data framework, which is rarely a great match.

Isolating and constraining frameworks and maintaining modularity is critical when we, as developers, have to welcome constant and rapidly changing requirements.

“A lot of the downside of frameworks can be avoided by applying them selectively to solve difficult problems without looking for a one-size-fits-all solution. Judiciously applying only the most valuable of framework features reduces the coupling of the implementation and the framework, allowing more flexibility in later design decisions. More important, given how very complicated many of the current frameworks are to use, this minimalism helps keep the business objects readable and expressive.” – Eric Evans. “Domain-Driven Design: Tackling Complexity in the Heart of Software”

## Distinct Model representations
When separating business logic from frameworks, it’s often necessary to create distinct model representations. One representing the business model and another representing the framework model. If we are to mix both in the same model, we may end up leaking framework details into the business layer (creating implicit or hidden dependencies).

The image below shows the clear separation and model representation of the image feed data per module:

The CoreDataFeedStore, backed by the Core Data persistent store requires its own way for modeling data through NSManagedObject subclasses.

So far, we have been treating representations of the feed image as immutable structs. However, Core Data represents models with classes (hence the NSManagedObject subclassing), meaning that we are no longer dealing with immutable data but with mutable references. Moreover, Core Data models have two-way relationships, i.e., ManagedCache holds a one-to-many relationship with ManagedFeedImage.

In the case of the ManagedFeedImage, the cache relationship is a Core Data (framework specific) implementation detail that should not leak into the LocalFeedImage or any other core models.

To avoid leaking of implementation details, we created the module/domain specific models that can map their underlying data to the model required by their clients. In this case, the ManagedFeedImage data will be transformed back into a LocalFeedImage, an immutable struct.

## Testing remarks on Core Data implementations
Choosing the correct bundle for loading the data model
To load the Core Data store in CoreDataFeedStoreTests, which is part of the test target, we need to locate the Core Data data model in the bundle. Since the data model file lives in the main production bundle which is different than the test bundle it’s essential that we choose the correct bundle to load the model from.

We decided to solve this problem by injecting the correct bundle when testing, while in production, we use the main bundle as a default value.

## Pointing the store at /dev/null
The null device discards all data directed to it while reporting that write operations succeeded.

By using a file URL of /dev/null for the persistent store, the Core Data stack will not save SQLite artifacts to disk, doing the work in memory. This means that this option is faster when running tests, as opposed to performing I/O and actually writing/reading from disk. Moreover, when operating in-memory, you prevent cross test side-effects since this process doesn’t create any artifacts.

Alternatively, you can create a Core Data stack with an in-memory persistent store configuration for the tests.

## Sharing side-effects between in-memory stores
If you want/need to share side-effects between multiple in-memory Core Data stacks during tests (e.g., to test synchronization between multiple store coordinators), you can use a named in-memory store. To do so, give a “name” for the in-memory store by appending a path component to the /dev/null URL:

let storeURL = URL(fileURLWithPath: "/dev/null").appendingPathComponent("a name")

"Any other SQLite store with that [named] URL in the same process will connect to the same shared in-memory database."—Scott Perry “Making Apps with Core Data, Session 230, WWDC 2019"
