## Deleting Models and Handling Errors with Codable+FileSystem, Making Async Code Look Sync in Tests to Eliminate Arrow Anti-Pattern, and More Essential Test Guidelines to Improve Code Quality and Team Communication

##Learning Outcomes
Turning async code into sync for expressiveness and readability in tests
Eliminating hard-to-read nested code (arrow-shaped code)
Monitoring the impact of refactoring with quantitative analysis
Improving test code by providing better names & making dependencies explicit


## Turning asynchronous code into synchronous
In this lecture, we decided to make asynchronous code look synchronous from the test code point of view to simplify the tests setup and improve readability.

Such a process entails the transformation of a function signature with a completion closure such as:

func asyncFunction(completion: @escaping (ReturnType) -> Void)

to a function signature without a completion closure:

func syncFunction() -> ReturnType

By hiding the async code behind the sync function helper, the async completion will be handled in the helper method instead, which will leave the client interacting only with synchronous behavior.

By altering the test implementation to interact with synchronous APIs instead of asynchronous, we end up with the following advantages:

The tests are much more readable
The tests are easier to write, maintain and extend
The tests are more flexible (allowing production changes without altering tests) as they are more decoupled from implementations details
The sync APIs insert and delete ended up returning the optional error value for the respective operation to make any required test assertions more visible and expressive.

The synchronous helper methods led to a more straightforward and more idiomatic code which is a much more valuable trait for the tests to have at the moment.

Finally, another benefit from using synchronous APIs in the tests is the elimination of chained async code with completion closures that formed the infamous arrow-shape code, which is hard to read and follow.

## Dealing with deep indentation levels a.k.a. “arrow code”
“Indentations represent a nested structure in an implementation. Some examples are nested conditional statements, flow of control statements and closures. Such behavior can result in the infamous ”arrow”-shaped code, where each line is indented by tabs or spaces and would have to end each nested statement with a curly brace, resulting in the code forming an arrow-like shape (also known as ”The Pyramid of Doom.”)

Each nested statement increases the complexity of the system, which can result in more state management and a lot more difficulty in testing, or—even worse—making certain behaviors untestable.

When dealing with these components, we have observed that developers understand the problem of the arrow shape formation in their code, which makes them extract such statements in new methods in the same component. This option solves the arrow issue; however, it also increases the component's lines of code as well as hiding a logical flow of data, especially if the code isn't organized properly within the file. It would be much better to extract arrow code paths in new components where they can be tested and then composed as a whole with the previous ones. Unfortunately, this can be impossible in messy codebases because of all the dependencies involved.

Arrow-shaped code usually results in maintainability issues so we suggest you examine it carefully, as it can lead to fragile and immobile code.”–The Lead Developer Essentials, Part 3: The Codebase
In this lecture, we faced a case of messy arrow-code and proactively decided to improve it. The following chart reports the values of the lines of code included in the CodableFeedStoreTests and the level of indentation (count of tabs, where 1 tab is equal to 4 spaces) existing in each test over the refactoring process.

The test values #1, #2, #3, #4 correspond to the CodableFeedStoreTests tests included in the refactoring process:

test #1: test_retrieve_deliversEmptyOnEmptyCache

test #2: test_retrieve_hasNoSideEffectsOnEmptyCache

test #3: test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues

test #4: test_retrieve_hasNoSideEffectsOnNonEmptyCache

By identifying the arrow-shaped code in the tests and allocating a few minutes to refactor the code, we significantly improved the CodableFeedStoreTests. Such a process should be considered an investment for software developers—do it often!

Even if you can’t see the immediate positive returns of such refactoring, keeping the production and test code tidy will always improve communication and pass a positive message to developers who interact with the code. Messy code is likely to push developers to be messy (“It’s already bad code... so I guess it’s fine just to add more to the mess”). Tidy code is likely to push developers to be tidy (“That’s some great code right here. Let’s keep it like this.”).

The gains from continuously refactoring your code will contribute to quality, maintainability, reusability, establishing a constant fast pace, minimal regressions/defects, frictionless merges into master, regular deployment cycles, improving the estimation accuracy, and overall long-term sustainability of your team operations.

## Good communication practice: Making dependencies explicit

Ideally, we want to avoid implicit details in tests. Tests should be short, but every important detail to a test should be clearly defined within the test method. By doing so, when there’s a test failure, we can easily understand the test set up by looking at its short scope (without having to debug or go through many levels of abstractions).

When following the Given/When/Then test structure, as a rule of thumb, every value used in the When and Then portions should be defined in the Given portion.

In this lecture, we improved a test which was properly structured (Given/When/Then), but hid essential and meaningful information about an implicit relationship with a value used in the When portion:

To make the test setup easier to follow/understand, we make all important details explicit by extracting the URL value produced by the testSpecificStoreURL() to a local constant and explicitly inject it as a dependency to the system under test creation (Given part), and then proceed to use it in the When part.

As the arrow points in the picture below there is a clear downwards direction for the use of the storeURL, first declared and explicitly used in the given block and then used explicitly in the when block.

Code is a way for developers to realize their business's vision. Although this is true, it's a very static view of how members of an organization should perceive code. At the end of the day, what's good about a codebase that has implemented the firm's vision but can't sustain future changes and additions? In our experience, many developers tend to not understand the imperative principle of code being a communication tool as well. If employees believe in the firm's vision, they should work towards building it right now while guaranteeing its sustainable nature for future extension.

Developers must write code in a way that clearly states what their intentions were at the time of writing it. They do this by following a set of guidelines and principles that will allow the next assigned person on the same piece of code to continue the development with ease. By doing so, developers can guarantee they won't be confusing their teammates as well as their future self (who might very well be the confused next person assigned to work on that part of the codebase).”–The Lead Developer Essentials, Part 2: The Team

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
