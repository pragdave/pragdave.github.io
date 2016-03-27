---
layout: post
title: "A loud \"Huzzah!\" was heard throughout the land"
date: 2008-01-07
comments: true
tags: []
---

Eric Hodel is giving RDoc <a
href="http://blog.segment7.net/articles/2008/01/07/rdocs-templatepage-removed-from-ruby">some
love</a>. You can’t imagine how happy that makes me.

When I first wrote RDoc, I was trying to find a way of solving two
problems:

* Adding comments to the largely uncommented C source of Ruby, and
* Providing a means for library writers easily to document their creations.

I’d just finished the PickAxe, and I wanted to take the work Andy and
I had done reverse engineering the Ruby API and add it back into the
interpreter source code.

I set myself constraints with RDoc and ri:

* it should produce at least some documentation even on totally
  uncommented source files
* it should extract tacit information from the program source (for
  example guessing good names for block parameters by looking for
  yield statements inside methods)
* the markup in the source files should be unobtrusive. In the typical
  case, someone reading the source should not even notice that the
  comments follow markup conventions
* it should only use libraries that come pre-installed with Ruby
* the documentation it produced should be portable across machines and
  architectures
* it should allow incremental documentation. Libraries that you
  install over time can add methods to existing classes. As you add
  these libraries, the method lists in the classes you extend should
  grow to reflect the changes
* it should be secure. People pushed many times to add the ability to
  execute code during the documentation process. I didn’t want to have
  code run on an end user’s machine during a process that ostensibly
  was simply installing documentation (particularly as these
  installations often ran as root)
* it should be throw-away

The last one might be a surprise, but the real objective of RDoc
wasn’t the tool. The real objective was to set a standard that meant
that future libraries would get documented in a consistent and usable
way. And so RDoc and ri compromised like crazy. Rather than a database
or some complex binary format, they used a set of directory trees in
the user’s filesystem to store documentation. This documentation,
which is basically a set of Ruby objects, was stored using YAML,
rather than marshaled objects or Ruby source. Even though YAML is
slow, it is more portable than marshaled objects, and more secure than
Ruby source. The parser in RDoc was a wild hack on the parser in
irb. This means it performs a static, not dynamic, analysis and that
it is sometimes confused by edge cases in Ruby syntax. So be it.

But the very worst part of RDoc/ri is the output side. I wanted to be
able to produce output in a variety of formats: HTML, plain text, XML,
chm, LaTeX, and so on. So the analysis side of RDoc produces a data
structure, and passes it to the output side. Here I made a stupid
design decision. What RDoc generates internally is basically nested
hashes. This has a couple of major advantages. In particular, there’s
a kind of fractal property when traversing it: it doesn’t matter how
deep you are in the structure—all you pass to the next routine down is
a hash. But it has a major downside—it’s a bitch to work with. If I
were doing it again, I’d use Structs.

Finally, there’s the generation of the output itself. I needed a
templating system and, for what seemed like good reasons at the time,
I wrote my own. It was only a handful of lines of code initially. It’s
still only a couple of hundred. It did a few things well, but
ultimately it was ugly as sin. But now, as Erb has become something of
a standard, it is definitely the right time to replace it.

RDoc and ri are, in a way, the ultimate <a
href="http://en.wikipedia.org/wiki/Stone_soup">stone soup</a>. The
code itself is not the output of the project. The real output is the
thousands of libraries that are now self-documenting. Eric and the
crew are busy on the stew, replacing the stones with real and tasty
ingredients. When they are finished, we’ll be able to use all that
library documentation in remarkable new ways. So, a big thank you to
Eric and Seattle.rb, and to all the Ruby coders who’ve created such a
great base of documentation for us all.

Here’s to RDoc 2.0.

