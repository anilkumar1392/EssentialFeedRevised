
# Effectively Test-driving MVC UI with Multiple Views/Models/State, Efficiently Loading/Prefetching/Cancelling Image Requests, Inside-Out vs. Outside-In Development, and Identifying the Massive View Controller Anti-pattern by Following Design Principles



## Learning Outcomes
Inside-Out vs. Outside-In development approaches
Efficiently loading images in UITableView cells
Efficiently prefetching images when cells are near visible
Efficiently canceling image loading requests to avoid excessive data usage
Managing multiple views, models, and state
Moving state management responsibility to clients with Return Values
Identifying the Massive View Controller antipattern
Test-driving UI components
Testing UIKit components without mocking
Creating in-memory UIImage representations for fast and reliable tests
Following the Open Closed, Interface Segregation, and Dependency Inversion Principles

// We are hiding all the implementation of tableView from the tests using DSL's.

// Every time we test in collection we test in 
1. zero case 
2. one element
3. Many element

This is a classic triangulation.
