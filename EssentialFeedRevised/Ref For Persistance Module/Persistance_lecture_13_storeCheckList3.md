
## Designing and Testing Thread-safe Components with DispatchQueue, Serial vs. Concurrent Queues, Thread-safe Value Types, and Avoiding Race Conditions

// Least side effect you have the more concurrent your app can be.
side effects are eneny of concurrency.


We have bounary such as FeedStore for lcoal DB and HTTPClient for network layer.

## Learning Outcomes
Designing and testing thread-safe components with DispatchQueue
Differences between serial and concurrent dispatch queues
Avoiding threading race conditions (e.g., data corruption/crashes)
Thread-safe(r) value types
Measuring test time overheads


##Thread-safe(r) Value Types
Reference types in Swift (e.g., class) share a single copy of the instance data.

When sharing mutable data (references), threading becomes a real challenge. For example, if two threads try to mutate the same instance data at the same time, all types of race conditions can occur (data corruption, crashes…).

Value Types in Swift (struct, enum or tuples) are initialized, assigned and passed as arguments as independent instances with their own unique copy of the instance data.

Since Pure Value Types* (types formed of only value types) are passed around as unique copies, they don’t share mutable state.

In turn, Pure Value Types are thread safe since multiple threads will hold and operate on their own unique copy of the data!

##Managing and documenting thread dispatch
When developing for multithreaded platforms such as iOS and macOS, we need to consider and evaluate how thread dispatching affects the composition, correctness, and ease of use of the system.

As a rule of thumb, we prefer to let the clients of our APIs decide to dispatch to appropriate threads if needed. We do so since we can’t predict the client’s needs. Some clients may want to update the UI (thus, dispatch to the main thread), while others may have to carry on mapping and to combine the data with other operations (thus, benefitting from background threads).

Another possible solution is to allow the clients to provide the desired dispatch queue for the completion callbacks (via dependency injection, for example).

Regardless of the technique you choose, it’s always a good idea to provide documentation to the clients of your APIs to help them use the APIs correctly (as you intended them to).

✅ Retrieve
    ✅ Empty cache returns empty
    ✅ Empty cache twice returns empty (no side-effects)
    ✅ Non-empty cache returns data
    ✅ Non-empty cache twice returns same data (no side-effects)
    ✅ Error returns error (if applicable, e.g., invalid data)
    ✅ Error twice returns same error (if applicable, e.g., invalid data)
✅ Insert
    ✅ To empty cache stores data
    ✅ To non-empty cache overrides previous data with new data
    ✅ Error (if applicable, e.g., no write permission)
✅ Delete
    ✅ Empty cache does nothing (cache stays empty and does not fail)
    ✅ Non-empty cache leaves cache empty
    ✅ Error (if applicable, e.g., no delete permission)
✅ Side-effects must run serially to avoid race-conditions
