---
layout: post
title: "The Wiki Way of Writing"
date: 2005-03-16 19:00:00 -0600
comments: true
categories: []
---

Leaving dangling cross references when writing a book is like leaving
dangling hyperlinks in a Wiki—they’re both a promise and a question.


I’m deep down in the bowels of writing the new <a
href="http://pragmaticprogrammer.com/titles/rails">Rails book</a>. As
usual, I’m adopting a fairly agile development style, moving stuff
around between chapters, adding and deleting whole chapters, and
generally working stuff out as I go along.



One of the tricks that I discovered myself using is the _dangling
cross reference_. If I’m writing some introductory material, for
instance, I might do something such as



```
  Of course, you'll need to tidy those session files. We'll talk
  about this later in <pref linkend="sec.tidy.session.files"/>.

```



(Our books use a simple XML markup, and <pref…> creates a cross
reference [including a page number] to a named tag.)


As I haven’t yet written about tidying session files, when I format
the book, the cross reference shows up as


```
    about this later in ? on page ?.

```


But even better, the formatting process itself summarizes the list of
all missing cross references.


This all means that as I write, I can drop in these references, not
caring if the section exists. Every now and then I’ll look through the
list of unknown tag names. If I’ve since written about that material,
I’ll marry the text and the tag. If I haven’t I’ll know that at some
point I’ll have to add more text on the subject.


In a WikiWiki web, a CamelCase word referencing an unwritten page acts
as a promise of future content, and as an invitation for someone to
produce that content. The same seems to apply to writing books. It’s
fascinating to see the list of unfulfilled tags ebb and flow as the
Rails book progresses. It’s a kind of dialectic writing process.


