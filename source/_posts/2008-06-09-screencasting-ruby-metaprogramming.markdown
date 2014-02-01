---
layout: post
title: "Screencasting Ruby Metaprogramming"
date: 2008-06-09 19:00:00 -0600
comments: true
categories: []
---



<img src="https://31.media.tumblr.com/0ecf630b57780b0fe64911fa56e9fb5b/tumblr_inline_my1a0jNm3X1rgo2z9.jpg"/>





I’ve been teaching Ruby (and in particularly, metaprogramming Ruby) for almost 7 years now. And, in that time, I’ve gradually found ways of cutting through all the confusing stuff to the actual essentials. And when you do that, suddenly things get a lot simpler. I’ve always know that Ruby didn’t really have class methods and singleton methods, for example, but until recently I didn’t have a simple way to explain that.


Then, when preparing to give an <a href="http://pragmaticstudio.com/ruby">Advanced Ruby Studio</a>, my thinking crystalized. Metaprogramming in Ruby becomes simple to explain if you focus on four things:

Objects, not classes.
There is only one kind of method call in Ruby. The “right-then-up” rule covers everything.
Understanding that `self` can only be changed by a method call with a receiver or by a class or module definition makes it easy to keep track of what’s going on when metaprogramming.
Knowing that Ruby keeps an internal concept of “the current class” which is where `def` defines its methods. Knowing what changes this makes it easier to know what’s going on.

I tried this approach in a number of Studios, and refined it during some talks for RubyFools in Copenhagen and Oslo.


So Mike Clark, who’s producing our new series of <a href="http://pragmatic.tv/">screencasts</a>, started pushing me to put this description into video. Last week I finally cleared the decks enough to record the <a href="http://pragprog.com/screencasts/v-dtrubyom/the-ruby-object-model-and-metaprogramming">first three episodes</a>.


First, I have to say it was a blast. I’d never recorded this many minutes of screencast before, and I was blown away by the amount of time it takes. I was also surprised at the level of detail involved, from microphone setup (which I messed up for a couple of segments) to color matching between codecs, it was fun to learn a whole new set of technologies.


I was also surprised at how hard it was to talk to a microphone. When we write books, we always try to write as if the reader was sitting there next to us. I tried to to the same approach with the screencasts, but it takes a whole new set of skills…


What I really liked was the way that I could live code examples to illustrate points. The first episode has maybe 50/50 code and exposition, and the second and third episodes are mostly code. And the code acts as a great skeleton on which to hang the concepts. Apple-R also keeps me honest.


So, if you’re interested in how the Ruby object model really works, and want to improve your metaprogramming chops, why not <a href="http://pragprog.com/screencasts/v-dtrubyom/the-ruby-object-model-and-metaprogramming">check them out</a>?

