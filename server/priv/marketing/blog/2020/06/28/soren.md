---
title: 'Interview with Søren Gregersen - Anyone in the team can create and maintain Xcode projects easily'
category: "community"
tags:
  [
    Tuist,
    SorenSHG,
    soundcloud,
    app development at scale,
    xcodeproj,
    xcode,
    swift,
    Emplate,
    xcodegen,
    xcode project generation,
  ]
type: interview
excerpt: 'In this interview we talk with Søren Gregersen, co-founder of Emplate, a digital studio based in Denmark. Søren shared with us how they use Tuist and the project description helpers for one of their main projects, a white label app for shopping malls in Europe.'
interviewee_name: 'Søren Gregersen'
interviewee_role: "Emplate co-founder"
interviewee_x_handle: 'SorenSHG'
interviewee_avatar: https://pbs.twimg.com/profile_images/1273573438767202306/5vapWEDT_400x400.jpg
---

In this interview, we talk with Søren Gregersen, co-founder of [Emplate](https://www.facebook.com/emplateaps/), a software studio based in Aarhus, Denmark. Emplate has been a heavy user of Tuist since they started using it in its early days. They've provided a lot of valuable feedback to make Tuist better and help other projects that face challenges maintaining and scaling up Xcode projects.

Without further delay, let's dive right into the interview:

### Tell us more about yourself and the project you work on

I am [Søren](https://twitter.com/SorenSHG) from Denmark. During university I co-founded a company called [Emplate](https://www.emplate.it/) together with some good friends. I have been tinkering with computers and software for +15 years and I love building things and solving problems.

## Team structure

### How are the teams structured?

Our company is still fairly small and we are 13 people in total. The product team consists of 7 people. We have two people working together on Android and two on iOS. My co-founder and I are also a part of the product team working on both our API, web-apps and also some Android/iOS. Apart from developers we also have a product designer working on everything from concept development to usability testing to marketing material.
The product team is a hybrid remote team spread across Europe which gives a lot of opportunities and challenges at the same time.

### How many engineers work on features and how many take care of the infrastructure of your projects?

We try to leverage tools that can help us not spending too much time on infrastructure work. This is one of the things Tuist has helped us a lot with as we went from having one person knowing about how the Xcode projects were configured and meant to be used to having it documented in the manifest files. This also means we do not have any people dedicated to only working on infrastructure or features - we share the tasks and responsibilities between us.

## Project and code architecture

### Could you describe the architecture of your project?

Our main project is a white label app for the guests in the shopping malls we work with. The app is currently available for +20 shopping malls across Europe in different variations. We use a strategy pattern to configure the app per shopping mall which allows us to customize them with different features, UI components etc. The Xcode structure is set up around multiple projects. One project with the app targets where the only source code is the AppDelegate + the configuration of each app. All app targets depend on a single framework in another Xcode project that contains the main part of the features. We do also have other separate frameworks containing network code, utility helpers, analytics code etc. Tuist has made this setup much more enjoyable and maintainable as we can set up a new framework project in a few minutes and make sure all frameworks are configured exactly the same.

### What code paradigms and architectures do you follow?

We use a basic implementation of the [VIPER](https://www.objc.io/issues/13-architecture/viper/) architecture. The benefit of using that architecture is that it provides a fairly clear definition of where to put certain kinds of code in a given module. This makes it easy for multiple developers to work together. Another benefit I like about VIPER is that it’s making testing our business logic very easy. The downside is that it might require a few more files and types than other architectures but using an Xcode template allows us to set up a new module in a few clicks.

### If you have multiple apps, how do you share code between them and how do you use internal tools to automate repetitive processes?

We have two app projects in Emplate - a white label app for the guests in shopping malls and a managing app for the staff across the shopping malls. The way we share code between the two projects is unfortunately by duplicating the code between them. We are looking into using the Swift Package Manager to start building some internal frameworks to be able to share code more conveniently.

## Dependencies

### How do you manage your third-party dependencies?

We use [Carthage](https://github.com/carthage/carthage) for managing third-party dependencies. To speed up build time on the CI and decrease the required project setup steps we track the built dependencies in a git submodule in the project.

### What’s a third-party dependency your project heavily depends on?

Our projects depends heavily on [RxSwift](https://github.com/ReactiveX/RxSwift) and [Texture](https://texturegroup.org/) _(formerly known as AsyncDisplayKit)_ for UI. We have been using these two dependencies for couple of years and they are in use in a large part of the projects at the moment.

### What’s your take on external dependencies?

I think external dependencies give a great way to leverage other people’s work and avoid having to reinvent the wheel over and over again. We try to limit the amount of dependencies we pull in and to not get locked in by them. We have experienced several issues with third party code when upgrading to new Xcode and iOS versions which is not fun to spend time on.

## Testing

### What’s your testing strategy?

We try to cover all business logic with unit tests. This comes as a natural thing as we tend to practice [TDD](https://en.wikipedia.org/wiki/Test-driven_development). In the VIPER modules we always cover the presenter with unit tests _(as close to 100% coverage as possible)_ with mocked view, router and interactor. In modules where the interactor has more complex responsibilities we also test those.
We also use the unit tests as a kind of documentation of the features in the apps and especially how edge cases are handled. It also gives the team members great confidence when touching other parts of the code base at a later point in time.

### Do you use third-party frameworks for testing?

We use [SwiftyMocky](https://github.com/MakeAWishFoundation/SwiftyMocky) to generate mock implementations of protocols which saves a lot of time writing boilerplate code when setting up a new test. I believe it has to be as simple as possible to get going with a new test case to keep the coverage high.

### How many tests do you have and how are they split between unit/integration/ui. Which ones give you more confidence?

We mainly use unit tests and have +500 unit tests across our two projects. We have simple UI smoke tests that verifies the apps can launch and allows the user to click around the main features. This UI test is also used for generating screenshots for App Store using Fastlane.

## Tuist

### What led you to adopt Tuist?

Adding a new app to the white-label project required too many manual clicks and drag/drop actions in Xcode that we had to keep a long list of steps to remember. Setting up a new app could take up to 45 minutes. After adopting Tuist the setup of a new app is down to a few easy steps using the scaffold command and is only taking around 15 minutes and can be done by the whole team. No more remembering and dragging and dropping inside Xcode 🎉

Apart from the setup of new apps it also turned out to be a big pain to maintain +20 app targets. Imagine having to change something in all of the Info.plists or add a new dependency from Carthage manually for all apps at the same time 🤯 Now we can just change it in a single place and next time we generate the project it’s reflected for all the apps.

### What’s the feature that you like the most from Tuist and why?

There are so many nice features in Tuist already but I think the [project description helpers](https://docs.old.tuist.io/guides/helpers/) are my favorite. It allows us to generalize and reuse the way an app or framework is configured.

### Do you use project description helpers? If so, how? Would you mind adding a code snippet that illustrates your usage.

We use project description helpers for everything from small utilities to defining a full app target. It’s a nice way to make sure that all our white-label apps and frameworks are configured in the exact same way. Here comes a few examples:

**Shorthand for defining Carthage dependencies**

To avoid having to repeat the path to the Carthage build folder we have defined an extension on the TargetDependency type to make it possible to define the dependency with just the name.

```swift
extension TargetDependency {
    public static func carthage(_ name: String) -> TargetDependency {
        .framework(path: .init("../Carthage/Build/iOS/\(name).framework"))
    }
}
```

**Specifying the app project**

In our project description helpers we have defined a _"Customer"_ struct to specify a customer/app in our white-label project. We then have extensions on the Target type to set up an app and UI test target from a customer instance. Our `Project.swift` for the app project then looks like this:

```swift
let customers: [Customer] = [
    .init(
        name: "Customer #1",
        bundleId: "app.emplate.customer1",
        fbAppId: "12345678"
    ),
    .init(
        name: "Customer #2",
        bundleId: "app.emplate.customer2",
        fbAppId: "87654321"
    ),
]

let project = Project(
    name: "EmplateConsumer",
    targets: customers.flatMap { [.app($0), .uiTest($0)] }

)
```

### One more thing: If you started the project again, what would you do differently?

Never promise support for anything below iOS 13 and use SwiftUI for all our UI code 😃
