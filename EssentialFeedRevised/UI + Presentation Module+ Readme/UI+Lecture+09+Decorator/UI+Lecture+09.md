##   Decorator Pattern: Decoupling UIKit Components From Threading Details, Removing Duplication, and Implementing Cross-Cutting Concerns In a Clean & SOLID Way

## UIKIt is not thread safe.

Most UIKit Components must be called from main thread.


So this check for main thread will be every where and we need to check and dispatch over and over and again.

That's a sign that this logic should be some where else.

Run the test and test fail. 
as we are using main Thread cheack closure but no weakifying it.

## It's not a memory leak but we are jsut holding the instacne longer than needed.

One solutiont to check for main thread is move threading one level up.
So in this case one level up will be the presentation level.

So problem with presenter.
1. Presenter is platform agnostic component.
2. And dispatcing to the mainthread is a implementation detail because of UIKit.
3. We are leaking this detail into the presenter.
2. Same duplication of code.

So to solve this what if we move dispatching one level up.
To composer.

## So to bridge the threading gap with a new type.
A type that gurarntees that FeedLoader always dispatches work to the main Queue.

## And that's whrer Deocrator come in.

Decorator pattern is used to add behaviour to a instance while keeping the same interface.

final class MainQueueDispatchDecorator: FeedLoader {
    let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (LoadFeedResult) -> Void) {
        decoratee.load { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}

## This way we end writing Main thread logic at one centralized place.

So decorator is adding behaviour to an instacne without changing the instance.

## That's the open close principle.
We are adding behaviour without changing code.

So the presenter does not know about threading.
The UI does not know about threading.
And the FeedLoader implementation does not konw that the UI Kit implemntations require work to be dispatched to main queue.
We still keep our implementations decoupled without leaking the concrete types.

ths composer layer is responsible for arranging and composing the components.

