---
title:  Testing Private Functions
layout: post
tag:    programming
---

A couple of days ago, I published
a [trivial little Elixir library](https://hex.pm/packages/private)
that temporarily overrides the `private` status of functions while
running tests.

I thought it was useful. I tend to decompose my work into lots of
functions, and try to publicly expose only those that I want to be
part of a module or class's API. But I often want to test some
particular aspect of the nonpublic functions. To do that, I've had to
set up a suitable environment for the public APIs to ensure my private
function gets called the way I want it to be called, and then work out
how to tell from the public API whether it worked. This is indirect
and laborious, so much so that I often just gave in and made the
internal functions public.

In Ruby, there are cheats that let you invoke private methods. In
Elixir, there aren't. Hence my little library. It that changes the
visibility of functions if they are being compiled for the purpose of
running tests.

So far so good. I'm personally using this library every day, and my
code seems clearer because of it.

But then I started getting comments. Not many, but they all seemed to
share the same misconception. "You can't test a private function!
That's an implementation detail. You can only test the public API."

I think this is a common belief. Let me explain why I feel it is
wrong.

{% image keep_out.jpg class:img-fluid %}
<div style="margin-top: -1.8em; margin-bottom: 1.8em; text-align: right; font-size: 60%; color: #aaa">
  DimitryB via <a
  href="https://www.flickr.com/photos/dimitryb/2280688545/in/photolist-4tx8fi-6L8CS7-7VTJSs-6EPhxA-6LEHD7-8NZ7RT-ndsW2-bJFW3-48wVFF-a7BJni-64uShN-49S72Z-a8WRPg-47n3as-48HTde-53ryB-dRXinh-o8zwPT-fHtHaP-8jw9Da-6KVZoZ-7MtWt3-owVaNf-5sPCe-T8rQSR-dCktbn-q7Mhfe-d56mS3-7DGs9E-8GQmsA-2D2sP-bkcH1D-dckmub-c6vSLS-ueTK-dUappy-7YquPv-5zjHF3-5gpHg8-5TYnwx-65uMcs-9nMoJo-r6SVPi-nKMfpx-naCBq3-8JS7R7-atwQai-dLoRCZ-aAsmFJ-paRyfq">Flickr</a>.
<a href="https://creativecommons.org/licenses/by-nc-nd/2.0/">[CC
BY-NC-ND 2.0]</a>
</div>

### What is a private function?

A private function (or method) is one that can only be called from
inside the module (or class) that defines it. It is invisible as far
as the rest of the code is concerned.

### Why do we need them?

A module is a collection of functions that share a common purpose:
working out sales tax, interfacing to Twitter, creating a chord
progression, and so on. The rest of the code in an application calls
functions in a module when it needs that module's expertise. For
example, a Twitter module will have functions to send a tweet, read a
tweet, and maybe subscribe to a timeline. The functions that do this
are part of the modules external interface—it's API.

The API functions are public. They are exposed to the rest of the app.

But an API function could be doing a complex job. So we would want to
split it up into a number of subfunctions. These will typically
be written in the same module. You can think of them as the
_implementation_ of the API.

Logically, they're just functions. We can define them just as we
define the API functions. But there's a problem. Other people may read
our code and see that, as well as the "official" API, we expose all
these helper functions. And maybe one or two of these might be useful
in their code. So they call them.

### So what if someone calls my helper functions?

Imagine it's a month later, and you realize that you could improve the
implementation of the module you wrote. You get stuck in, rip out
half the code and replace it with new stuff.

Now, you don't want to change your API—other people depend on that.
But you feel totally free to change any of the helpers. After all,
they're just there to implement the API. After to finish hacking, you
make sure your API passes its tests, and publish your masterpiece.

Thirty seconds later the emails start arriving: "You broke my code."
People who (wrongly) relied on the internal implementation of your
module suddenly found that the functions they use had disappeared, or
had changed.

Their code was coupled to the internal implementation of yours.

{% image tangled_seaweed.jpg class:img-fluid %}
<div style="margin-top: -1.8em; margin-bottom: 1.8em; text-align: right; font-size: 60%; color: #aaa">
  Quinn Dombrowski via <a
  href="https://www.flickr.com/photos/quinnanya/8107666487/in/photolist-dmrUMe-aF9aeJ-beLziP-awTTg8-775i8F-68abaa-89piSh-6RfcLj-4UC2WQ-4W1PAr-4WFtU8-oLGsn6-earqXh-967mST-ag6cPs-raLuUF-jrTkcC-eZ1j2M-pL6Xm6-bxvZHJ-n1djpi-mSyztT-pSbUAw-dYqzJA-5FfvNE-qTcB2S-6mdNs3-7GNxSu-eYUeB7-pprXQD-qCeJgX-FYzxd-mSyzoH-74Su1a-nM8P82-6m9NcF-qqYQ7x-r3BzZr-7dofqo-mV2bkH-8fjdvM-2GT51M-pXunTq-eDz3Ka-9aosCG-pou8MW-qDoitK-4eTT39-gGY36W-oUCrLq">Flickr</a>.
<a href="https://creativecommons.org/licenses/by-sa/2.0/">[CC
BY-SA 2.0]</a>
</div>

### Why is coupling bad?

To my mind, there is only one rule when it comes to designing
software:

> Given the choice between two alternatives, choose the one
> that makes future change easier

Most of the principles of good design are just
someone's idea of how to codify some aspect of this.

Avoiding unnecessary coupling is one of those principles. 

If thing Y depends on thing Z, then changes to thing Z affect thing Y.
Even worse, if X depends on Y, then a change to Z might force a change
to Y which then breaks X. And, to make it a total disaster,
dependencies aren't nice and linear like this. Instead, they form a
complex mesh. In a bad (typical?) code base, these dependency chains
can often interconnect the majority of the code.

The problem is that a change to any module in such a system has the
potential to ripple through to every other part of the system. Change
the calling sequence of a function, and potentially dozens of other
modules will need to change, too. This is the software equivalent to
the butterfly flapping its wings in Tokyo. It's chaos. And it makes it
hard (and stressful) to change code.

### What's this got to do with private functions?

Every time you code a call from module A to a function in module B,
you set up a dependency between them. A becomes coupled to B.

That's not a bad thing. The whole reason you write code is to have it
be called. But you try to arrange things so that when you write a
module you provide a public API, which you expect people to call, and
a private implementation, which is none of their business.

In the old days, this was never actually enforced. You wrote comments
saying `one()`, `two()`, and `three()` are the public API, and you'd
have some kind of banner comment saying 

~~~ c
/**************************************************/
/*  The low-level implementation follows...       */
/**************************************************/
~~~

Then language designers wised up, and added visibility modifiers. You
could declare that the functions that formed your module's API were
publicly available, and the rest were private. Now you were free to
change the internals, safe in the knowledge that, as long as you
didn't change the API, nothing would break as a result of your
refactoring.

### What's this got to do with testing?

Nothing.

And that's the point.

If I feel the need to test a piece of code, I want to isolate that
code as much as I can. This lets my tests focus on just the thing
they're testing. Sure, I want to test my APIs. But I also want to
isolate and test pieces of the implementation, too.

### Doesn't that mean your tests may fail if you change the implementation?

Of course.

### But then you can't refactor

Says who? Seriously.

Refactoring encourages you to change the implementation without
changing the API. It suggestions using tests to verify this. Those
tests shouldn't fail at the end of each step of refactoring. But they
may well fail _during_ the refactoring.

So if _they_ can fail, then so can the tests that I write on my private
implementation functions. The only difference is that the API tests
act as proxies for the rest of the application. You shouldn't change
them—the same tests should run identically against the pre- and
post-refactored code.

The tests of the implementation are volatile. If you break them, it
could be because they are now testing the wrong thing. It's perfectly
OK to change these to reflect the changes to the implementation.

### The point?

* It's good to decompose complex functions into smaller ones. Ideally
  each function has just one responsibility.

* It's good to differentiate the stuff that shouldn't change (your
  public interface) from the stuff that may change (your internal
  implementation). Making the implementation private makes this
  easier.
  
* You should test code at both the API level and at the granular
  level. Visibility modifiers make the latter nearly impossible. Hence
  the Private library.
  


