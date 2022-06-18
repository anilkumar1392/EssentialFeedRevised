## Persisting/Retrieving Models with Codable+FileSystem, Test-driving in Integration with Real Frameworks Instead of Mocks & Measuring Test Times Overhead with `xcodebuild`

1. Downside of using real time implementaiton of Codable is we are storing data in real time and this will effect the  whole system.
2. Upside is we are testing real behaviour.

Down side of not mocking the file system.

So we need to clean a disk every time we run a test.

While encoding and decoding we have made a change in production Type by conforming FeedImage confirm to Codable.

This may seems a minor change but we are adding framework dependency in model.
In future we may use realm so we will be adding realm dependency their.
Let's fix this.

We can do this by creating a local CodbaleFeedImage.


##Learning Outcomes
Encoding and decoding models with Codable
Persisting model data to disk
Retrieving model data from disk
Test-driving infrastructure components in integration with real frameworks instead of mocks
Preventing hard-to-debug test issues in stateful components by cleaning up the system state before and after test executions
Preventing hidden-coupling implications of cross-boundary Codable requirements
Improving testability, maintainability, and reusability by moving from implicit hardcoded data to explicit data injection
Using xcodebuild to measure test times and discover potential overheads
Codebase health analysis

## Balancing the trade-offs of cross-boundary Codable requirements
In this lecture, we dealt with a common type of decision while pondering if we should make the LocalFeedImage conform to the Codable protocol or not.

This is the type of situation where the framework, language or platform used incentivize the developer to decide based on the ultimate convenience the decision bears. In this case, Swift hides from the developer all the complexity and volume of code that comes from encoding and decoding models with single conformance to Codable.

Thus we face a dilemma.

On one side we are provided with convenience (Codable conformance) with the trade-off of making our model aware of framework-specific requirements. On the other side, we would like framework-agnostic models in the Feed Cache module. 

The first option takes little time to implement and requires a minimal amount of code. Its trade-off is the constraint the LocalFeedImage, a domain-specific type, will have to external implementation details (the CodableFeedStore requirements). Such a solution works great on the short-term, however, it creates implicit coupling with the framework implementation that may affect other components of the Feed Cache module, contributing to the rigidity of the system. Additionally, it sends a wrong message to other developers, signaling “it’s ok to add framework details in this part of the system” which is not true.

The second option requires us to write a bit more code, by creating a new private CodableFeedImage type that mirrors the LocalFeedImage model. The new type can conform to Codable instead of the LocalFeedImage and perform the mappings for transforming a LocalFeedImage to a CodableFeedImage and vice versa. The CodableFeedImage serves as a framework-specific model making the LocalFeedImage framework-agnostic again. Thus, removing the implicit coupling from the Feed Cache module towards the CodableFeedStore framework implementation.

There is no right or wrong option that can be applied universally. Such decisions must be filtered through your own needs and goals. This decision-making process is about understanding the current design of the system, the team preferences, the team size, culture and even future plans for the codebase. As always, while managing risk and trade-offs.

It may very well be worth going with a simple Codable conformance in the LocalFeedImage and revisit your choice later as shown in the diagram below.

## Dealing with side-effects and stateful components in tests
As you witnessed in the lecture video, choosing to test CodableFeedStore through its own APIs (instead of mocking its collaborators) can cause problems because of its stateful nature. CodableFeedStore uses the real file system as its storing mechanism, thus expect side-effects to take place.

In one instance, the side-effects of one test lead to the creation of an artifact in the file system which caused other tests to fail—even though the production implementation was correct.

## Setting up a clean disk state and undoing side-effects
To remedy the failing tests issues caused by the side-effects and state of writing to the disk we need to clear any artifacts generated in the file system every time we run a test. Removing any state at the tearDown method might seem reasonable and sufficient; however, tearDown is called only after the test finishes executing. Cleaning up state only in tearDown leaves open the possibility of problematic edge cases such as crashes and breakpoints that can prevent the test from completing and the tearDown from being invoked (leaving the artifacts in disk nonetheless). Such edge case can make your tests flaky and are extremely hard to debug and fix.

To prevent the test from such flaky edge cases, we also cleared the state in the setUp method which is called before each test execution.

## Moving from implicit hardcoded data (shared disk URL) to explicit URL injection
Leaving artifacts behind can affect multiple parts of the system including other tests. Relying on a shared disk URL will make tests fragile and prevent us from running them in parallel as other parts of the system (including other tests) might also generate artifacts on the same disk location.

By generating a unique location for the cache used in the tests we can associate the artifact on disk with a specific test file. In our case, we decided to name the store artifact as the test class name: CodableFeedStoreTests.store.

If you require a unique store file on disk every time you run the tests, you can append a random identifier token to the name of the store URL, for example. However, remember to wipe out the artifacts afterward, especially when working in large teams and running the tests on a server e.g., CI, as the data on disk can accumulate quickly resulting in massive storage overheads.

To go the extra mile and prevent such scenarios, we made sure to use the cachesDirectory which is a place for “discardable cache files” and the OS itself can clean up when necessary. (As opposed to the documentDirectory, which the developer is fully responsible for maintaining).

Finally, by moving from implicit shared URL to explicit URL injection, we have opened the doors to new possible use cases (reusability!) such as support for multiple accounts per device (every account can have their own namespace in disk), testing in isolation and in parallel (with test-specific URLs) and seamless store migrations (moving/replacing files without affecting the store implementation).

## Measuring the CodableFeedStore’s testing overhead
During the lecture, we mentioned that we have a tiny overhead by not mocking the file system in the CodableFeedStoreTests. 

We encourage you to measure your test suite performance over time. It should be automated, as part of your CI reports. Performance outliers should alert you to take action before they become a costly problem.

To measure our test suite times, we used the following xcodebuild command to clean, build and test the EssentialFeed project using the EssentialFeed scheme:

xcodebuild clean build test -project EssentialFeed/EssentialFeed.xcodeproj -scheme "EssentialFeed"

Although we might have been biased with prior experiences leading us to think that performing disk operations will introduce a massive overhead in our test times, upon thoroughly measuring the system’s performance it’s clear that we can comfortably withstand the added time. 

In spite of an 11.32% increase in test duration, the extra 0.018 seconds go by unnoticeable. Our development process speed was not affected. 

The fact that the changes made in this lecture left the development workflow unaffected doesn’t mean we should stop thinking about test suite performance and use I/O frameworks everywhere in our tests. 

I/O operations can be expensive, and as we continue developing the FeedStore’s implementations, we should closely monitor the test times to ensure smooth development operation and protect the sustainability of the system.

If the test times become a bottleneck, you can move disk I/O tests to a separate test target and make sure to add it in the CI scheme. The downside is that you may run this separate test target less often. Receiving the complete system feedback less often also delays failure reports, making the whole operation less efficient and more costly. 

For example, we’ve seen many teams relying on “overnight CI runs for slow tests.” 

The problem is: You don’t want to come to the office every morning to deal with CI failures that happened overnight and will take hours to fix and rerun. Instead, optimize the whole test suite to run in a few minutes (ideally seconds!) and even reside to mocking the frameworks if necessary. Then, you can run the whole suite of tests several times a day.

Finally, a slow suite of tests caused by disk I/O frameworks often means you’re relying too much on those frameworks. They probably perform complex business logic, which forced you to write many tests that interact with the disk. If that’s the case, move that business logic into side-effect free functions that are easy to test, fast, and reliable. Then, your framework implementations will be so simple they will require just a few tests to guarantee they behave correctly. So few tests, that we can live with their tiny overhead.

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
