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

