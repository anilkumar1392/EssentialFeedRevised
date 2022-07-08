
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


# we are not testing the volatile translations
we are testing that all localized keys have a corresponding value in all suported localizations.


# Recap

1. Static and lcoalized belong to the presentaiton module or view model.
2. The UI Module is passive it does not make presentation decision.
3. The UI module just renders data passed to it.
4. which makes it much easier to develop, maintain extend and test reuse and even replace.


## Localizing strings within various UI design patterns

Have you noticed that we haven’t added any customer-facing strings (e.g., localized titles and friendly error messages) to the production code so far? That’s no accident.

In Apple’s platform, there is a built-in way to localize string content: Localized Strings.

You can access your Localized Strings via the Foundation Bundle APIs or NSLocalizedString function.

But creating and managing customer-facing strings from many parts in your project can induce tight-coupling.

For instance, the same Business Logic can be presented using different content, styles, languages, etc.

So managing customer-facing strings is a Presentation concern. And we highly recommend you to separate Presentation from Business Logic by managing your static and localized content in the Presentation module.

For example, in MVP, the localized strings should ideally be created by Presenters and passed to the UI via ViewModels.

In MVVM, the localized strings should be created by the ViewModel.

In MVC, you should expect to see the localized strings created by components responsible for Presentation logic. That’s often the Controller or the View.

Localized strings should only exist in MVC Models if the Model represents a ViewModel. If you’re localizing strings in Business Models, move it to another component, keeping the Business Models agnostic of any Presentation logic.

Moreover, localized content can be reused across applications if you create a cross-platform Presentation module. When extra customization is needed, you can inject localized data from the Composition Root where the Presenter and UI components are instantiated.


## Best practices for testing localized strings

Your apps are probably localized in many languages. When testing localized strings, avoid asserting specific localized values in the tests, such as:

XCTAssertEqual(title, “My Feed”)
XCTAssertEqual(confirmationMessage, “Do you want to continue?”)

That’s because you should avoid coupling your tests with a specific translation or any other locale-specific detail such as timezones and number/date formatting rules.

Often, translations come from different teams, and they change a lot (for various reasons!). So translations are incredibly volatile.

You should strive to avoid volatile (fragile) tests. Instead, you can test-drive the implementation by asserting you’re using the correct key, not the specific localized value.

So the localized string values can safely change without breaking the tests. Additionally, you can also safely run the tests in any localization.

Another benefit is of testing only the keys is that you facilitate the work of distributed teams. For example, you can safely run your tests in Brazil, Germany, Greece, and any other locale.

Furthermore, you should also add fast and reliable automated tests to guarantee your app releases contain localized strings for all keys in all languages.

Finally, if you need to test the actual localized values with your localization team, there are better ways, such as snapshot/screenshot tests.

## Best practices for naming localized keys

Bundle.localizedString(forKey:) and NSLocalizedString attempt to find the localized value of a given key at runtime.

## Best practices for naming localized keys
Bundle.localizedString(forKey:) and NSLocalizedString attempt to find the localized value of a given key at runtime.

One caveat of the function is that it always returns a non-optional String value, even when it cannot find a value for the given key. That means that if NSLocalizedString can’t locate a localized value for the given key, it will then return the given key (unless you give it a default value).

We suggest you avoid using the key as a default value for the localized string as it will make your strings management a lot harder and can result in bad customer experience.

Instead, every localized string should have its own key and an excellent comment per specific context, even if it seems identical to a localized string in another context.

The main reason being: every language has specific rules, so seemingly identical contexts may vary per translation.

For example, canceling an operation is a common action a customer can take. However, the translations may vary depending on the context.

Canceling a transaction or canceling an upload should have two distinct keys “CANCEL_TRANSACTION_ACTION” and “CANCEL_UPLOAD_ACTION” respectively.

That’s because the word used for “canceling” a transaction or an upload might differ in some languages.

In English, the word “Cancel” might apply in both contexts, but it might very well be different in Portuguese, Greek, or other supported localizations, leading to confusing customer experience.

The words used often depend on the confirmation message, which should also have separate localized string keys. Something like “CANCEL_TRANSACTION_MESSAGE” and “CANCEL_UPLOAD_MESSAGE”.

The more you separate keys, the more options the translators will have to deliver precise directions to the customers.

## References
Bundle.localizedString(forKey:value:table:) https://developer.apple.com/documentation/foundation/bundle/1417694-localizedstring
NSLocalizedString reference https://developer.apple.com/documentation/foundation/1418095-nslocalizedstring
Creating Great Localized Experiences with Xcode 11, WWDC 2019, Session 403 - https://developer.apple.com/videos/play/wwdc2019/403/
Creating Apps for a Global Audience, WWDC 2018, Session 201 https://developer.apple.com/videos/play/wwdc2018/201
New Localization Workflows in Xcode 10, WWDC 2018, Session 404 https://developer.apple.com/videos/play/wwdc2018/404/
String Resources https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html
About Internationalization and Localization https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/Introduction/Introduction.html#//apple_ref/doc/uid/10000171i
Managing Strings Files Yourself https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/MaintaingYourOwnStringsFiles/MaintaingYourOwnStringsFiles.html
