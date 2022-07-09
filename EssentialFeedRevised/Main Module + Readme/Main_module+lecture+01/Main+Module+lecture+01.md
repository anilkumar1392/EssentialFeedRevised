 ##   Feed Image Data Loading and Caching with URLSession/CoreData + Composing Modules Into a Running iOS Application with Xcode Workspaces

## FeedStore

<FeedStore> protocol is an abstraction to hide infrastrucutre detail(e.g., CoreData) from its client (LocalFeedLoader). 

and 

## FeedImageDataStore

<FeedImageDataStore> is an abstraction to hide infrastructure detail(e.g, Core Data) from its client (LocalFeedImageDataLoader).

## Infrastructure abstraction should have exactly what the client needs.
