## Finishing the Cache Implementation with Business Logic + Core Data Integration Tests—Unit vs. Integration: Pros/Cons, Performance, Complexity & How to Achieve The ideal Testing Pyramid Distribution

1. How to create and separate integration test from Unit(Isolated) tests.

Goal: To keep isolated test as fast as possible.

Unit Test: are the primary feedback mechanism.
Unit Test(Isolated test): Should be fast, so you can run them several times a day without affecting productivity.
Isolated test give us fast and continuous feedback and also confidence that our components work as intended.

##Integration Tests:

Give us confidence that components collaborate as intended.
With no mocks and any other ttpes of testables.

However Integration tests can be slow so you won't be running them as often as fast as isolated tests.

While calling api
Interacting with databases or filesystems.

All tests (isolated & Integartion) hould run in your continuous integration pipeline.


## The Goal

The idea is to integrate all the cache model objects and see how they behave in collaboration or in integration.

In Unit/isolated tests, we preper to run operations in memory when possible, which should be ultra fast.

In Integration tests, we prefer to use a stack of production instances, with no test doubles.
This includes a physical file URL to make sure we can create and load the CoreData SQLLite artifacts to disk, which can slow down the tests.
