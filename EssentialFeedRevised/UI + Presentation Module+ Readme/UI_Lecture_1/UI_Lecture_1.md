##   Gathering Fast Feedback and Validating UI Design and Dev Decisions Through Realistic App Prototypes


Learning Outcomes
Validating UI design and dev decisions through prototyping
Working effectively with designers
Improving collaboration and getting fast feedback from clients with prototyping

## Why have a prototype?
Prototyping is an excellent technique for creating the first iteration of your app or feature without committing too many resources, such as time and money.

Prototyping provides a quick way of experimenting with ideas (e.g., “Should I use a table or collection view?”) and gathering insights from key people to your organization and clients.

You can share your prototype app with a trusted and valuable group of testers and use the received feedback for improving your product, iteratively. You can even automate the prototype releases with Apple’s TestFlight service.

Prototyping is another tool that helps you work in fast iterations (small batches) as it allows you to get feedback from your peers and customers validating if the user experience is moving in the right direction.

Releasing running apps frequently (daily or weekly), even if simple prototypes or beta versions of your app, increase trust and transparency with clients such as stakeholders and customers as you are inviting them to be part of the development process. Being transparent about the development, design, and release processes since the beginning of the product can accelerate the deployment frequency, bring value to your customers faster and provide you with valuable insights from a client perspective that otherwise the dev team could miss.

## Prototyping with Empathy and Integrity
Developing and releasing a prototype app or feature doesn’t imply building something of poor quality.

Although it should take a lot less time and effort to prototype a version of a feature than actually creating a fully functional one, you shouldn’t treat your prototype recklessly, especially when releasing it to a group of people to test it. Instead, we advise you to show the same level of professionalism and care you would as if it was the final version of the product. A great prototype will win you points with everyone that interacts with it!

The following checklist contains suggested items for reviewing before releasing a prototype feature to your clients:

the design is polished following the specs (app icons, fonts, colors, margins, images, animations, etc.—aim for a realistic experience!)
the content is localized, if your testers expect it to be
the app works on all expected orientations
the description on the tester invite is detailed and specific enough to avoid any confusion for the testers (with a clear way for testers to provide feedback!)

## Working effectively with designers
Another great benefit of prototyping is working closely with designers. If you can, invite them to create the prototype together. It can be a rewarding bonding experience in the team, and you can learn a lot about graphical design in the process!

Moreover, it’s common for designers to create custom elements that don’t fit the Human Interface Guidelines by Apple (custom transitions, custom controls, custom tab bar positioning & sizing, etc.).

We recommend you prefer standard platform components such as navigation controllers for navigation on iOS, instead of reinventing the wheel.

Standard components are:

Easy to use, out-of-the-box solutions.
More maintainable long-term as you often get new features for free (e.g., standard components adapted nicely to safe areas when the notch was introduced—you got the adaptability for free!).
Expected by customers are already as they’re used to standard components (Apple standardized the UI, so users don’t get surprised every time they open an app!).
So what can you do when designers create custom components?

Share with them the Human Interface Guidelines by Apple.

Don’t say "NO!" to the designers, but make sure they understand the cost of not using built-in components and the risks custom solutions may bring as Apple creates new devices that don’t work nicely with the custom UI. For example, when supporting multiple languages in your app, custom elements may not play nicely with right-to-left languages or accessibility features.

However, sometimes, custom solutions work great! There are great (and beautiful) custom UI features outside Apple’s standard design. If it makes sense, go ahead, and implement custom UI elements. Just make sure the team understands the cost (including maintainability!) and is happy with taking risks.

## The prototype feedback loop
“Let’s run the app to make sure we didn’t break anything!”

When developing the internals of a feature (e.g., as we’ve been doing so far with the business logic) we have been using test-driven-development generating a suite of blazing-fast automated tests where we can validate any changes in the codebase in very little time with a very minimal cost. The feedback loop of automated tests is delightful.

On the other hand, when prototyping, we are bound to run the app manually to gather feedback (which can be very slow).

Although it takes a lot more time to run the app and verify that the new changes didn’t break the previous state of the UI, prototypes usually have little to no logic, making the duration of the whole process brief and cost-effective.

Remember: a prototype is just an experiment to validate an idea and shouldn’t be “promoted” to production. We recommend you to use it only to spike ideas. When it’s time to write production solutions, start fresh!
