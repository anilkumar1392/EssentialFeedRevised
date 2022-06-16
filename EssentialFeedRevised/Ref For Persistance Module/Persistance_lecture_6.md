
#### Performing Calendrical Calculations Correctly, Dealing With Coincidental Duplication While Respecting the DRY Principle, Decoupling Tests From Implementation With Tiny DSLs, and Test Triangulation to Increase Coverage & Confidence

In this lecture, we deal with calendrical calculations, coincidental duplication, and triangulating data points while test-driving the Load Feed From Cache use case implementation.

Learning Outcomes
Identifying coincidental duplication while respecting the DRY (Don't Repeat Yourself) principle.
Performing calendrical calculations correctly.
Creating a simple DSL (Domain Specific Language) to decouple tests from implementation details.
Increasing test coverage and reducing the probability of error by triangulating data points.
Duplicating code in different contexts
Don't Repeat Yourself (DRY) is a good principle, but not every code that looks alike is duplicate. Before deleting duplication, investigate if it's just a coincidental duplication: code that seems the same but conceptually represents something else. Mixing different concepts makes it harder to reason about separate parts of the system in isolation, increasing its complexity.

For example, although we decided to keep the "Save" and "Load" methods in the same type LocalFeedLoader, they belong to different contexts/Use Cases. One test for the “Save” and “Load” use cases may look "duplicate," but it's a "coincidental duplication" since they represent different actions.

If we ever decide to break those actions in separate types, it's much easier to do when the tests are already separated and with all the necessary assertions.

Calendrical calculations
When performing date calculation make sure to use system tools that can account for edge cases and scenarios that can be easily missed by developers.

In our case, we had to calculate a date of seven days in the past from the current date. One way to approach such calculation is to manually construct a seven days interval (60 seconds x 60 minutes x 24 hours x 7 days) and then subtract it from a current date. Although such an approach can be deemed reasonable for cache validation, it may not be enough for use cases that require precision as it doesn’t account for edge cases where days don’t have exactly 24 hours (e.g., daylight saving times). Naive calendrical calculations can really damage the customer experience and even introduce critical bugs that can cost trust and money to both the customer and business (e.g., a customer may miss an event date or flight date). Such date bugs are very hard to find and debug, so it’s essential to prevent them proactively.

Furthermore, relying on naive date logic makes your tests fragile, as they can fail unexpectedly on specific dates and locales. For example, it’s typical for continuous integration and continuous delivery workflows to run on third-party servers around the world, in different locales/time-zones from where the codebase is been developed. Also, many dev teams work remotely from different locales/time zones. So, ideally, tests should be locale/timezone agnostic, unless you’re testing timezone or locale-specific logic.

To avoid such problematic and unwelcome scenarios, we rely on Apple’s Calendar API for performing calendrical calculations. Depending on your specific needs, you can also set a specific TimeZone and Locale to the Calendar instance.

Finally, to make our intent explicit and facilitate the calendrical calculations in the tests, we extended the Date type with two helper methods: adding(days: Int) and adding(seconds: TimeInterval). By doing so, once again we have made our tests more readable while decoupling them from implementation details (calendar logic, in this case).

Those helper methods represent a test-specific DSL (Domain Specific Language) making the tests more flexible as we are free to reuse/change/replace the logic within the Date extension without breaking the tests.

Triangulating data points and deciding which values to test
To protect the codebase from possible (present and future) defects, we take proactive steps to decrease the risk (uncertainty for the outcome) as much as we can. Triangulating specific data points helps us de-risk and increase the test coverage of the system. For example, the use case dictated that a valid cache must be less than seven days old. At a minimum, we should test the seven days and less than seven days old data points (equal and less than), plus the more than seven days old case (completing the triangulation).

We can improve our process of testing “hidden” behaviors simply by triangulating examples around a specific data point. By finding and covering all hard limits, such as the mean and adjacent values, we decrease the chance of accidentally introducing a bug in the system.

As high-performance developers, we’re also risk managers, so it’s our responsibility to help the business folks uncover hidden scenarios or edge cases that were never explicitly defined in the provided requirements. Such proactive actions will improve your outcomes and increase your rewards, influence, and trust within the company.
