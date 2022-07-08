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


