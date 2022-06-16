Test-driving Cache Invalidation + Identifying Complex (Bloated) Functionality With The Command–Query Separation Principle



Learning Outcomes
Test-driving cache invalidation
Identifying bloated requirements
Identifying bloated code with the Command–Query Separation principle
Bloated requirements (and how it hides information)
One of the best skills a developer can master is the ability to break down problems into smaller tasks. For example, TDD helps us to break down tasks and solve one problem at a time at the code level. And before you even start coding, you can break down tasks by drafting use cases based on the requirements you receive from the business.

Smaller tasks are easier to estimate (time and cost), test, implement, develop, and deploy.

Before accepting a new task, make sure to—along with business peers—clarify and break down the work into smaller units. It’s amazing how much hidden information you can uncover in this exercise. Also, by working closer to business people, you’ll learn more about the short- and long-term business goals and will be better equipped to help everyone thrive (including yourself).

Refining requirements is an extremely valuable skill for developers to master. To achieve influence within the business, negotiate deadlines responsibly, deliver remarkable results, and build an exceptional career, we should practice it with every opportunity.

What to do when you find hidden requirements while coding
Once you’ve accepted and started working on an assignment, you may find missing/hidden requirements. You should be fine as long as you follow a process to manage the hidden complications accordingly.

If the newly found work is doable within the agreed deadline, notify your team, document the newly found requirements within the current task to make it visible to everyone, and carry on.

If the newly found requirements can’t seem to fit the deadline, announce the situation to the team and, together, decide how to proceed. Here are some possible decisions: rethink the deadline, allocate more people to the task, descope, simplify the feature…

Bloated code
Another negative side of bloated tasks is that it may lead to bloated code. To deal with them effectively, you can use programming principles to help you identify and break down tasks. For example, we have already introduced the Single Responsibility Principle in previous lectures. But there’s another good design principle we haven't mentioned yet: the Command–Query Separation.

Command–Query Separation (CQS)
Command-Query Separation is a programming principle that can help you identify functions/methods that do too much. The idea is simple:

A Query should only return a result and should not have side-effects (does not change the observable state of the system).

A Command changes the state of a system (side-effects) but does not return a value.

“Command” is a generic name used in many contexts, so some people prefer to use “Modifier” instead. Query-Modifier Separation. A simple way of looking at it is that of Getters (Query) and Setters (Command/Modifier). For example, customer.name is a getter and should not change the state of the Customer instance. customer.name = “Mary” is a setter so it should change the state and not return a result.

In our case, asking for the cached feed (query) should not also delete an invalid cache (side-effect: altering the state of the system). Instead, we can break this task into two: Load Cache (query) and Invalidate Cache If Needed (command).

Command-Query Separation is a principle that will help you uncover bloated functions/methods and guide you towards simpler code. However, like all principles, it doesn’t fit all contexts (no silver-bullets). It’s common to see commands/modifiers that, for a good reason, return a result. For example, Swift’s Standard Library remove(at index: Int) method for mutable collections does not comply with the CQS principle because it returns the removed object. But for a good reason: it leads to simpler and more idiomatic code!
