---
layout: post
title: "The Joy of Lego"
date: 2003-06-01
comments: true
tags: []
---

Martin Fowler has put up a link to an IEEE Software Design Column
article by Rebecca Parsons called Components and the World of Chaos
(<a
href="http://www.martinfowler.com/ieeeSoftware/componentChaos.pdf">pdf</a>).


In part, the paper argues that assembling large numbers of components
could potentially lead to behavior that would be hard to predict ahead
of time: the interaction of these simple components could lead to
complex (or _emergent_) behavior. Components could interact in ways
not foreseen by their original designers.


The paper suggests that this might be a bad thing: it would be hard to
predict the exact behavior of these component-based applications in
advance, and so they would be risky to deploy.


I can see that argument: even without worrying about the distribution
of heterogeneous, multi-vendor, high-level components, I know that
I’ve been bitten in the past by different parts of systems interacting
in ways that I hadn’t expected.


But at the same time, a part of me wonders if there isn’t some
potential magic to exploit here. Say we can find ways of specifying
the stuff we definitely _don’t_ want to happen, perhaps by specifying
business rules as invariants or mini-contracts, stuff such as “you
can’t sell something if it isn’t in stock,” and “you can’t refund more
that you were originally paid,” that kind of thing. These rules define
a kind of business baseline: something that the application must
do. We implement the rules at some kind of meta-level; some are
associated with individual components, and others, specified in the
component assembler/aggregator layer, apply to the component’s
interactions. They give us our safety net.


But we don’t try to box the application in totally. Instead, we wait
to see if other, potentially unexpected behaviors emerge. Our business
rules act as some form of guarantee that the new behavior won’t hurt
us, but they don’t prevent us from benefiting from any new and
valuable behavior that might pop up.


Can we really produce working systems where we don’t know all the ways
in which it will behave up-front? Just look at The Sims (or Lemmings,
for those feeling nostalgic). Look at the way folks are using
scripting languages to produce small component-like interfaces for
existing applications, and then using those interfaces to combine the
applications in unexpected ways. Clearly at some level we can. Right
now we can’t do the same kind of thing for business applications: we
don’t know enough about specification techniques to be able to plug
all (or even most of) the holes up-front. But in the next few years,
perhaps we will. And perhaps systems such as <a
href="http://www.nakedobjects.org/">Naked Objects</a> suggest how some
of lower-level building blocks might work.


All the truly interesting behavior is emergent (if for no other reason
that if we can predict it ahead of time, it really isn’t too
interesting when it happens). And this emergent behavior has an
amplifying effect on our productivity as developers: combine simple
things using elementary rules to produce a whole that has complex and
rich behavior. So I’d argue that having component-based architectures
produce systems with emergent properties is not a risk: it’s a
requirement. We’re just not there yet.

