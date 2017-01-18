---
layout: post
title: "SYWTWAB 6: Wrandom Writing Wrules"
date: 2007-03-12
comments: true
tags: [writing-a-book]
---

{%img1 right /img/penknife.jpg %}

This is the sixth of a series of personal notes to people who may be thinking of writing (or who have embarked upon writing) a book. You’ll be able to find them all (eventually) by selecting the tag <a href="http://pragdave.pragprog.com/pragdave/writing_a_book/index.html">Writing A Book</a>. In no particular order:


### Work Where it Works

_Writing is difficult._ Part of the trick of writing is to be able to
focus on the writing itself—there’s no point making things harder than
they already are. So choose your writing environment carefully, and
defend it when necessary.

So just what is a good writing environment? You tell me—everyones’ is
different. Some folks I know go down the local coffee shop and blitz
out chapters. Other people go to the park. Some write in bed while
waiting to go to sleep.

I personally look for an environment where I know I won’t be
disturbed. It isn’t good enough that I don’t get disturbed—I have to
know that the interruptions aren’t going to happen. Without that, part
of my brain is constantly scanning the background, waiting for the
e-mail _ping_ or the IM window to pop open. So, when I sit down for a
writing session, I kill off all my network applications. I put the
phone on DND, and I close the door. The risk of being disturbed drops
and my productivity rises.

For this same reason I find I’m really productive is on airplanes: I
stick the <a href="http://www.etymotic.com/">earphones</a> in and I
can churn out page after page.

It really doesn’t matter what environment works for you. Experiment
until you find one, and then use it.


### Stay Out of Lay Out

Many authors claim that they want to see the final format of the book
as they write it. I don’t agree. Remember the underlying
axiom: _writing is difficult_. Why make it doubly so by simultaneously
worrying about form and content?

Assuming you’re using a decent tool for creating your book, you’ll be
using logical markup. You won’t be saying “set this word in Courier.”
Instead, you’ll use markup to say “this word represents a variable
name.” If that’s the case layout is simply a matter of associating
sectioning and character markup with the appropriate layout
elements. You book can change appearance many times without changing
anything in the content. With this kind of system, your job is to use
the correct markup as you enter content. This lets a designer work on
the layout in parallel. It’s just another case of separating concerns
to make life easier.

### A Time to Write

In some ways, writing a book is like going to the gym. It’s hard work
and it feels better when it’s over.

To help us go to the gym, most people have some kind of schedule: they
go before work, Mondays, Wednesdays, and Fridays; or they go whenever
American Idol is on (the latter folks are fit.) Having a schedule
means that you feel an obligation to go. It also means you tend not to
schedule other things at the same time, which gives you one less
excuse to skip a session.

Do the same with your writing. Pick a schedule for writing and stick
to it. Some folks like to set their alarm clocks a couple of hours
early and write before the rest of their house gets up. Some folks
write after everyone else goes to bed. Or you can write on Sunday
afternoons and Wednesday mornings. The key things are to (a) agree a
schedule with those around you, (b) make sure it is practical to use
your ideal writing environment during those times, and (c) to use
those times to get some writing down. An entry in a diary doesn’t get
you fitter; time spent exercising does.

### End at the Beginning

One of the biggest mistakes new writers make is to start their book by
entering “Chapter 1: Introduction” into their editor. No one really
knows what their book will contain when they start out, so writing an
introduction to it is really pretty futile. Make life easy for
yourself and write the introduction last.

So, where should you start? Assuming you’ve already written the
throw-away prose while [finding your
voice](/blog/2007/03/11/sywtwab-5-finding-your-voice/), I think you’re
best off choosing a chapter where you feel at home with the
material. Belt it out, and then move on to something else fairly
straightforward. Make sure you have the voice business nailed
cold. Show what you’re written to some friends. Get into the swing.


Then change gears. You’ve mastered the writing part. Now look at the
content. Is there some area where you don’t feel so confident, or
where you need to do some research? Now’s the time to get that out of
the way. Tackle the difficult stuff while you’re still relatively
fresh. You’ll find it easier to do now than later. And, more
importantly, you won’t have it hanging over you while you
write. Getting the difficult stuff down also gives others longer to
review it.


### Cut and Paste is Your Friend

No one gets it totally right when they plan a large project. You
always discover things that you thought went here, but that work
better over there. So don’t get overly protective of your outline.

As you gain experience with your book, take every opportunity to look
at your content and ask whether it is flowing the way you’d like. Cut
out text that doesn’t fit. If you know where it belongs, paste it into
the new chapter. But don’t try to put it in exactly the right
place. Instead, paste it at the very top of the chapter and flag it
somehow. Then get on with writing what you were writing
originally—don’t break your flow. Then, at some point in the future,
you can go back and knit the orphaned piece of text into its new home.

I keep a special dummy chapter available for snippets that don’t seem
to have a home. As the book developer, I periodically look to see if
any of these snippets might add value to any existing content, moving
them into place if they do. I’m not particularly sad if I finish a
book and find the bucket still has stuff in it: books are ruined by
authors trying to add every single idea they have to the flow.

### Interact

Never, ever, write in a vacuum. Show your work to people: friends,
colleagues, reviewers. Check with your publisher to see how they want
to handle this, but get feedback early, and get it often. If you work
with a publisher who offers a beta book program (where books are
released as works in progress), see if you can take advantage of it:
releasing your book to the general readership early will generate a
tremendous amount of feedback.

### Save and Archive Often

It’s almost embarrassing to have to say this, but please make sure you
back up your book. When the Pragmatic Bookshelf signs a new book, we
create a new project for the book’s files in our Subversion version
control repository. As the author creates and edits content for the
book, we strongly encourage them to commit these changes to the
repository, multiple times a day. That way, if they have a hard drive
failure they won’t lose their work: it’ll tucked away securely on our
servers.

Other publishers may not offer a Subversion repository for your
work. If that’s the case, I strongly recommend you set up something
similar for yourself. At the very least, get into the habit of
archiving your writing onto some external machine or external media on
a regular basis. Ideally, keep the content in a version control
system.

### Use Cross References as Placeholders

Although I’ve
[written about this before](/blog/2005/03/16/the-wiki-way-of-writing/)
before, I’d like to mention it again. Use cross
references as placeholders for content you haven’t written yet.


### Outline the Plot, not the Paragraphs

It’s just natural: people like lists. And all the conventional wisdom
tells writers to produce outlines for their books. So many writers
take this to heart, producing long, deeply nested notes that tell them
what each paragraph in a chapter should contain.

If this works for you, do it. But don’t feel that strict outlining is
necessary. When I write, I start each chapter with a simple list of
the things I want the reader to learn by the time they get to the
end. I then sort them into an order which seems to make sense as a
narrative. Then I replace each item with a section or subsection of
prose. I find that this scheme gives me the skeleton I need for a
chapter, but it also gives me the flexibilitiy I need when fleshing it
out.

This list just scratches the surface—there are whole books on writing
tricks. As yo’re starting out, ask your editor for their ideas. Search
out more experienced authors and see what they do.

Writing a book is difficult. Don’t make it harder than it has to be.

