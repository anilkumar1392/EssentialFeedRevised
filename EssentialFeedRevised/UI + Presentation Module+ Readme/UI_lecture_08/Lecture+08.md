
##  Storyboard vs. Code: Layout, DI and Composition, Identifying the Constrained Construction DI Anti-pattern, and Optimizing Performance by Reusing Cells

To use storyboard we need to use property injection instead of constructor injection.

// Down sides of using storyboards

we loose compile time composition checks we can get with constructor injection.

using objects in storyboard we can confgure FeedRefreshViewController from storyboard.
So whole view configuration now leaves in stroyboard.

## Reusing cell is a new behaviour we are not covering in tests. which can lead to bugs.

Multiple controller may be refering the same cell is controller does not leave the cell when teh cell goes off screen.

when the cell goes off screen the didEndDisplayingCell is called so we should release the cell for reuse here.

## Rethink your assumptions by writing more tests.

1. It's essential to prove a problem with a failing test first
2. Only with a failing test you go ahead and solve the problem.
