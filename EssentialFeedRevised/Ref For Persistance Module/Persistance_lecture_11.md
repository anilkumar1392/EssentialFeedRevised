## Persisting/Retrieving Models with Codable+FileSystem, Test-driving in Integration with Real Frameworks Instead of Mocks & Measuring Test Times Overhead with `xcodebuild`

1. Downside of using real time implementaiton of Codable is we are storing data in real time and this will effect the  whole system.
2. Upside is we are testing real behaviour.

Down side of not mocking the file system.

So we need to clean a disk every time we run a test.

While encoding and decoding we have made a change in production Type by conforming FeedImage confirm to Codable.

This may seems a minor change but we are adding framework dependency in model.
In future we may use realm so we will be adding realm dependency their.
Let's fix this.

We can do this by creating a local CodbaleFeedImage.
