
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
