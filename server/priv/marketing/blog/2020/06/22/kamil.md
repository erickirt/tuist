---
title: 'Interview with Kamil Pyć - With Bazel we were able to reduce build times by 70% on clean builds'
category: "community"
tags:
  [
    Tuist,
    kamil,
    soundcloud,
    app development at scale,
    xcodeproj,
    xcode,
    swift,
    Allegro,
  ]
type: interview
excerpt: "In this interview, we talk with Kamil Pyć, Senior Mobile Developer at Allegro. Allegro is one of the few companies that have undertaken replacing Xcode's build system with Bazel, and that led them to an improvement in build times of roughly 95%. In this interview, Kamil shares more about Bazel's adoption, and some other insights about their project and teams."
interviewee_role: "iOS developer at Allegro"
interviewee_name: 'Kamil Pyć'
interviewee_x_handle: 'KamilPyc'
interviewee_avatar: https://pbs.twimg.com/profile_images/745018488184516608/Skzxzejl_400x400.jpg
---

When we announced the idea of publishing a series of interviews around app development at scale Kamil offered to participate and tell us more about iOS development in the biggest e-commerce company in Poland, [Allegro](https://allegro.pl)

### Tell us more about yourself and the project you work on

I'm Kamil Pyć. I have been working as a Senior Mobile Developer at [Allegro](https://allegro.pl) for over 6 years. Currently I am part of the team responsible for supporting other developers - providing tooling and solutions for them to create our app fast and efficiently. Allegro is Poland's biggest e-commerce company - providing millions of products to millions of customers. That was a succulent offer that we couldn't turn down so let's dive right into the interview with Kamil:

## Team structure

### How many engineers work on features and how many take care of the infrastructure of your projects?

We used to have platform specific teams but now mobile developers are part of feature teams. Currently we have about **35 developers** working on our iOS application. Our app is divided into **50 modules** so every team has at least one module to take care of. We have a dedicated team that performs releases every two weeks and our iOS infrastructure is a team of three people.

## Project and code architecture

### What are the main challenges on your architecture when scaling?

There is nothing revolutionary about our code architecture - we mostly use MVVM, yet we are open to other paradigms if they are more suitable for the use case at hand. For example reactive programming architecture is applied just in the module of user registration which has a lot of input and validation.

Main challenge of working with application that have many modules and over 500k+ lines of code is how to work at such a scale. If we have like hundreds of modules described with yamls and for some reason we would like to change all of them, sometimes it is just easier to write a script to do it. With many developers it’s hard to track all changes in codebase, that why we have added many automated metrics like clean & warmbuild times, application size & launch time etc.
We managed to solve a couple of problems we had with a large code base - long compilation time is fixed thanks to [Bazel](https://bazel.build/) caching and we used to have many conflicts in Xcode projects - thanks to XcodeGen we don’t have to worry about that.
We work in iOS monorepo, all of our modules and applications are in one repository so sharing frameworks is as easy as adding one line into the XcodeGen project spec.

## Dependencies

### What’s your take on external dependencies?

We use cocoapods but the standard way of integration is not scaling well. To avoid conflict in Pod projects and to avoid adding all modules into Podfile we set `integrate_targets: false, generate_multiple_pod_projects: true`. Thanks to that our dependencies look and behave just like our internal modules and we can easily add them to any project.
We keep the number of external dependencies as low as possible, few essentials we use are [SDWebImage](https://github.com/SDWebImage/SDWebImage) for downloading images or [Firebase](https://firebase.google.com/) for collecting crash reports. When we integrate a third party dependency we always create a wrapper for it so it’s easy for us to replace it or remove it since it’s imported only in one place.

## Testing

### How many tests do you have and how are they split between unit/integration/ui. Which ones give you more confidence?

We follow [The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html), we are getting closer to **20k unit tests**, we have a couple of test suites for UI tests - fast general one with critical buying paths that are built with every PR and a couple more detailed that are scheduled and another set that runs on real devices. We used [snapshot testing](https://github.com/pointfreeco/swift-snapshot-testing) for visual regression and [EarlGrey](https://github.com/google/EarlGrey) for UI testing.

## Tooling

### What are some challenges you are facing scaling up your project?

The with tooling is that the only way to know that someone has a problem with tools is to report it to you with email or Slack. That's why we have created a wrapper master tool for our tool that provide us with that - we now know how long it takes for XcodeGen to generate our project, if there were any errors - thanks to that we have more control over tools we use, if any tool update will increase error rate or execution time - we will know before anyone will report it to use. Looks like Bazel is most popular tool in iOS world that you can achieve just that - it’s used by teams in [Lyft](https://www.lyft.com/), [Pinterest](https://www.pinterest.com/), [LinkedIn](https://www.linkedin.com/feed/) and a few other large mobile teams.

## Build times

### What was the biggest challenge of adopting Bazel?

Our motivation to use Bazel was looking for a way to reduce our build time. Tweaking build settings and hunting Swift compiler with -Xfrontend is a short time solution that gains us ~5% of build time drop. Only sensible way to seriously improve build time is to not build anything that was already built in the past - just download it from a shared cache.
At the beginning we tried integrating Bazel using official rules for iOS, but that way had many issues:

- Wwe couldn't mix Obj-c and Swift in single module
- We would have to migrated and maintain BUILD files for 3rd party dependencies
- It’s impossible to do incremental adoption - so we would have to migrated all of our modules at once
- Build is performed outside of Xcode, so to debug or profile the app we would have to generate special project that would allow as to do it, official tool for that - [Tulsi](https://github.com/bazelbuild/tulsi) don’t do it quite well, probably we would have to build our own tool like Pinterests did with [XCHammer](https://github.com/pinterest/xchammer).

During the Bazel evaluation we did find it pretty flexible - we can basically cache anything that takes input files and generate output. We added a pretty simple xcodebuild wrapper in Starlak _(language used by Bazel)_ and we were able to generate cacheable XCFrameworks for our modules using good old Xcode and .xcodeproj. Later we had to migrate to fat frameworks because of problems that began to surface with XCFrameworks.

We have a special focusing tool similar to `tuist focus` - developers select modules to focus on and only those are included in the workspace, everythings else is built with Bazel as build phase and copied to `BUILT_PRODUCTS_DIR`.

_So how much did the build time improve?_ Our dependencies are responsible for about ~70% of build time and we were able to **reduce by 95% on clean build** -remaining 5% is the time to download a cache from the server and copy it build dir. Our next goal is to cache the application the same way as we do for modules and reduce this time even further.

## WWDC

### What are you the most excited about for WWDC?

I wouldn't change much if I start the project again - probably just to use Combine and SwiftUI - because we still support iOS 12 users and we are not able to use all the new goodies right away.
For this year's WWDC I am most excited about changes in Xcode - some stuff are already in progress - like [llbuild2](https://github.com/apple/swift-llbuild2) - it’s a change that we can get native Bazel like solution.
