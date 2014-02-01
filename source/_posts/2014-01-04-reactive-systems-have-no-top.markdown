---
layout: post
title: "Reactive systems have no top"
date: 2014-01-04 19:08:00 -0600
comments: true
categories: []
---

Back when I used to consult into projects in trouble, there was a trick that always worked, Look for classes or modules named `XxxManager`. These puppies would always be at the epicenter of the structural spaghetti. Invariably they’d be doing too much, with lots of conditional code and a fair amount of poking into the business of the things they were supposed to be managing.


So we’d pick them apart, split out functionality, and see if there was a way to either eliminate them, or turn them into something less coupled (my favorite approach when appropriate would be to turn each into a state machine).


But, as they say, the cobbler’s children have no shoes. I fell into the trap myself this week.


Over the Christmas break, I’ve been amusing myself by writing a terminal emulator in Coffeescript. Part of the intent is to allow me to record and then play back interactive sessions. The playback will have a bunch of bells and whistles (including fast forward, rewind, step-by-step and so on).




<img src="https://31.media.tumblr.com/c3dfec2870757b0cbbb66e70d2f05d86/tumblr_inline_mywwumUvgn1rgo2z9.png"/>




To manage all this (yes, there’s that word) I wrote a class called `Driver.`


Perhaps it was the eggnog, but the usual alarm bells were muted. I happily coded away for half a day, hacking more and more stuff into the driver. We had events, callbacks, a little RxJS, and lots of asking other objects for status.


And it bogged down. Every change got more difficult. Every test harder to write. And it wasn’t fun.


So I took the dog for a walk, and the dog told me I was being stupid. I’d written a manager class. It wasn’t called `PlaybackManager`—that would have been a giveaway. I’d called it `Driver`. That kind of pathetically meaningless name should also have been a giveaway, but until the dog pointed it out, I’d kinda spaced it out.


So I got back, gave the dog a treat, rolled back the code to the start of day, and looked for a good name for a class that would drive the playback. I ended up with `VcrControls`. What did it control? A class called `Player`. The `Player` class had methods such as `play()`, `rewind()`, and `step()`. The `VcrControls` object sat between the UI and the player. And the code just fell into place.


In a way, this is a variant of the “tell, don’t ask” rule. 


Reactive systems have no top—they are lots of components that transform data and events. There’s no place for anything called a manager in such a system. And careful naming (cf `Driver`…) is a quick way of working out when you break the rule.

