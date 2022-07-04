
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
    
