---
layout: post
title: "Fun with Ruby 1.9 File Encodings"
date: 2008-04-07
comments: true
tags: [ "ruby" ]
---

Ruby 1.9 allows you to specify the character encodings of I/O streams,
strings, regexps, symbols, and so on. It also lets you specify the
encoding of individual source files (and a complete application can be
built from many files, each with different character
encodings). Expect to start seeing a rash of obscure source code, at
least until the initial excitement abates and cooler thinking
prevails.

In the meantime, we can get away with

``` ruby
# encoding: utf-8
require 'mathn'
class Numeric
   def ℃
     (self - 32) * 5/9
   end
   def ℉
     self * 9/5 + 32
   end
end
 
puts 212.℃
puts 100.℉
```

Or, for those who’d like a peek at the start of a road that eventually
leads to madness:

``` ruby
alias ✎ puts 
 
✎ 212.℃
✎ 100.℉
```

I’m betting this post displays badly on about 50% of the machines that
are used to view it. Which is reason enough to tread very lightly down
this path…

