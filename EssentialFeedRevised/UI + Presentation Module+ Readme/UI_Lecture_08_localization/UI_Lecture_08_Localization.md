
##   Creating, Localizing, and Testing Customer Facing Strings in the Presentation Layer + NSLocalizedString Best Practices

In this lecture, you’ll learn how to manage and test static and localized strings within a clean architecture.

Learning Outcomes
Localizing strings within various UI design patterns (MVC, MVVM, MVP)
NSLocalizedString best practices
Creating and managing customer-facing strings in the Presentation Layer (away from Business Logic!)
Testing customer-facing strings


String values like title belong to Presentation layer.
Created by contoller or directly by the views.

In MVVM presentaiton strings should be created by ViewModel.
In MVP presentation strings should be created by Presenters.

for us now move string creation to presenter.

Since our title does not change a static property will do just fine other ways we can pass title in model.

## Move title configuration from 'FeedViewController' to 'FeedUIComposer'  - the view controllers can be agnostic of presenters if we move the configuration to composer's 
