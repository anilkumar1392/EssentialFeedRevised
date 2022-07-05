 ## MVVM: Reducing Boilerplate, Shifting Reusable Presentation Logic from Controllers into Cross-Platform (Stateful & Stateless) ViewModels, and Decoupling Presentation from UI Frameworks with Swift Generics
 
 1.  Can help us create platform agnostic presentation layer by separating UIKIt ViewControllers from Core model.
 
 Cause: UIviewcontroller depneds on model beacuse of which their is lot of state management.
 2. All that state management inflates the number of responsibilities.
 
 Another problem is 
 2. If we need to deploy our code to another platform such as watch OS we wil hav to preety much duplicate or copy-paste from UIKIt controller in to watch kit controllers.
 
 ## So ideally we should move reusbale logic to platform agnostic type.
 
 thats where MVVM come in.
 
 1. MVVM is very much similar to mvc with a diff is that a viewModel does not hold a ref to the view as the controller does.
 
 2. TO make both sides reusbale the view and the viewModel should not depend on each other.
 3. Their communication should be indirect some kind of binding.
 
 as iOS platform does not have any automatic binding so the boiler palte code for binding will still be their.
 but the idea of viewModels are still an interesting one to as they can help us create better architectual separation.

## It's recommended that ViewModel to be platform and framework agnostic.
so you can reuse them in multiuple platforms.

## So now the Goal is to decouple the ViewControllers from the EssentailFeed Core components.

1. So we need to move EssentialFeed core Components to a ViewMOdel
2. All state management will move to viewMOdel.

## Creating ViewModel

their are 2 common ways.
1. Statefull
2. Stateless

Target action enforces the target instacne to be NSObject.
so we would have to make FeedViewMOdel confirm to NSObject.
but confroming to NSObject is a UIKIt requirement.
but remember viewModel should be platform agnostic.

Making ViewMOdel confirm to NSObject just to satisfy UIKIt requirment is a leaky implementation.

Thats why we kept target action relationship with the controller.

## KEY points
1. ViewModel should be platform agnostic.
2. Move all the state management to viewModel means controller should be free from models

FeedRefershViewController is creating FeedViewModel and as we recommend objects should not create their own dependencies.


// For now communication is like
FeedViewModel -> FeedRefershViewController -> FeedController

// we can make it.
FeedViewModel -> FeedController

by moving onRefresh to ViewModel as FeedRefershViewController is just forwarding the data.

## Now FeedRefershViewController does not holds any state it just binds the view with viewModel.
All the state management now leaves in viewModel the platform agnostic the reusable component.

Now we have stateFull ViewMOdel ready with us.

But it does not need to have states instead of holding state we could only have transient state.
Instead of holding state we could have a specifc closure observer for each state change.

So insetad of isLoading we could have onLoadingStateChange closure.

## FeedImageCellController 

we moved the state management to the 'FeedImageViewModel' so FeedImageCellController now acts as a binder between 'View' and 'ViewModel'.
SO the cell controller create and binds the cell with the viewModel.

## So properties that can change have their on closure observer.

Transformation from data to UIImage happeing in viewModel however this data to UIImage transformation creates a strign dependency with UIKIt.

SO our viewModel is coupled with UIKIt and can not be used with cross platforms that dopnt support UIKIt.
## View model has strign dependency with UIIMage (UIKIt)
This way we can't use viewMOdel in a watchOS applciation.

## It's common to see viewMOdel with UIKIt components or platform specifc components.
but it does not have to.

to make ViewModel agnostic of UIKit we need to remove references from UIKIt.

## To do so we can use generics.
class FeedImageViewModel<Image> {

} 

and use dependency injection to pass transformation closure.

private let imageTransformer: (Data) -> Image?

so the transforer method will be injected in viewModel.

## now 'FeedImageViewMOdel' does not depend on UIKIt any more.

1. FeedViewController does not need to manage any state so it does not need viewMOdel.
2. FeedRefreshController and 'FeedImageCellController' bith require model state thus they have their own view model.

## In this lecture, you’ll learn how MVVM can help you reduce boilerplate code and create a reusable cross-platform Presentation layer.

## Learning Outcomes

Improving architectural separation between UI and core components with View Models
Creating a reusable cross-platform Presentation layer with MVVM
Implementing Stateful and Stateless View Models
Using Generics to create reusable components

## Introduction to MVVM (Model-View-ViewModel)
MVVM is a UI architectural pattern, and it stands for Model-View-ViewModel. MVVM is an MVC variant created by Microsoft aiming to eliminate the boilerplate of syncing View events and Model updates that Controllers hold in an MVC implementation.

Microsoft’s MVVM solution binds View events with Model updates automatically, with the help of a ViewModel component in between.

MVVM was incorporated in Microsoft’s .NET graphics system, where developers define the ViewModel bindings along with the View declarations in XAML, and the framework performs the runtime bindings automatically.

Outside the Microsoft platforms, MVVM is also known as Model-View-Binder, since most platforms don’t offer the automatic wiring as the .NET graphics system does.

For example, in UIKit, there’s no automatic way of binding a ViewModel with a View, so it’s up to the developer to implement the Binder components.

To facilitate the bindings between the View and the ViewModel, it’s common for iOS teams to use frameworks like RxSwift or Combine.
