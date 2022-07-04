
## Refactoring Massive View Controllers Into Multiple Tiny MVCs + Using Composers & Adapters to Reduce Coupling and Eliminate Redundant Dependencies


// Clean code is a must but not enough we must also manage dependencies effectively.

As we keep adding features the class will keep growing along with number of dependencies and responsibilites.

e.g,
Formating number and date, pagination, sharing images performing view animations and layouts firing analytice event and etc.



// Now to solve massive view controller problem we will create multiple conrtoller with one responsibility.

So after moving refresh control to a new class refresh control took four resonsibilites from FeedViewController but it added to new responsibilty to FeedViewCOntroller (Creating/Communicating) with refreshControl and that can be a problem.

# Ideally we don't want objects creating their own dependency.
It will be better to move dependency creation somewhere else.

Let's keep an eye on this as we don't want to create dependency
 
2. Sinc feedViewCOntroller is a UITableViewCOntroller it's job is to populate UI tableView so jump to the next one.
3. FeedImageCell creationa and configuration and managing feed image state 
     so we can keep the tableview datasource code in the controller and move cell creation and configuration to another controller
     
     // The idea here is one controller per cell.
    So method injection may not be the best choice here.
    Since model dont very for this controller.
    it is more suitable to move it to a initializer injection.
    
    This calss does not need to manage more than one model or more than one imageLoader. So initializer injection is best here.
    
    We moved several responsibilities to the 'FeedIamgeCellController' but again FeedViewController gain another two more responsibility Creating and communicating with the 'FeedImageCellController' 
    
    ## Creating your own dependencies can be a problem.
    
    After having FeedViewController, FeedImageCellController, FeedRefreshViewController diagram shows now we have more dependencies than previous beacuse FeedViewController has to create its dependencies.
    
    So clean code and separate responsibilites are must bu tnot enough we must also manage dependencies smartly.

##1. Clean Code
##2. Separate Responsibilities
##3. Manage dependency

we need to create dependency creation and injection in to a separate component.

Since FeedViewController Create RefreshController thats why it need FeedLoader as a dependency.

        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        
        Then it creates FeedImageCellController for every cell adn since cellControlelr needs a image loader the feedViewController also depends on  image loader.
        
        So we need to separate the creation.
        The FeedViewCOntroller should onkly use its dependency.
        
        1. One solution is to inject it as a dependency.
        
## We need to create FeedImageCellController on demand

1. A common approach to solve this problem is to use factory.
 factory will have a reference to the image loader then we can decouple the feedViewController from the image loader.
 
 but now we have a extra dependency. ## The Factory and the factory depends on the image loader.
 although its a popular solution but it does not solve the problem.
 
 So factory don't solve our dependency problem.
 
 ## also FeedViewCOntroller also depends on tableModel just to pass it to the cell controller so ideally FeedViewCOntroller should not depend on FeedImage or imag e loader.
 
 ##Solution: 
 
 So we have tableModel an array of FeedImages 
 1. but we don not need FeedImages we need CellControllers.
 So what if instead of tableModel we get cell Controllers. that is created by someone else then we can decouple the 'FeedViewController' from 'Feed' and 'ImageLoader' at teh same time and move the responsibility of creation to another component.
        
    Now we have all the object creation in one function so we can move it to another fucntion.

## Closure in composer
// closure here we may fine it odd but that'a the adapter pattern. it is very common in composer types to adapt unmatching types.

        // closure here we may fine it odd but that'a the adapter pattern. it is very common in composer types to adapt unmatching types.
        
        //1. Refresh controller delegates array of 'FeedImages' but the 'FeedViewController' ecpects array of 'FeedImageCellController'
        // So while composing types the adapter pattern conenct a matching api's.
        
        // [FeedImages] -> Adapts -> [FeedImageCellController]
        
        // To keep the responsibilty of creating dependencies away from types that uses the dependencies.
        
        // We can even move it to a separate function to clarify the intent.
    
## Finally The FeedViewController 
Does not depend on 'FeedLoader', 'FeedImage', 'FeedImageDataLoader', and 'DataLoaderTask'

we separted the responsibilities along with dependencies and the code is still clean.

## Multi MVC is just MVC.

we can further divide them for eg. we can have a ImageViewController just to manage image data loading with a retry actions.
The point is we can spilt responsibilites as much as we want with smaller mvc's.

## Learning Outcomes
Distributing the responsibilities of a view controller with other controllers to form a multi-MVC design
Creating Composers to separate usage from creation and decoupling components
Using the Adapter pattern to enable components with incompatible interfaces to work together seamlessly

