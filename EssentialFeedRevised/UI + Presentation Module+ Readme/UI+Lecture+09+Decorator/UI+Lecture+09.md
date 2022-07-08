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

## So Decorator pattern is a fantasic way of adding a behaviour with out alerting the while class.

So thats the key for decoupled module.
if you want to decouple your module from each other.
 A change in UI requirment should not require change in a database or a network module.
 
 ## if you find your self creating so many decorator you can create a generic one.
 ## Generic implementation.
 
 final class MainQueueDispatchDecorator<T> {
    let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
}
// and we can move the conformance to a extension

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
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

## Updated one
 
final class MainQueueDispatchDecorator<T> {
    let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        if Thread.isMainThread {
            completion()
        } else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
// and we can move the conformance to a extension

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void) {
        decoratee.load { result in
            self.dispatch { completion(result) }
        }
    }
}

## Now you have a reusable MainQueueDispatch decorater

Do the same in FeedImageDataLoader 
and see no change in any class aonly change in composition.

## Learning Outcomes

Decoupling UIKit components (and any other client) from threading details
Removing duplication and centralizing threading logic in the composition layer
Decorator pattern: Extending behavior of individual objects without changing its implementation (Liskov Substitution + Open/Closed Principles)
Decorator pattern: Implementing Cross-Cutting concerns (Single Responsibility Principle)

## Hiding threading details from clients

Threading is an implementation detail. And, as always, we want to hide concrete implementation details from client components.

# Hide concrete detials from client components

For example, the <FeedLoader> protocol hides implementation details of how the feed is actually loaded from its clients. The feed can be loaded from disk, from an in-memory cache, from a backend server, etc.

The UI and Presentation modules, for instance, use the <FeedLoader> protocol. So the UI and Presentation modules are clients of the protocol, and they shouldn’t be aware of the concrete protocol implementations or the feed’s provenance.

However, some <FeedLoader> implementations may perform work in background threads. And the UIKit UI module requires its components to be used in the main thread.

## Important: Use UIKit classes only from your app’s main thread or main dispatch queue, unless otherwise indicated. This restriction particularly applies to classes derived from UIResponder or that involve manipulating your app’s user interface in any way.

### If the UI or Presentation components dispatch the result callback to the main thread, then we would be leaking details of how the protocol was implemented, implying that the <FeedLoader>’s completion was invoked in background threads.

In other words, we would be leaking threading details of the <FeedLoader> implementations into distinct modules.

### But the reason we create abstractions such as protocols is to hide concrete details from their clients. If you hide implementation details from clients, you can easily make changes to the code in isolation, without affecting multiple parts of the system.

To achieve such desired separation, even threading details should be hidden from the clients.

Moreover, when a component is aware of threading details, it’s common to see a lot of duplicate code forming and defensively dispatching work to the specific queues.

To hide concrete implementation details, you can move dispatch queues and threading to the Composer layer by using Decorators.

Decorating the behavior of specific objects, based on your clients’ needs, should make your components lighter, reduce duplication, and contribute to their open/closed nature.

## The Decorator pattern

The Decorator pattern offers a way of adding behavior to an individual object and extending its functionality without subclassing or changing the object’s class.

Decorators are useful when you want to add or alter the behavior of individual objects instead of an entire class of objects. For example, we only want the instance of <FeedLoader> that will be used in the UI to complete in the Main queue, instead of the <FeedLoader> instances.

To implement the Decorator pattern, you create a new object (decorator) that encloses and conforms to the interface of the component (decoratee) it decorates. The decorator class will contain the extended behavior and forward messages to the decoratee.

By doing so, the decorator can be used by the clients of the interface, extending the behavior of the system without needing to alter any existing components.

The Decorator pattern is supported by the SOLID principles, especially the Single Responsibility, Liskov Substitution, and Open/Closed Principles.

You can use Decorators to add Cross-Cutting concerns such as Logging, Analytics, Threading, Security, etc. into your modules in a clean way while maintaining low coupling in your applications.

## References
Design Patterns: Decorator https://www.goodreads.com/book/show/85009.Design_Patterns
Diagnosing Memory, Thread, and Crash Issues Early https://developer.apple.com/documentation/xcode/diagnosing-memory-thread-and-crash-issues-early
Thread reference https://developer.apple.com/documentation/foundation/thread
DispatchQueue reference https://developer.apple.com/documentation/dispatch/dispatchqueue
UIKit reference https://developer.apple.com/documentation/uikit
