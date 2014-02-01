---
layout: post
title: "The New LaTeX Companion"
date: 2004-08-03 19:00:00 -0600
comments: true
categories: []
---

I love the output produced by TeX, and I love the flexibility I get
typesetting from plain text input. However, TeX isn’t trivial. The new
edition of _The Latex Companion_ is a godsend.


I love type. Ever since I got into computers, back when high
resolution was a 132 column printer, I’ve tried to find ways to play
with typesetting and fonts. I wrote a basic layout system in OMSI
Pascal that drove daisywheel printers. I got to be quite an expert at
nroff and troff. I used to hunt (without success) for a free copy of
Scribe. I played with Lout, and a dozen other packages. But nothing,
ever, helds a candle to TeX when it comes to the quality of the output
it produces.


Ignore for the moment some of the uglier fonts than some TeX users
employ, and look instead at the pages. Hold them up at a distance and
admire the uniformity of the gray: no rivers of white to be seen. Look
at the bottoms of the page: if the typesetter didn’t totally goof off,
they’ll be vertically balanced: an open spread is the same height on
both pages (TeX’ll add tiny amounts of leading to make it happen). Dig
into the line-breaking, and you’ll find optimization algorithms, which
shuffle words back and forth trying to minimize the _badness_ of the
appearance.


The output of TeX gives me a lot of pleasure.


Unfortunately, the same cannot be said for its input. Don Knuth is
clearly a genius, but as with all wizards, his creations can be
tricky. In the case of TeX, we have a typesetting engine driven by a
macro processor whose interpretation of syntax can be changed while it
is in the middle of processing individual commands. Raw TeX is scary
to deal with, so people don’t deal with it. Instead, they use its
power to write macro packages, abstracting the low level commands into
something more palatable (and tractable). The most widely used of
these is Leslie Lamport’s LaTeX. LaTeX is at its heart a logical mark
up system, documented in an admirably short and lucid book, <a
href="http://www.amazon.com/exec/obidos/tg/detail/-/0201529831/ref=pd_sim_books_2/002-0998484-3621639?v=glance&s=books">LaTeX:
A Document Preparation System</a>.


But when you want to use LaTeX to do serious work, you need more than
this small book. When you want to set complex tables, or handle
floating material a certain way, or get your index looking just right,
you need the real scoop. And you turn to just one book.


The original _LaTeX Companion_ was one of those books that never got
returned to my bookshelf. I used it almost every day for 4 years
during the typesetting of five books. Thanks to its wealth of detail,
I was able to create press-ready files straight from my computer to
the exacting specification of the production departments of three
separate printers.


But now, the bible has been retired. Mittlebach and Goossens have
produced a second edition of <a
href="http://www.amazon.com/exec/obidos/tg/detail/-/0201362996/ref=pd_sim_books_5/002-0998484-3621639?v=glance&s=books">The
LaTeX Companion</a>, and it’s better in every possible way. In the ten
years since the first was published, a lot has changed, and the book
captures it all. New packages, improvements in encodings, font
handling, xindy: the book describes it all. My copy arrived a couple
of weeks before Mike Clark’s <a
href="http://www.pragmaticprogrammer.com/starter_kit/au/index.html">Automation</a> book
was due to go to the printers. I devoured it, and immediately used its
advice to improve the appearance of ragged-right text, fix up some
font issues in the code listings, and improve the handling of included
graphics. Since then, it’s been a true companion as I’ve worked with
the typesetting of the new edition of _Programming Ruby_.


I don’t often gush, but if you use LaTeX, or if you’d just like to
produce great looking typeset output, you owe it to yourself to get
this book.

