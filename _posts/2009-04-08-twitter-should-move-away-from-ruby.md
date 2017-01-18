---
layout: post
title: "Twitter Should Move Away from Ruby"
date: 2009-04-08
comments: true
tags: []
---

Oh dear. The chattering classes are at it, talking about how the
Twitter folks are dissing Ruby by announcing the replacement of some
Ruby code with Scala code.

Please stop.

At the kinds of volumes that Twitter handles (and with what I assume
is a somewhat scary growth curve), Twitter needs  to improve
concurrency—it needs an environment/language with low memory overhead,
incredible performance, and super-efficient threading. I don’t know if
Scala fits that particular bill, but I know that current Ruby
implementations don’t. It isn’t what Ruby’s intended to be. So the
move away is just sound thinking. (I suspect it also took some
courage.) I applaud Alex and the team for this.


Instead of defending Ruby when it’s clearly not an appropriate
solution, let’s think about things the other way around.


The good folks at Twitter started off with Ruby because they wanted to
get something running quickly, and they wanted to experiment. And Ruby
gave them that. And, what’s more, Ruby saw them through at least two
rounds of _phenomenal_ growth. Could they have done it in another
language? Sure. But I suspect Ruby, despite the occasional headache,
helped them get where they are now.


And now they’ve reached the status of world-wide wunderkind, it’s time
to move on.


I for one wish them luck. I look forward to the day when our online
store reaches the kind of size where we have to move away from
Rails. I’ll tweet the fact with a tear in my eye, while my yacht sails
me off to the sunset.

