---
title: 'Interview with Marek Fořt - The feature that I enjoy the most about Tuist is the clarity of manifest files'
type: interview
category: "community"
tags: [Tuist, marek, app development at scale, xcodeproj, xcode, swift]
excerpt: In this interview, Marek shares his experience at AckeeCZ adopting the Microfeatures architecture and how they use Tuist to codify the structure of their projects. He also talks about his stance regarding the usage of third-party dependencies, as how they approach testing to deliver code fast and with confidence.
interviewee_name: Marek Fořt
interviewee_x_handle: marekfort
interviewee_role: iOS developer at AckeeCZ
interviewee_avatar: https://avatars0.githubusercontent.com/u/9371695?s=460&u=c41f3b4590e74724c1a2972606d3c8ef321ef4b2&v=4
---

This post is the first one of a series of interviews about how different companies in the industry are doing app development at scale.
Our first interviewee is Marek Fořt, iOS developer at [AckeeCZ](https://www.ackee.cz/en), an app development studio based in the Czech republic.
Marek is a core member of Tuist, and has been the brain behind features like [scaffolding](https://docs.old.tuist.io/commands/scaffold/), and soon signing management.

Let's dive right into Marek's experience doing app development at scale:

## Team structure

### How are the teams structured?

We have a platform-oriented _(iOS, Android, web...)_ teams structure - every team has a team leader who is the go-to person for the other members.

## Project and code architecture

### What code paradigms and architectures do you follow?

We use MVVM architecture with [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) for all of our projects currently, although we have also started experimenting with [Composable architecture](https://github.com/pointfreeco/swift-composable-architecture) and Combine since we think that Redux-like approach might be a better option once we start using SwiftUI. Along with the MVVM architecture we have also started using [microfeatures](https://docs.old.tuist.io/building-at-scale/microfeatures/) approach for one of our larger projects - this has had the benefit of better separation of concerns, faster build times, we have also introduced an example app for each individual feature which means it is extremely easy to concentrate on the task at hand. You can check out our [MVVM template](https://github.com/AckeeCZ/iOS-MVVM-ProjectTemplate/): we are planning to publish a revamped version with the microfeatures and composable architecture approaches.

### If you have multiple apps, how do you share code between them and how do you use internal tools to automate repetitive processes?

Most of our shared codebase lives in our [open-source repositories](https://github.com/orgs/AckeeCZ/teams/ios/repositories) - I’d highlight [ACKategories](https://github.com/AckeeCZ/ACKategories) where our more general-purpose extensions and convenience structs and classes live and then [ACKLocalization](https://github.com/AckeeCZ/ACKLocalization) which we use constantly to download and generate new localization strings from a Google spreadsheet. For building, testing and publishing an app we mostly use [Fastlane](https://fastlane.tools), but we are stoked about trying out new features in Tuist that could help us simplify a hard-to-reason-about Fastfiles.

## Dependencies

### How do you manage your third-party dependencies?

In most of our projects we use [Carthage](https://github.com/carthage) and [Cocoapods](https://cocoapods.org). For Carthage we also use [Rome](https://github.com/tmspzz/Rome/), so not every user is forced to rebuild Carthage dependencies whenever they start working on a new project. But for our microfeatures app we have ditched Cocoapods and started using Swift Package Manager - managing a microfeatures architecture with Cocoapods was not ideal since there was an added overhead. But SPM dependencies are defined right in the Tuist manifests, so the definition and maintenance of dependencies is easier and helps with the code review process!

## Testing

### What’s your testing strategy?

Since most of our logic lives in ViewModels and accompanying services, that’s where our focus lies when it comes to testing. We think testing is important, but on the other hand we do not strive to have a 100 % testing coverage. We let developers decide what they think are the important parts of code to test, so they gain confidence in the code they have written. It’s then part of the code review process to let the reviewer assess if the merge request has tests for the important business logic.

## Tuist

### What led you to adopt Tuist?

The main reason for us, initially, was getting rid of merge conflicts due to changes in a `.pbxproj` file. Besides that we also wanted to have a better sense of changes in the xcode project since reading `.pbxproj` during the code review process was … let’s say not ideal. After leveraging Tuist for code generation we have started to looking into how to use it for further optimization of development process, like migrating to microfeatures architecture.

#### What’s the feature that you like the most from Tuist and why?

It’s very hard to pick one, but I think the feature that I enjoy the most about Tuist is the clarity of manifest files. Being able to define the architecture, modules, dependencies, etc. in Swift files is powerful and brings more joy to parts of development that have been error-prone and tedious before we started using Tuist.

### Do you use project description helpers? If so, how? Would you mind adding a code snippet that illustrates your usage.

We use project description helpers extensively and it’s a key to achieve readable and scalable manifest files as it lets you to define your projects in multiple files. This also means that it is possible to reuse parts of project definition and you can articulate your own interface for a new module or app, so you only need to focus on things that are specific to the domain you are working on. As an example, we have a set of custom configurations that come with a custom set of settings. With project description helpers they are defined for the developer with a custom enum called `AppCustomConfiguration`. You can see [here](https://github.com/AckeeCZ/iOS-MVVM-ProjectTemplate/blob/master/Tuist/ProjectDescriptionHelpers/Project%2BTemplates.swift#L5) how easy it is to then use it for an app the developer is working on.

## Other

### What are you the most excited about for WWDC?

I hope that Apple will bring a next iteration of SwiftUI which will be focused on stability, so it will be usable in production apps without having to deal with all the quirks and bugs the current releases have been plagued with. I love the declarative approach and, as tuist, it helps developers to focus on building, rather than being forced to write boilerplate code and deal with very complex systems that UIKit and Xcode projects definitely are.

## Closing words

Hopefully, this interview has brought you, the reader, some useful information about how tuist might fit into your team’s workflow. I can’t recommend Tuist enough and I am looking forward to seeing how new features might help with our work even further. At the moment we are trying out the new `build` command and I am also trying to work on a new signing feature that will make setting up app’s signing more deterministic and easy to use 🎉
