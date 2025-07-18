---
title: Tuist 1.9.0 - Speedy Gonzales
category: "product"
tags: [Tuist, release, swift, project generation, xcode, apple, '1.9.0']
excerpt: In this blog post we announce the latest version of Tuist, 1.9.0, which introduces significant improvements in the performance of the project generation.
author: pepicrft
---

Hi there 👋,

It has been quiet for the past few weeks,
but we are back to announce a new release that we just baked,
Tuist 1.9.0.
As you might have noticed,
from this release,
we started giving them names.
We not only do it for fun,
but we think it is easier to remember a release.

## Faster project generation

1.9.0's name is Speedy Gonzales,
which relates well with one of the most significant improvements with are shipping with this release:
**faster project generation.**

One of the features that make Tuist's project generation unique at scale is using Swift as a format for the manifest files.
That allows developers to edit their projects using Xcode,
where they can get auto-completion, documentation, and validations.
Moreover,
they can extract pieces of their manifest into a separate framework,
`ProjectDescriptionHelpers`,
which they can import and use from their manifest files.
That's great,
but it comes with costs.
One of those is having to compile the files,
which takes significantly longer than reading a YAML or JSON file from disk.
[Kas](https://github.com/kwridan) noticed that and ventured into improving that.

The result of this work is a project generation that is **approximately 50% faster**.
Insane.
We [achieved](https://github.com/tuist/tuist/pull/1341) that by introducing caching.
After the manifest is first compiled,
we serialize it and store it as a JSON in the cache.
To uniquely identify the manifest in the cache,
we hash the content of the manifest as well as other files and metadata the manifest depends on,
for example,
the project description helpers.
If nothing has changed,
future project generations will read the JSON instead of using the compiler.

And this is just the beginning.
While doing this work,
we spotted some other opportunities for improving performance.
One of them is loading the dependency graph concurrently using multiple threads.
Stay tuned because you'll hear more about this topic in future updates.

> Note that the new caching behavior is enabled by default.
> If you notice project generation misbehaving, you can disable it by setting the environment variable `TUIST_CACHE_MANIFESTS=0`.

## Other improvements

Besides making Tuist faster,
this release also [adds support](https://github.com/tuist/tuist/pull/1382) for enabling the main thread checker in schemes.
It used to be enabled by default and we changed the behavior to be an opt-in feature.
If you define your own schemes,
`RunAction` and `TestAction` have now a new attribute,
`diagnosticsOptions` that you can use to enable the main thread checker:

```swift
let runAction = RunAction(config: .debug,
                          executable: targetReference,
                          diagnosticsOptions: [.mainThreadChecker])
```

Moreover,
we continued working on the Cloud set of features,
adding some [internal building blocks](https://github.com/tuist/tuist/pull/1335) that will be necesary for collecting insights from your builds,
and sending them to a server-side application that processes them.

## Minor bug fixes

Tuist 1.9.0 also [fixes a bug](https://github.com/Shopify/react-native/pull/1650) that caused `tuist edit` not to wait while the project was being edited.
and [removes](https://github.com/tuist/tuist/pull/1361) the unnecessary `CFBundleExecutable` attribute from the auto-generated `Info.plist` for bundle targets.

## What's next

We are working on the following areas:

- We are close to have a first iteration of our [support for configuring the environment and the generated projects for signing](https://github.com/tuist/tuist/pull/1066).
- We are doing some technical-debt work turning our graph representation into a value type with the goal of minimizing side effects to make the project generation more deterministic.
- We'll continue building the client-side logic for the 2 major cloud features, insights and caching.

## Some closing words

As always,
you can update Tuist by simply running `tuist update`.
We are excited to keep pushing the project forward and making interacting with your projects as easy and fun as possible.

If you want to chat with contributors and other users of Tuist,
you can join our [community forum](https://community.tuist.io).
Also, you may consider supporting us on the [GitHub Sponsors](https://github.com/sponsors/tuist) program and [Open Collective](https://opencollective.com/tuistapp).
This project is developed by people devoting their spare time,
so a token of appreciation means a lot.

I hope you are all safe and wish you all a steady return to the new normal.
