Unified vs Segregated Models
A model should be a simple and consistent representation of a domain concept. When we share models across boundaries, it gets easy to start adding methods and properties that one of the modules need, let's say the API, but the others (e.g., UI, Analytics, and Persistence) don't. When this happens, our models grow in size and start to lose consistency.

The system's boundaries, based on their specifications, may require multiple model representations. Opting to use a single model across modules may lead to complex, costly-to-maintain, and hard-to-use code. “Trying to solve everyone’s problems at once will solve no one’s.”

Thus, instead of always passing models across boundaries, consider using a data transfer representation (also known as data transfer objects or DTO).

Creating separate model representations helps us keep the code concise and easy to develop, use and maintain. At first, the separate representations may look similar, but over time they often change at a distinct pace and for different reasons. When the models start deviating, it's important to be ready to separate the concepts in a way which will prevent the system from being in inconsistent states. Furthermore, team members should have a common/shared view of the context for each model, and work towards maintaining its consistency. The context breakdown will vary from project to project, depending on the domain and subdomain models, frameworks in use, parts of the application that requires separation, and even cross-team structure.

For example, the backend team might make model and payload decisions to facilitate their work. However, such changes may not fit the iOS application needs. If backend conveniences propagate to an iOS unified model, they can make the application harder to develop and maintain. Thus, you should proactively set a boundary (also called anticorruption layer) to prevent external actors from accidentally influencing/damaging your roadmap. This separation gives clarity (simple/pure models) to application developers consuming such external APIs, and freedom to the backend team to go their way in solving their challenges.

Such an approach is not complicated but counterintuitive to developers that were never exposed to modular design before. As developers, we often strive to find perfect abstractions, so multiple representations of a data model seem inelegant. For this reason, it’s common to see codebases where a desire to fully unify the domain model leads to inconsistent and hard to reason/maintain design. A unified model can be a good starting solution, but it is often not scalable or cost-effective.

However, we must also be careful with the other extreme: a design that diverges related concepts too much. Otherwise, the system grows in complexity, the cost of integration increases, communication between teams becomes harder, and we won’t be able to clearly see the correlations within the boundaries.

We prevent harmful model diversion by keeping the translation layer (the mapping to and from data representations) very close to the model representations (within the same project at this stage) and having a continuous integration process in place. By keeping modules within the same project, we must be disciplined with our actions as it’s much easier to cross boundaries accidentally or to trade modularity for quick (but costly) conveniences (debt). If you want to prevent such unwanted dependency accidents, separate modules in different projects. Also, if module reuse in other projects is ever a requirement, moving such modules to isolated projects will be necessary. The cost of maintenance and extension might increase with separate projects, but don’t be discouraged from doing so. When done right, the collaboration/integration friction is minimal, and the modularity and reuse benefits are high.

Regardless if your team decides to keep everything in the same project or not, communication is essential in keeping such separations clean and easy to use. We recommend drawing dependency diagrams, just like we’ve been using such visual representations to communicate our intent to you throughout the course. Diagrams can quickly show the desired separations, so everyone on the team is on the same page. Additionally, without a dependency diagram, it can be hard to visualize and solve dependency bottlenecks.

A conformist approach
Using a unified model controlled by an external team (e.g., backend API models/Firebase models) throughout the application is often called a “conformist approach.” There’s merit to such an approach, as it can speed up development at early stages of simple API-consumer app projects. If the app you’re building does nothing more than consuming and displaying data from some external APIs, such an approach might pay off while its requirements don’t change. However, the problem lies when the conformist path is the only path known by the team, but a decentralized approach would be more beneficial. It is essential to have more options to be able to identify when to switch strategies and refactor the design towards independence/freedom from external actors.

Goodwill is not enough to keep a codebase under control. A conscious effort towards better modeling and design supported by continuous refactoring is essential to take advantage of new information and insights.

Why keep the RemoteFeed(ITEM) name instead of RemoteFeedImage?
Ideally, every team working in the same software product should share a common language. However, it is easier said than done.

In our case, the backend team overheard discussions about videos and ads in the feed, so they decided to use the term “Feed Item” to protect themselves from those future requirements. If they called it “image,” it could be harder to introduce new kinds of items without breaking the proposed API contracts. However, the product team is still not sold on the idea of videos and ads, so they never mention such concepts in their language. This is a classic technical vs. non-technical view of the same product.

When discrepancies in the language happen, it’s important to keep such naming conventions in separated contexts to facilitate communication. In the context of the API, we keep their Item naming convention, but everywhere else where the business folks have more influence, we use their term (Image).

During meetings, it is highly advised to reiterate such terminologies as they might unify once new kinds of items (video/ads/sponsors) are added to the feed. However, they might diverge more, as business folks might decide to call them Feed Types, or whatever they see fit. In this case, it might be time to recommend one of the sides to compromise and accept the others’ term.

What about performance penalties?
If you have concerns about performance when translating models, you should measure it before optimizing. Developers are often surprised by how minimal the impact is, especially when using immutable data. Behind the scenes, the compiler will optimize such immutable data mappings since copies aren't always necessary.

Nevertheless, you can indeed find performance impediments with very large collections, in which case you must optimize. But before giving up on modularity, find ways to do so without affecting the system design too much. Caching and lazy evaluations go a long way in solving performance problems without affecting modularity.

A case against private extensions
In this lecture, we wrote private Array extensions for translating/mapping between model representations. Usually, we meet resistance from developers when creating private extensions on types. They like the discoverability that comes from internal and public types. For example, autocomplete is a great tool when trying to find which functions can be performed on a specific type. That is indeed a good argument against making extensions private.

A counter-argument is that, in some cases, the logic is very specific to the problem at hand. Where else would we see such a mapping from RemoteFeedItem to FeedImage? Maybe putting this extension in a shared scope is a premature action that won’t ever be required elsewhere, but that instantly expose private concepts to components that do not need to know about them.

We prefer to keep such behaviors private, within the scope it's required. However, it’s up to you and your team to decide.

Why should we strive to “test through the public interfaces”?
In this lecture, we displayed the power of flexible tests when restructuring the Feed API dependencies. We introduced the RemoteFeedItem data model, removed the FeedItem source code dependency from the FeedItemsMapper, added a translation/mapping helper, and we didn’t have to change any tests.

Since the mapper and the data model are internal types, and we don't expose internal/private types to tests, the refactoring was safe and easy. That’s the power of testing only through the public interfaces: behavior is guaranteed to stay the same while we have the freedom to move things around and repurpose the design as needed.