## Architecture overview

## Visualizing all the MVC responsibilities

To understand the FeedViewController’s responsibilities we grouped its interactions with other components in individual MVC groups. You can visualize the segmented MVCs through the following graph

1. Describes how the FeedViewController manages the FeedLoader loading state, updates the UIRefreshControl view and handles UIRefreshControl events via the target-action pattern.
2. Describes how the FeedViewController manages the feed state, which is an [FeedImage], to populate the UITableView via the UITableViewDataSource protocol. Additionally, it also handles delegation and prefetching events for the table view.
3. Describes how the FeedViewController creates and configures FeedImageCells with the FeedImage data model.
4. Describes how the FeedViewController manages the FeedImageDataLoader loading state for every ongoing image request, and it updates the FeedImageCells accordingly. When the request fails, it updates the cell and handles retry actions.

It’s important to note that the Models and Views of all MVC groups are very lean. They have single responsibilities and don’t depend on any other components. On the other hand, the FeedViewController is responsible for the following:

## Separating usage from creation

Although we distributed responsibilities, the FeedViewController ended up with new roles: creating the FeedRefreshViewController and the FeedImageCellController.

The main problem is that, as long as the FeedViewController creates its collaborators, it needs to provide their dependencies.

Thus, the FeedViewController ends up requiring redundant dependencies, just to pass it forward to its collaborators:

The FeedRefreshViewController needs the <FeedLoader> dependency
The FeedImageCellController needs the FeedImage and the <FeedImageDataLoader>.
As a result, even though the FeedViewController does not use those components, it still depends on them.

To achieve low coupling, there must be a clear separation between creating and using instances. Dependency Injection is the solution.

To separate creation and usage between the FeedViewController and the FeedRefreshViewController and FeedImageCellController we created a new component: the FeedUIComposer.

As you can see in the diagram above, the FeedViewController now only uses the FeedRefreshViewController and the FeedImageCellController which the FeedUIComposer is responsible for creating.

The FeedUIComposer, for now, is merely a namespace holding a static function that creates the FeedViewController with its dependencies.

Moreover, as part of composing components, the FeedUIComposer must adapt unmatching APIs.

## The Adapter pattern

The Adapter pattern is a structural design pattern that relies on object composition.

The purpose of an Adapter, also known as Wrapper, is to convert the interface of a component into another interface a client expects. It enables you to decouple components from complex dependencies.

In other words, the Adapter pattern enables components with incompatible interfaces to work together seamlessly.

In our case, the FeedRefreshController sends [FeedImage] but the FeedViewController expects [FeedImageCellController].

Thus, to maintain a clean separation between the two, we need to transform (or adapt) the communication between them.

Although the Adapter pattern is often implemented as a class, nothing stops you from following its principles to implement adapter functions as we did.

## Composer Rules

As stated previously, the Composer is a powerful concept to separate instance creation from usage.

However, to truly achieve the desired low coupling, some usage rules must apply:

Composers should only be used in the Composition Root
Only Composers can use other Composers
What that means is that you shouldn’t be interacting with composers anywhere in your codebase.

For example, imagine that after login, you want to present a FeedViewController instance. It might be tempting to let the LoginViewController use the FeedUIComposer static function to create the FeedViewController. But doing so will make the LoginViewController depend on redundant dependencies, such as the <FeedLoader> and <FeedImageDataLoader>.

Although tempting to use Composer types within your instances to create collaborators, you should use Dependency Injection instead. Only use Composers in the Composition Root to reduce coupling and prevent redundant dependencies!

“ …[creating instances] isn’t suddenly “illegal,” but you should refrain from using it to get instances of Volatile Dependencies outside the Composition Root. Also, be aware of static classes. Static classes can also be Volatile Dependencies. Although you’ll never use the new keyword on a static class, depending on them causes the same problems. The most common and erroneous attempt to fix the evident problems from newing up Dependencies involves a factory of some sort.“—Mark Seemann and Steven van Deursen “Dependency Injection Principles, Practices, and Patterns”

## Factories and Dependency Injection

In this lecture, we demonstrated how using a concrete factory directly in the client code does not provide any value regarding Dependency Injection, modularity, or decoupling. In fact, even Abstract Factories can increase the number of redundant dependencies and complicate the design.

Factories should be used to remove duplication / encapsulate the logic of creating complex instances, not to reduce coupling. To reduce coupling, Factories (such as Composers) should be used only in the Composition Root.

