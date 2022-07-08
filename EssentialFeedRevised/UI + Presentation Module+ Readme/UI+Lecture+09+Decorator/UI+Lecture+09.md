##   Decorator Pattern: Decoupling UIKit Components From Threading Details, Removing Duplication, and Implementing Cross-Cutting Concerns In a Clean & SOLID Way

## UIKIt is not thread safe.

Most UIKit Components must be called from main thread.


So this check for main thread will be every where and we need to check and dispatch over and over and again.

That's a sign that this logic should be some where else.

Run the test and test fail. 
as we are using main Thread cheack closure but no weakifying it.

## It's not a memory leak but we are jsut holding the instacne longer than needed.

