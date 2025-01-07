## YUI

A gallery of various demos built with UIKit, demonstrating fluid, interactive transitions between view controllers, novel user interfaces, and more.

![image](https://github.com/user-attachments/assets/a785e608-2a5f-4cb7-80a2-542a7902c98a)

## Motivation

SwiftUI is great for building out interfaces and apps quickly, but at the expense of feeling very similar amongst one another – standard controls, list views, toggles get tiring just as quickly... and surface-level design, no matter how polished, can only get you so far.

In my opinion, what sets apart a good app from a great one (amongst other things) is the use of fluid, interactive transitions when navigating between screens or presenting modals and the like. Whether it's gesture-driven (e.g. pinching to expand or dismiss entries in [Dot](https://new.computer/)) or using a shared, interruptible model (e.g. going between a post and its detail view [Instagram](https://instagram.com)), such transitions really elevate the UX of an app.

Apart from that, novel user interfaces like the ones from [Path](https://brianlovin.com/app-dissection/path-ios) or [Mailbox](https://www.youtube.com/watch?v=FG-h8pDXfoE) also go a long way in making an app feel less box-standard than what's on the App Store nowadays. Transient pop-ups that sync with some state like scroll position, custom swipe actions whose buttons fan out in some elegant way... these add surprise and delight, and leave you wondering how they were made. Some might argue that these apps feel antiquated or less native-feeling as a result of these bespoke interfaces, but that was the beauty of apps in the pre-iOS 7 era, where each app could shine with their own personalities. We have much to learn from their "antiquated-ness".

This repo thus aims to study, replicate and build upon such transitions and interfaces, and serve as a reference for anyone who may be interested in learning and implementing these for themselves.

> [!NOTE]
> In particular, for custom view transitions, there are many parts that go into creating them (some boilerplate, some actual code), so I think the best way to learn and eventually implement them is to sit down and read through the documentation and [articles](#Resources) that exist on this topic, and to play around with example code. It might take a few days, or even weeks (as it will for me) to really understand the necessary protocols, delegates and methods that go into creating custom transitions, so I recommend being patient and working through them step by step.

## Overview

These are the main ingredients that go into implementing custom, interactive transitions:

- `UIViewControllerTransitioningDelegate`: tells the system that you want to supply custom transitions for view controller **presentations** and **dismissals** (like sheets, modals, etc.).
- `UINavigationControllerDelegate`: tells the system that you want to supply custom transitions for view controller **pushes** and **pops** (like going between a grid view and a detail view).
- `UIViewControllerAnimatedTransitioning`: think of this as an **animation controller**. During transitions, UIKit will call our animation controller with the necessary context, allowing us to execute our custom animations instead of the default ones.
- `UIViewControllerInteractiveTransitioning`: think of this as an **interactive animation controller**. If implemented alongside `UIViewControllerAnimatedTransitioning` and configured appropriately, this will enable interruptible transitions that work alongside the custom, non-interactive animations.
- `UIPercentDrivenInteractiveTransition`: an object that drives an interactive transition. This enables gesture-driven navigations like swiping to go back. The default implementation utilizes the existing custom transition defined in `UIViewControllerAnimatedTransitioning`.
- `UIViewControllerContextTransitioning`: passed as a parameter to the required methods of `UIViewControllerAnimatedTransitioning`, this context contains information about both the presenting and presented view controller, and (if extended and conformed to by our view controllers) can hold other information that is useful for our custom transitions.

## `UIViewControllerAnimatedTransitioning`

This is the main protocol in UIKit that allows you to create custom transitions between view controllers. In other words, it contains the logic for the animation (interactive or not) that occurs during the transition. It has two required methods to implement:

1. `transitionDuration(using:)` returns the duration of the entire transition animation
2. `animateTransition(using:)` is where you define the actual animation sequence(s) which will be executed during the transition

And both methods have a `transitionContext` parameter of type `UIViewControllerContextTransitioning` that is crucial as the system will be providing all the necessary components through this parameter to use for our custom transitions. 

This `transitionContext` object also contains a `containerView` that we will use to show whatever views we need to as the `from` view controller transitions to the `to` view controller. Think of it as the intermediary view. It starts off empty, and we can add any views we want, including the previously mentioned `to` and `from` views that already exist within the `transitionContext` object.

## `UINavigationControllerDelegate`

To use our concrete implementation of `UIViewControllerAnimatedTransitioning`, i.e. our animation controller, we will have our view controller(s) conform to `UINavigationControllerDelegate` and implement the following method:

1. `navigationController(_:from:to:)`, which will return an instance of our custom `UIViewControllerAnimatedTransitioning`

This tells UIKit that we want to use our custom transition animation instead of the default `push` and `pop` animations when navigating between view controllers.

Alternatively, we can have this animation controller (let's call it `TransitionAnimator`) be the one conforming to `UINavigationControllerDelegate`, which will have to implement the method above. Then, we set our view controller's delegate to `TransitionAnimator`. The following describes the pros and cons of these two approaches.

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

## Demos

This section provides light documentation of the demos implemented in the project, in terms of the techniques and approaches used.

### Facebook Paper transition demo

This demo/view serves as the main hub for all the other demos, and is what you see when you first open the app. It aims to replicate the expanding and shrinking transition of stories. A horizontally scrolling `UICollectionView` with a constrained height is used, and the cells contained within are all scaled down by `0.4` with respect to the device's screen size. 

During the transition, we map the destination view to the cell that was selected both in terms of size and position, and from there we animate the growth of both the cell and destination view in tandem to fill up the screen, also adjusting the `contentOffset` of the collection view as the transition progresses so that it aligns perfectly to the center of the screen.

For more details on how this is achieved, look at `FBPaperTransitionAnimationController.swift`, specifically the `pushAnimation()` and `popAnimation()` methods.

> [!NOTE]
> The current implementation leaves out the interactive drag gesture, which will be worked on in the near future.

### Instagram transition demo

This demo replicates the transition behavior when going from a post on a profile to the detailed post view, where the image appears to expand into the new screen. It utilizes a custom transition and transformations to pull off – please see the detailed comments in `CGAffineTransform+Extensions.swift` for more info on this, in particular the following methods:

```swift
static func transform(parent: CGRect,
                      suchThatChild child: CGRect,
                      matches targetRect: CGRect) -> Self { ... }
                      
static func transform(parent: CGRect,
                      suchThatChild child: CGRect,
                      aspectFills targetRect: CGRect) -> Self { ... }
```

Essentially, when the transition begins, we crop the destination view to match the image's frame in the grid using a mask, and position it atop the image in the grid. Then, as the transition progresses, the destination view appears to grow to take up the entire screen, via manipulation of the mask.

### [untitled] transition demo

It is crucial that the `sharedView` that both view controllers implement as part of the `SharedTransitioning` protocol are **copies** instead of references, since it becomes **much easier** to reason about and manipulate them for our custom transitions. Otherwise, we would have to involve convoluted logic to manage and restore states before, during and after the transition. With copies, we can easily create and destroy them on demand with little overhead. 

The only caveat is if the view is complex, this operation might take much longer. The alternative is to manipulate the source and destination views themselves using clever tricks like masks, as is the case with the Instagram transition demo.

### ModalCard demo

This demo demonstrates a three-stage modal that is inset from the edges of the screen, which is apparently very trendy nowadays (see: [Family](https://family.co)). It feature custom rubber-banding and drag gesture logic, allowing for fluid navigation between the different states without any jarring locking.

### Path demo

This demo replicates the [neat clock tooltip](https://littlebigdetails.com/post/15886779130/path-when-scrolling-in-the-app-the-clock) that appears on scroll in Path. The position of the tooltip is synced with the scrollbar via overriding various `UIScrollView` methods, and we convert the center point of the tooltip in its coordinate system to the coordinate system of the `UICollectionView` to determine which post the tooltip is currently intersecting with. Then, we can update the tooltip to show the correct date and time for that post.

### Twitter splash screen demo

This demo replicates the [Twitter logo animation](https://iosdevtips.co/post/88481653818/twitter-ios-app-bird-zoom-animation) when launching the app from a cold boot. It uses a simple masking technique and 2-stage animation sequence to pull off – the first stage shrinks the bird down slightly, before expanding to reveal the app's contents, which also has a subtle shrinking animation, in the second stage.

### Twitter swipe action demo

This demo replicates the [swipe gestures](https://x.com/X/status/1859757879613587698) that Twitter recently introduced, allowing users to perform quick actions when swiping from the left or right on a tweet.

For this to work, a pan gesture is attached to the collection view, and the cell that the user has their finger on when dragging is retrieved using the `indexPathForItem(at:)` and `cellForItem(at:)` methods. We perform a simple translation that follows the drag gesture on the focused cell, and also curve the corners and apply a drop shadow that gradually strengthens as the drag gesture progresses. Using the computed `indexPath` we can also retrieve the adjacent top and bottom cells to appropriately curve their corners. 

For the delete button, since it's purely cosmetic to indicate its action, we only need to add it as a single subview to the view rather than to each individual cell, and update the layout constraints upon dragging to make it appear as though it's attached to a particular cell. We also update the z-indices appropriately so that the layers make sense (dragging cell on top, close button in the middle, rest of collection view at the bottom).

## TODOs

### Facebook Paper transition demo

- [x] Implement Facebook Paper card transition
- [ ] Add interactive gesture to Facebook Paper cards
- [ ] Make into its own demo instead of the home view

### Instagram transition demo

- [x] Fix `index beyond bounds` error
- [ ] Make `pushAnimation()` interruptible (ref: [WWDC 2016: Advances in UIKit Animations and Transitions](https://devstreaming-cdn.apple.com/videos/wwdc/2016/216v55u6zpxizxkml6k/216/216_hd_advances_in_uikit_animations_and_transitions.mp4))
- [ ] Implement Instagram-like vertical scrolling experience on `PhotoDetailView`
- [ ] Support fetching remote images
- [x] If at the top of `scrollView`, activate pan gesture for starting transition

### [untitled] transition demo

- [x] Implement [untitled] album transition with slide over
- [x] Adjust curves on interactive transition

### Path demo

- [ ] Build out rest of Path interface (custom cell layouts, bouncy header, etc.)

### Other demos

- [x] Path timeline scroll
- [ ] Twitter side-bar half transition

### General

- [ ] Disallow multiple touch inputs during transitions
- [ ] Experiment with rubber banding individual cells in `UICollectionView`s
- [x] Swipe down/from left edge on demos to return to home view

## Resources

- [Custom view controller transitions](https://blorenzop.medium.com/custom-view-controllers-transitions-aa8c052f8049)
- [Replicating Instagram's shared transitions](https://medium.com/supercharges-mobile-product-guide/replicating-instagrams-shared-transition-on-ios-uikit-part-i-144a26c31353)
- [A complex push/pop animation](https://devsign.co/notes/navigation-transitions-iii)
- [View controller life cycle](https://medium.com/good-morning-swift/ios-view-controller-life-cycle-2a0f02e74ff5)
- [Spotify sheet transition](https://www.onswiftwings.com/posts/interactive-animations/)
- [Understanding `UIViewControllerAnimatedTransitioning`](https://medium.com/@cleanrun/trying-to-understand-uiviewcontrolleranimatedtransitioning-5abff56c5f93)
- [Wrap your head around custom view controller transitions](https://danielgauthier.me/2020/02/19/indie-4.html)
