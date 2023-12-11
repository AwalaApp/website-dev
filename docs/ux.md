---
title: UX Design
permalink: /ux
nav_order: 1
---

# User Experience in Awala apps

Awala itself doesn't constrain the look and feel of compatible apps, but you'll have to unlearn common UX patterns when you design for people who may be disconnected from the Internet for a long time: The user being offline is the rule, not the exception.

The rest of the document is divided into two sections: Delay-tolerant UX agnostic of Awala, and Awala-specific considerations.

## Awala-agnostic considerations

[Designing Offline-First Web Apps](https://alistapart.com/article/offline-first/) by Alex Feyerke is a good starting point for the kind of things you ought to consider. However, you should keep in mind that there are two key elements of the offline-first movement are unlikely to apply to your app:

- Offline-first advocates are primarily concerned with web applications.
- Offline-first assumes that the user is briefly disconnected from the Internet, but Awala is meant to support extreme cases where there's no end in sight for when the Internet will be restored.

You should also consider that if your user is disconnected from the Internet, they may be under excessive stress as a consequence of the circumstances they're dealing with in their region.

Sadly, there's not enough literature on how to approach UX in these scenarios, but [we're keen to work with others to improve this](https://github.com/relaycorp/relayverse/issues/26).

## Awala-specific considerations

### Awala may not be installed or ready

Your UX should handle the following scenarios:

- Awala isn't installed. You should offer the option to install Awala. On Android, for example, you could open the Awala app listing on the Google Play app.
- Awala is installed but not ready. You should open the option to open the Awala app, so the user can see what's happening and if they need to do anything,
- Awala is installed but your app failed to communicate with it. In this case, there's nothing the user can do, but your app should internally share the error with your team.

## Remind the user that your app requires Awala

As of this writing, if the user uninstalls Awala or clears its data, your app will stop receiving data, so it's important to remind them that they need to keep Awala installed.

You could do this on the splash and/or about screens of your app, for example. You're also welcome to use the following image if you wish:

!["Powered by Awala" logo](assets/images/powered-by-awala.png)

The image is also available in [SVG](assets/images/powered-by-awala.svg).
