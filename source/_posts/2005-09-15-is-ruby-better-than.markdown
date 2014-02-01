---
layout: post
title: "Is Ruby Better Than…?"
date: 2005-09-15 19:00:00 -0600
comments: true
categories: []
---

As I speak about Ruby with folks around the world, a question comes up
with depressing regularity: “is Ruby better than _Xyz_?”,
where _Xyz_ is the questioner’s current language du jour.


The simple answer is “no.”


But then let’s ask the same question differently. Is _Xyz_ better that
Ruby?


The simple answer is “no.”


The longer answer is that the question falls into the same category as
“have you stopped beating your wife?”—it makes an implicit and
(hopefully) incorrect assumption. In this case, it assumes that it’s
possible to compare two languages and come up with some kind of
binary _A trumps B_ evaluation.


Is your chisel better than my hammer? If I’m forming dovetail joints,
yes. If I’m nailing two-by-fours, no.


Is my Ruby better than your Java (or C#, or …)? It depends.


So, over the next few weeks I’ll try to post some answers. I’ll look
at areas of Ruby which seem to be hot buttons for folks when making
language comparisons.


Let’s start with a big one:

### Performance

Ruby is probably slower than Java or C# in most real-world
situations. Does that worry me? Not normally.


Think about your average web application. An incoming request appears
on an Ethernet interface. The packets make their way up through the IP
and TCP stacks, then get queued up as a data buffer. The web server
receives the data, decodes some of the content and passes it off to
your application server. There the information is massaged into some
kind of request object, and your application is invoked. Your code
hits the database a couple of times, probably using an OR mapping
layer such as Hibernate to sanitize the access. It then constructs
response data before calling some kind of templating library to format
a response. The response heads back through the application server,
and possibly through the web server, before being deconstructed into
packets and sent over the network.


Whew! There’s a bunch of processing going on there. Millions and
millions of machine instructions being executed. There’s latency while
packets are queued, processes are scheduled, threads are dispatched,
and disk heads seek to the right track.


How much of this processing is done in code that you write? How much
of the total time spend handling the request is spend executing the
actual instructions corresponding to your code?


Zip.


I’m guessing maybe 5% on a really bad day, with a complex
application. Let’s face it: you average commercial application isn’t
burning CPU cycles solving NP-complete problems. We typically write
code that moves chunks of data about and adds up a couple of numbers.


In these scenarios, is it worth worrying about the relative
performance of the language used to do the moving and adding? Not in
my book.


Instead, I’d rather write in a language that let’s me focus on the
application, and which lets me express myself clearly and
effectively. And, if I can do those two things, I believe that
sometimes I’ll be able to write code which is cleverer than something
I’d write in a lower-level language. A better algorithm will easily
gain back any marginal performance hit I take for using a slower
language.


Justin Ghetland experienced this recently on a Rails project. Having
coded the same application twice, once in Java and once using Ruby on
Rails, he was surprised to <a
href="http://www.relevancellc.com/blogs/?p=31">discover</a> that the
Rails application outperformed the Java one. Why? Justin believes it’s
because Rails does smarter caching. The Rails framework contains some
very high-level abstractions, and that allows the folks writing the
framework to be smart about what they do. They accepted the linear hit
of writing in a language that executes more slowly because they got a
non-linear increase in speed from being able to write better code.


Clearly there’ll be times where you need to squeeze the most out of
your CPU, where your application itself is the bottleneck and it’s CPU
bound. In these cases, Ruby might be a bad choice. You probably want
to look at a high-performance language such as OCAML. But even then,
the choice isn’t always clear. Ruby with a good parallizing matrix
library would probably beat Java or C# code which inlines the same
operations.


So, is Ruby fast enough for _your_ application?


I don’t know. But I do know that I wouldn’t assume that I can’t use
Ruby for performance reasons. There are plenty of sites out there
pumping high transaction volumes through a Ruby application. The real
answer, as always, is _it depends_. If you’re concerned about
performance as you start to develop a new application, it doesn’t
matter if you’re writing Ruby, Java, C#, or assembler. It’s prudent to
spend a small amount of time doing some rough tests on your proposed
architecture before you start laying down the code.

