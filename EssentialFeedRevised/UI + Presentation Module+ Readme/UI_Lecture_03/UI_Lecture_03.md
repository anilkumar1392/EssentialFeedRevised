 # Apple MVC, Test-driving UIViewControllers, Dealing with UIKit’s Inversion of Control & Temporal Coupling, and Decoupling Tests from UI Implementation Details
 
## UX goals for the Feed UI experience
[] Load feed automatically when view is presented
[] Allow customer to manually reload feed (pull to refresh)
[] Show a loading indicator while loading feed
[ ] Render all loaded feed items (location, image, description)
[ ] Image loading experience
    [ ] Load when image view is visible (on screen)
    [ ] Cancel when image view is out of screen
    [ ] Show a loading indicator while loading image (shimmer)
    [ ] Option to retry on image download error
    [ ] Preload when image view is near visible

## MVC is a UI Architectural Design pattern

SO we just need to create views and controllers.

One of the biggest misconception with MVC is their is only one Model one view and one controller per screen.
Infact a screen can be composed of many small MVC's.

// UIKIt is a third party framework because, even though it's part of the platform, it's private.

// We have no access to the source code. We can't change it or even see the implementation.
// We need to learn how the frame work works.

so while writing tests will not write test for viewDidLoad is actually invoked instead we just test what our implementation does when the framework tells us that the view is loaded.


