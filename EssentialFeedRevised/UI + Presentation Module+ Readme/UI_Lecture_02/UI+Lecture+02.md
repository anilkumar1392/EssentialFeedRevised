
##  Supporting Multiple Platforms with Swift Frameworks While Separating Platform-specific Components to Facilitate Loose Coupling and Speed up Development

## Learning Outcomes
Separating platform-specific and platform-agnostic components in Xcode using Swift frameworks
Supporting multiple platforms on Swift frameworks
Configuring Xcode Targets and Schemes to build and test all supported platforms on the continuous integration (CI) pipeline

## Separating platform-specific and platform-agnostic components


## Creating the iOS UI components in a framework
Since we don’t need to run the application yet (we’re still in the process of creating components), we created a new EssentialFeediOS framework to include all iOS-specific components instead of an iOS application.

This way, we can develop, maintain, and test the iOS components without having to run an application (which is faster!). Additionally, a framework allows us to easily share the iOS components across iOS apps too!

On supporting multiple platforms
It’s common for components to behave differently in distinct platforms. To guarantee the consistency of the behavior of the system on all platforms it’s essential to run all tests on all supported platforms!

There’s a cost for adding platform support as continuous integration can become slower, and the CI server costs can increase. However, you can minimize those extra costs by decoupling your modules and breaking them down into separate projects.

With decoupled modules and projects, when you make changes to one module, you don’t have to recompile/retest/redeploy the rest.

That’s another reason why we recommend breaking down your project into separate projects, frameworks, and modules.

The segmentation in modules reduces compilation, build and test times of large systems and subsequently, the time and cost of development, integration, and deployment.
