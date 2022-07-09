## Test-driven Approach to Effectively Dealing with Legacy Code (Code With No Tests!) + Extracting Cross-platform Components From a Platform-specific Module


### “Legacy code is code without tests.”—Working Effectively with Legacy Code by Michael Feathers

So far we have been testing the UI and the presentation module in integration.
So the presenter types are not even public we don't test them directly.
But through the integration with the UI.
Our test don't even know that FeedPresenter exists.
Because they dont have access to internal types.


But The feedPresenter is not iOS Specific it does not depend on iOS or any other platform.
it can be reused across platforms.
It can be used for macOS, watchOS, iPadOS and etc.

So essentially we should move it away from iOS module and into a more cross platform module.
Which at this point can be the 'EssentialFeed'

So if we are moving FeedPresenter to Cross-Platform module, it can be shared among other module so it is better to Test it in isolation.
SO if their is a problem with the 'FeedPresenter' implementation we know exactly where the problem is.

/*
 What does feed presenter do it receives events
 and translate those events in to presentable viewData or viewModels.
 So it's a translation layer it sends message to the view.
 
 View is the collaborator but now we need the action the initializer.

 */

// So if we create a feed Presenter with that view the view should not receive any messages.
/*
 We recommend you to start from the degenerate simple and trival behaviour first.
*/

/*
 Just to capture the received value we can create an enum.
 */

/*
 First behaviour tested but now their are two things happening so now add second behaviour in to it.
 */

/*
 we have no temporal coupling the order does not matter
 So chaning order should not break the tests.
 */

/*
 Moving code from one module to another is an delicate process we need to do it step by step.
 fi you don't have test for your code usign this TDD approach to existing code it's going to help you mistakes.
 */

/*
 Now we have isolated tests in cross paltform module
 and integration test in the iOS module.
 */
 
 ## Learning Outcomes
Extracting cross-platform components from a platform-specific module
Test-driven approach to testing components that have been implemented already (test-after)

## Extracting the cross-platform Feed Presentation

So far, we’ve implemented and tested the Feed UI and Presentation modules in integration within the same iOS target.

However, since the Presentation module is platform-agnostic, it can be reused in other platforms such as macOS, watchOS, iPadOS, etc. So, ideally, we should move the Feed Presentation components to a cross-platform target.

In our case, we can move the Presentation components the EssentialFeed cross-platform target for now (in the future it can have its own dedicated framework/package).

To move the Presentation components to the EssentialFeed target, we’ll have to expose some internal Presentation types publicly so that they can be accessed by the iOS UI, macOS UI, and other client modules.

But… we have zero unit/isolated tests for the internal types as they are 100% tested in integration with the iOS UI module.

TIP: Private and Internal types are preferably tested in integration through public APIs.

Testing internal types in integration is fine when used in one integration context only. However, when exposing types publicly, it’s advised to add unit/isolated tests for them instead of relying solely on integration tests.

That’s because public types can be used in distinct integration contexts, such as an iOS UI and a macOS UI in the Presentation case, and Integration Tests are often not very precise.

When an integration test fails, it’s hard to know why and where’s the problem (it can be in any component of the integration!).

The more you test types only in integration, the harder it gets to quickly and precisely find and prevent mistakes.

And, as always, we want our tests to be as fast and precise as possible when there’s a failure. That’s where adding unit/isolated tests shine. If a change breaks the Presentation types, the unit/isolated tests will flag the exact place.

In this project, we have the Integration Tests to help us prevent mistakes while moving the Presentation components across targets.

However, when dealing with legacy code, you may not have any tests at all. In that case, we recommend you to add tests before performing the refactoring. So, you can guarantee the system behaves the same after the refactoring.

The good news is: Adding unit/isolated tests for existing components can also be done by following a quick and safe test-driven approach, as shown in this lecture.

## TIP: Private and Internal types are preferably tested in integration through public APIs.


## The cost and risks of writing tests after

## We highly suggest you follow a test-driven approach instead of adding tests after the feature is done (test-after).

Adding tests after the creation of components can lead to a slow and fragile QA process, causing you to potentially miss edge cases and states the system can find itself in.

Furthermore, testing after can be more costly as it increases the development time.

For example, to implement and validate a solution without tests, you’ll need to run the app and use the debugger more regularly. Both these two processes can be extremely slower and more costly compared to running blazing-fast unit-tests (test-first) to verify if your solution is valid or not.

Additionally to the increased debugging time and manually running/testing the feature, you’ll have to account for the time to write the tests after. When adding tests after, you often need to make big changes to the design to enable testing, making the whole process even slower.

Because of the tremendous slow down of writing the tests after, the team may decide that writing automated tests is optional. The reasoning usually being “I know the code works (I’ve debugged and tested it manually), thus I don’t need tests.”

So, adding tests becomes secondary or non-existent, leading to regressions and an increase in development and maintenance time/cost as more features are being added to the codebase.
/*
“Code without tests is bad code. It doesn’t matter how well written it is; it doesn’t matter how pretty or object-oriented or well-encapsulated it is.

With tests, we can change the behavior of our code quickly and verifiably.

Without them, we really don’t know if our code is getting better or worse.”—Working Effectively with Legacy Code by Michael Feathers
*/

##  Identifying test after code in a project

Indicators: Test lines of code per production lines of code over time
“To assess the level of consistency in writing tests along with the production code, we can plot the ratio of each commit in a graph and let the graph lines tell the story, regardless of whether the tests were written first or last. Developers who do not practise TDD tend to write the production code first and come back to it, usually in the later days of a sprint, and only then add any missing tests.

The test lines of code per production lines of code metrics should indicate how important automated testing is for the team and what the preferred way is of performing it (first or last). If the test lines of code index is flat or with small spikes when compared to the production lines of code index, you know the codebase is not built with testing and an automated QA strategy in mind, which can be costly for the business as you move forward.” – Part Three: The Codebase, The Lead Developer Essentials

In a test-after curve, the green line (tests) remains flat, and the blue line (code) is trending upwards until the vertical orange marker meaning code is written first, without tests. The dashed orange line marks the time where the code implementation ended (flat blue line), and at the same time, the test lines of code (green line) begin to ascend.

Using the “Test lines of code per production lines of code over time” indicator is a great diagnostic tool to assess parts or periods where the codebase was developed with a test-after approach. For instance, it can help you identify parts of the codebase where the team had a hard time writing tests first, so you can help them enhance the design to facilitate testing and sharpen their TDD skills. As a result, you should see improvements in the development and delivery process.
