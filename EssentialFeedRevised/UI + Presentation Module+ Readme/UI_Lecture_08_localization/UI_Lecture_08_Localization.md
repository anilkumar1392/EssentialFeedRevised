
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

## Localized string files.

It is preety much like a dict contains key and value.
1. they are bundled into your app.
2. So you can load localized strings by key at runtime.
3. So to access bundled localized strings you can use the bundle types.


        let bundle = Bundle(for: FeedViewController.self)
        let localizedTitle = bundle.localizedString(forKey: "My Feed", value: nil, table: nil)
        
        if value not find it return the key.
        "My Feed"
        
        Test still passing.
        
        you can also use
## We can also use NSLocalizedString 
which uses the bundle api behind the scenes.

Using the key as default value is bad practice.
we recomend you to distinquish between key and natural transactions.
A key should not be the default value.

so replace 'My Feed' key with 'FEED_VIEW_TITLE' 

if you want to have a default value just pass a string value in value param.

Table: Is the name of localized string file where you want to locate the key value pair.
if you pass nil it will look for the default localized table.

## Translations are volatile because they change a lot.

and we don't want volatile and fragile tests.
so we are setting the value for right key not the localized value.

## So FeedViewController tests are actually intergration tests.

It test whole composition of Feed UI and the presentation.
