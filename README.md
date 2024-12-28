## Custom, interactive UIKit animations & transitions

Implementing fluid, interactive transitions between view controllers with UIKit.

## Motivation

In my opinion (and amongst other things), what sets apart a good app from a great one is the implementation of fluid, interactive transitions when navigating between screens or presenting modals and the like. Whether it's gesture-driven (like a pinch to expand/dismiss views in [Dot](https://new.computer/)) or uses a shared, interruptible model (like when going between a post and its detail view [Instagram](https://instagram.com)), such transitions really elevate the UX of an app.

This repo aims to replicate and build upon such transitions, and serve as a reference for anyone who may be interested in learning and implementing these for themselves.

Since there are so many parts to creating custom UIKit transitions (some boilerplate, some actual code), I think the best way to learn and eventually implement them is to sit down and read through the documentation and [articles](#Resources) that exist on this topic, and to play around with example code. It might take a few days, or even weeks (as it will for me) to really understand the necessary protocols, delegates and methods that go into creating custom transitions, so I recommend being patient and working through them step by step.

## Pre-requisites

I found that already having experience with Swift and SwiftUI helps a lot, as well a basic understanding of `UIViewController` life cycles, delegates and protocols.

## Overview

These are the main ingredients that go into implementing custom, interactive transitions:

- `UIViewControllerTransitioningDelegate`: tells the system that you want to supply custom transitions for view controller **presentations** and **dismissals** (like sheets, modals, etc.).
- `UINavigationControllerDelegate`: tells the system that you want to supply custom transitions for view controller **pushes** and **pops** (like going between a grid view and a detail view).
- `UIViewControllerAnimatedTransitioning`: think of this as an **animation controller**. During transitions, UIKit will call our animation controller with the necessary context, allowing us to execute our custom animations instead of the default ones.
- `UIViewControllerInteractiveTransitioning`: think of this as an **interactive animation controller**. If implemented alongside `UIViewControllerAnimatedTransitioning` and configured appropriately, this will enable interruptible transitions that work alongside the custom, non-interactive animations.
- `UIPercentDrivenInteractiveTransition`: an object that drives an interactive transition. This enables gesture-driven navigations like swipe to go back. The default implementation would utilize the existing transitions defined in `UIViewControllerAnimatedTransitioning`.
- `UIViewControllerContextTransitioning`: passed as a parameter to the required methods of `UIViewControllerAnimatedTransitioning`, this context contains information about both the presenting and presented view controller, and (if extended and conformed to by our view controllers) can hold other information that is useful for our custom transition(s).

## `UIViewControllerAnimatedTransitioning`

This is a protocol in UIKit that allows you to create custom transitions between view controllers. In other words, it contains the logic for the animation (interactive or not) that occurs during the transition. It has two required methods to implement:

1. `transitionDuration(using:)` returns the duration of the entire transition animation
2. `animateTransition(using:)` is where you define the actual animation sequence(s) which will be executed during the transition
`
And both methods have a `transitionContext` parameter of type `UIViewControllerContextTransitioning` that is crucial as the system will be providing all the necessary components through this parameter to use for our custom transitions. 

This `transitionContext` object also contains a `containerView` that we will use to show whatever views we need to as the `from` view controller transitions to the `to` view controller. Think of it as the intermediary view. It starts off empty, and we can add any views we want, including the previously mentioned `to` and `from` views that already exist within the `transitionContext` object.

## `UINavigationControllerDelegate`

To use our concrete implementation of `UIViewControllerAnimatedTransitioning` (let's call it `TransitionAnimator`), i.e. our animation controller, we will have our view controller(s) conform to `UINavigationControllerDelegate` and implement the following method:

1. `navigationController(_:from:to:)`, which will return an instance of `our custom `UIViewControllerAnimatedTransitioning`, i.e. `TransitionAnimator`

This tells UIKit that we want to use our custom transition animation instead of the default `push` and `pop` animations when navigating between view controllers.

Alternatively, we can have `TransitionAnimator` be the one conforming to `UINavigationControllerDelegate`, which will have to implement the method above. Then, we set our view controller's delegate to `TransitionAnimator`. The following describes the pros and cons of these two approaches.

### View controller conforming to `UINavigationControllerDelegate`:

Pros:
- Clear separation of concerns: the view controller handles its own navigation delegate methods, and can customize it if needed
- Direct access to view controller properties and state

Cons:
- Code duplication if multiple view controllers need the same transition
- View controller has additional responsibility beyond its main purpose
- Mixing navigation logic with view controller logic

### `TransitionAnimator` conforming to `UINavigationControllerDelegate`:

Pros:
- Better reusability as one animator can be used by multiple view controllers without additional configuration
- Cleaner view controller code as they don't need to implement the navigation delegate method
- Centralizes all transition-related code in one place
- Easier to maintain and update transition logic

Cons:
- May need additional configuration methods if transitions need to be customized per view controller
- Less direct access to view controller properties; might require additional communication patterns

### Which approach should I use?

If you want to implement custom but still simple transition animations, like a slide or fade that doesn't require the animator having access to any of the view controller's properties (but potentially just the view controller itself), then the *second* approach is more appropriate.

If the transition logic is tightly coupled with the view controllers' internal state and behavior, e.g. the transition requires knowledge of which `UICollectionViewCell` was tapped or the frame of the view you want to have animate between the two view controllers, then the *first* approach is more appropriate.

## Instagram transition demo

This demo replicates the transition behavior when going from a post on a profile to the detailed post view, where the image appears to expand into the new screen. It utilizes a custom transition and transformations to pull off – please see the detailed comments in `CGAffineTransform+Extensions.swift` for more info on this, in particular the following methods:

```swift
static func transform(parent: CGRect,
                      suchThatChild child: CGRect,
                      matches targetRect: CGRect) -> Self
                      
static func transform(parent: CGRect,
                      suchThatChild child: CGRect,
                      aspectFills targetRect: CGRect) -> Self
```

Essentially, when the transition begins, we crop the destination view to match the image's frame in the grid using a mask, and position it atop the image in the grid. Then, as the transition progreses, the destination's view grows to take up the entire screen.

## [untitled] transition demo

It is crucial that the `sharedView` that both view controllers implement are **copies** instead of references, since it becomes **much easier** to reason about and manipulate them for our custom transitions. Otherwise, we would have to involve convoluted logic to manage and restore states before, during and after the transition. With copies, we can easily create and destroy them on demand with little overhead. The only caveat is if the view is complex, this operation might take much longer. The alternative is to manipulate the source and destination views themselves using clever tricks like masks, as is the case with the Instagram transition demo.

## TODOs

- [x] Fix `index beyond bounds` error
- [ ] Make `pushAnimation()` interruptible (ref: [WWDC 2016: Advances in UIKit Animations and Transitions](https://devstreaming-cdn.apple.com/videos/wwdc/2016/216v55u6zpxizxkml6k/216/216_hd_advances_in_uikit_animations_and_transitions.mp4))
- [ ] Implement Instagram-like vertical scrolling experience on `PhotoDetailView`
- [ ] Twitter half side-bar transition
- [ ] Support fetching remote images
- [x] If at the top of `scrollView`, activate pan gesture for starting transition
- [ ] Disallow multiple touch inputs during transitions
- [x] Implement [untitled] album transition with slide over
- [ ] Implement Facebook Paper card transition
- [ ] Experiment with rubber banding individual cells in `UICollectionView`s

## Resources

- [Custom view controller transitions](https://blorenzop.medium.com/custom-view-controllers-transitions-aa8c052f8049)
- [Replicating Instagram's shared transitions](https://medium.com/supercharges-mobile-product-guide/replicating-instagrams-shared-transition-on-ios-uikit-part-i-144a26c31353)
- [A complex push/pop animation](https://devsign.co/notes/navigation-transitions-iii)
- [View controller life cycle](https://medium.com/good-morning-swift/ios-view-controller-life-cycle-2a0f02e74ff5)
- [Spotify sheet transition](https://www.onswiftwings.com/posts/interactive-animations/)
- [Understanding `UIViewControllerAnimatedTransitioning](https://medium.com/@cleanrun/trying-to-understand-uiviewcontrolleranimatedtransitioning-5abff56c5f93)
- [Wrap your head around custom view controller transitions](https://danielgauthier.me/2020/02/19/indie-4.html)
