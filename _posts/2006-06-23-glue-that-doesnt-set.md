---
layout: post
title: "Glue That Doesn't Set"
date: 2006-06-23
comments: true
tags: []
---

Back in the old days of computing—those days where I could still see
my knees when standing up—folks used to talk about languages such as
Perl as _glue languages_. What did they mean?


{%img1 right /img/glue.jpg %}

Well, Perl is a great general purpose programming language. But it is
exceptional at doing something that no previous language could do
well: Perl made it easy to glue together other _stuff_. Data,
programs, external systems—all these things could be integrated using
Perl. Thanks to its integration with the underlying operating system,
and its amazing support for text processing, Perl made a name for
itself as an integrator _par excellence_. Want to take the last 20
lines of an error log, convert them to HTML, and upload the result to
your web server? Perl could do that in a handful of lines of
code. Need to screen-scrape a book’s sales rank from Amazon and
writing it into a local MySQL database. Perl to the rescue.

Perl let us glue stuff together. It was magic.

But there was a problem. Perl is a great language. It was my scripting
language of choice before I discovered Ruby. But even on my most
charitable days I could never really claim that these Perl programs
were exemplars of readability. And, in turn, this lack of readability
made it hard for me to pick one of them up six months after I’d
written it and make some change—even small alterations could involve
long periods of head-scratching as I tried to work out exactly what
the entries in my hash of arrays of hash references actually
contained.

As a result, I found that the longer it was since I last looked at a
program, the harder it was to maintain and extend it. The programs
effectively became less malleable and more viscous. It became
stickier; I got mired in a gooey mess of details. Leave a program long
enough, and I’d often decide to rewrite it rather than attempt some
piece of surgery: the program had become totally inflexible.

The glue had set.

Now Ruby is also a glue language. Just like Perl, Ruby works and plays
incredibly well with external data, resources, and programs. I can do
everything with Ruby that I used to do with Perl—I can use it to
integrate all kinds of stuff just as easily as I used to be able to
with Perl. But, there’s a major difference. I’ve discovered that, over
time, my Ruby programs stay malleable and easy to change. **Ruby is
the glue that doesn’t set.**


### Glue and the Web


That’s all very well, but what does writing little utility scripts
have to do with real-world web programming? A whole lot, as it turns
out.

As we move into a world where the network is the computer,
applications change in character. Rather than writing free-standing
islands of code, developers are increasingly writing programs that
knit together other, existing web resources. Want to annotate a map
with pictures of famous landmarks? Maybe you’ll want to use the Google
Maps and Flikr APIs to carry most of the load for you. Want to let
your readers know when their product has shipped? Why not generate the
information as RSS and let their aggregator client do all the
gruntwork of displaying the result? As we move forward, more and more
of our applications will be less and less like one-man bands and more
like orchestra conductors.

Our applications are increasingly becoming glue code. And, if that’s
the case, I’d rather write them using a glue that doesn’t set over
time.

