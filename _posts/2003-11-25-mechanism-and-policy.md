---
layout: post
title: "Mechanism and Policy"
date: 2003-11-25
comments: true
tags: []
---

What can we do about the tradeoff between flexibility and convenience
in interface design? Do users want us to provide just the means to get
the job done (the mechanism), or do they want to be told _how _to do
that job (the policy)?


I’ve been reading Eric Raymond’s “The Art of Unix Programming” (a good
book that could have been great had he managed to find a more balanced
voice). In the section on user interfaces, he reminds his readers of
the decision of the designers of the X windowing system not to impose
look-and-feel constraints on X applications. The designers say that X
supports “mechanism, not policy.”


The X windowing system provides the underlying graphical user
interface for most Unix systems (the Mac is a notable exception, as
we’ll see). Perhaps surprisingly, X itself offers almost no user-level
features. Instead, it concentrates on providing a set of low-level
primitives for drawing windows and filling those windows with graphics
and text.


In order to make X usable, you need to supply an application program
called a “window manager.” This hooks in to X and handles events: for
example, X may create a window, but the window manager can decide
where to place it on the screen. To fill windows with widgets
(standard interface components) you need another layer of software,
the various X toolkits.


The designers of X felt that building a lot of behavior and standard
interaction models into X would limit the user of X. Instead, they
provided a (fairly low-level) API, and allowed their users to build
any style of interface they wanted. They provide the _mechanism,_ but
enforce no policies on how that mechanism is used.


By contrast, the windowing systems from Microsoft and Apple (as well
as those from Be and NeXT) were rich in policy. The windowing systems
imposed a number of look-and-feel constraints and behavioral
similarities between applications. There were even documents for
application designers dictating just_how_ their applications should
look and react.

So what are the tradeoffs? Raymond says:

> _The difference in approach _[between X and Mac/Windows]_ ensured that
> X would have a long-run evolutionary advantage by remaining adaptable
> as new discoveries were made about human factors in interface
> design—but it also ensured that the X world would be divided by
> multiple toolkits, a profusion of window managers, and many
> experiments in look and feel._

Ignoring the interesting spin on “evolutionary advantage” (I don’t
often see X applications edging out Windows and Mac ones on my
client’s desktops), the point is a good one. By keeping the underlying
framework free of particular implementation decisions, you make it
more flexible. This flexibility is a two-edged sword. One the one
hand, it allows multiple competing ideas to duke it out: the winners
will be selected by their users, and not just by developers (perhaps
this is what he meant by evolution). But on the other hand, it also
leads to the fragmentation he describes.

But he’s also being disingenuous here: the reality is that it isn’t
the X windowing system itself that’s adapting at all. Instead, it’s
the efforts of hundreds of people writing the stuff on top of X that
has provided the ongoing evolving interfaces he describes. Underneath
the covers, X is basically the same old X. In some way, you could say
that all their efforts were expended making up for stuff that X didn’t
provide itself.

So, by providing policy, the designers of Windows and Mac interfaces
have provided their end-users with a consistent look and feel, and a
base set of application behaviors. By instead focusing on mechanism
and ignoring policy, the designers of X allowed developers to
experiment, but gave the users of X applications a very inconsistent
interface experience. Arguing one approach is better than the other is
pretty pointless: they’re just different.

What can we learn here when it comes to applications and designs?

When I first started thinking about this, I was reminded of the
audience discussions that sometimes erupt when I talk about <a
href="http://www.nakedobjects.org/">Naked Objects</a>. A Naked Objects
application exposes the core business objects of an application
directly to the end user. They can manipulate these in any way the
objects allow: there is no overall application GUI imposing a certain
way of doing things. A Naked Objects system provides mechanism, but
little in the way of policy. When I describe this, some folks have a
strong reaction against the idea. “Without high-level policy imposed
by the GUI (scripting, or series of modal dialogs that have to be
filled in in a proscribed order) how can we ensure our users do
everything that needs to be done?” they ask. And its a good
question. Experienced users, folks who understand the domain, love
Naked Object systems because they get the control and flexibility they
need to get the job done. But inexperienced users can be confounded by
that same flexibility—”what should I do now?”. (In a way, this also
relates back to the Dreyfus model of skills acquisition: beginners
need to be guided, while experts need to be left alone to get on with
their jobs.)

In the Naked Objects world, it turns out that there’s a
compromise. Because the Naked Objects are themselves just Java
business objects, there’s nothing stopping you putting a more
conventional view and controller on top of them, converting your Naked
Objects application into a conventional GUI or Struts-style app. And,
because the objects are the same beneath the covers, you could
probably arrange to run both the Naked Objects and conventional
application at the same time. The conventional application would have
less flexibility and functionality, but would be easier for casual
users. The Naked Objects system would have full flexibility for more
experienced users.

In a way, this seems like the OSX way of doing things. Apple have
taking a Unix operating system and wrapped it with a fantastic user
interface. Not only does this interface work at the application level,
but it also gives you the ability to do most of the administration of
a box without dropping to the command line or editing files. I love
this: I’ve spent all too many years administering Unix boxes the hard
way. But what I love just as much is that when I need to, I can still
get down and dirty. It’s the best of both worlds: regular users get a
great, easy-to-use interface, but power users get to strip away the
facade and work down at the lower levels.

Increasingly, I think the “one-size-fits-all” mentality is going to
break down. We need to think about delivering our application
functionality using multiple modalities, each targeted at specific
user communities. Mechanism _versus_ policy is one axis we need to
consider, and one that’s relatively easily addressed in a
well-designed application. We don’t need to decide up front whether to
deliver one or the other; instead we need to work out how to provide
both.

