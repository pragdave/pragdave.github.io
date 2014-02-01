---
layout: post
title: "Weeding out Bugs"
date: 2004-08-11 19:00:00 -0600
comments: true
categories: [ "programming", "debugging"]
---

If programming is like gardening, then weeding has much to teach us
about debugging.


After an exhausting couple of weeks doing book layout, I decided to
tale a break and do some therapeutic gardening. Not that I had to,
mind you—it’s only been a year since I last weeded.


The area between the side of our house and the fence was solid weeds,
an impenetrable bed of evil. This being Texas, we’re not just talking
dandelions. There were weeds that grow 12 foot long vines with small,
sharp thorns. There are weeds whose leaves make my arms break out in
blisters. There are weeds with petite leaves and stems whose roots go
half-way to China.


For a while (while I had the energy) I went into “random ripping”
mode, pulling at any bit of greenery that came to hand (and that
didn’t bite back). After half a hour, the weed bed looked no different
to when I first came down.


I realized that I was missing the point of the exercise. Pulling weeds
is about removing the plants, not about moving leaves. I needed to see
the plants so that I could attack them. I took my trusty hedge trimmer
and cut off a couple of square feet of the tops of the weeds. I was
left looking at perhaps 10 or 20 stalks on bare earth. A job that had
seemed intractable from the outside was now reduced to pulling up
those stalks—a couple of minutes later, it was done.


Now that I had a bare patch to work with, I stopped and had a look at
the rest of the weeds. Because I could now seem them in profile, I
noticed things I hadn’t before. A large part of the mass of leaves
didn’t actually have roots immediately below—they were vines that had
spread over the whole area. I pulled at them, and soon had a ball of
material three feet across, all originating from just four
plants. Four quick pulls, and they were gone. And, once gone, I could
see even more structure in the weeds that were left. There were some
obvious bush-like weeds: a few more tugs, and they were
toast. Suddenly I was starting to see bare earth. Most of the area
yielded to this kind of attack: find things you can identify, deal
with them, and you can start t identify more things. Every now and
then I brought in the hedge trimmer, but I found I needed it less and
less—it was less effort to analyze, attack, and re-analyze.


What’s this got to do with programming? Well, Andy and I have long
held (to some derision) that programming is much like gardening. In <a
href="http://www.pragmaticprogrammer.com/ppbook/index.shtml">The
Pragmatic Programmer</a>, we said:


{%blockquote%}
Rather than construction, software is more like _gardening_—it is
more organic than concrete. You plant many things in a garden
according to an initial plan and conditions. Some thrive, others are
destined to end up as compost. You may move plantings relative to each
other to take advantage of the interplay of light and shadow, wind and
rain. Overgrown plants get split or pruned, and colors that clash may
get moved to more aesthetically pleasing locations. You pull weeds,
and you fertilize plantings that are in need of some extra help. You
constantly monitor the health of the garden, and make adjustments (to
the soil, the plants, the layout) as needed.
{%endblockquote%}


And if programming is gardening, then debugging is weeding. And the
same lessons I learned when pulling weeds applies when eliminating
bugs.


First, randomly hacking at the symptoms doesn’t help. Patching around the effects of a bug just makes the code worse. The real point of the exercise is to find and remove the underlying cause. Pull plants, not leaves.


Second, it’s very hard to work with systems that contain many bugs at the same time. They interact and confuse things. When you look at the symptoms, you see the tangled leave cover, not the underlying plants. It’s often impossible to know how many underlying bugs/plants there are. So, cut through the cover and attack the underlying plants directly. We don’t yet have programming hedge trimmers, but we have techniques that strip away leaves just as effectively. The trick is to stop looking at a buggy system as a whole—stop looking at the exposed symptoms as being the actual bugs. Instead look at the system as a series of components, some of which contain bugs. Ignore, for now, the user-level issues, and ask instead if there are ways of deciding quickly if an individual component might be the cause. Brainstorm scenarios with your team: “Well, if the tax module _did_ generate a negative payment due, I guess that could cause the check printing module to crash the way we’re seeing.” The rule in these brainstorming sessions is simple: no one is allowed to say “but that can’t happen.”


Other ways to look at components in isolation include log file analysis and spot testing. I’m a big believer in log files. And if they have a standard format and are in plain text, I can apply all my scripting tool arsenal to them, looking for patterns, unbalanced things that should have occurred in pairs, strange timings, and so on. Once an anomaly is found, the responsible component is normally obvious.


My last technique for isolating components is to do spot testing. I’ll trust my intuition to guide me to areas when bugs might lurk, and I’ll write some unit tests. Surprisingly, I often find I don’t even have to run those tests. The act of concentrating on some code to test it often throws the bugs into some kind of contrast: “let’s see what happens when a refund is due. How can I test this? Oh, I see, I could call this method, with invokes the payment module, and… that can’t be right…”


My final lesson from weeding is that each weed has its own structure. Once I’d recognized that the vines were there, I could pull them all up at once. A good half of the visible leaves were attributable to just four plants. The bush-like weeds were easily pulled up once I’d found their stems.


It’s the same with bugs. Often a single, trivial bug can spread its effect through an entire system, making if look as if the whole program is wrong. If you look for the structure in the symptoms, though, you’ll quickly be able to find the root cause.


And the last lesson from weeding that applies to programming: I wouldn’t have to have done any serious weeding if I’d just bothered to go out every couple of weeks and pull up the small weeds as they appeared. With code, the analogy is obvious. Decent unit tests, written as you code, will help stop bugs from spreading. Catch them before they’ve had a chance to grow, and they’re easy to deal with.

