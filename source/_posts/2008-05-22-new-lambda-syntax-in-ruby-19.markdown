---
layout: post
title: "New lambda syntax in Ruby 1.9"
date: 2008-05-22 19:00:00 -0600
comments: true
categories: []
---

I’m slowly getting used to the new `->` way of specifying lambdas in
Ruby 1.9. I still feel that, as a notation, it could be clearer. (I’d
personally like just plain backslash, because that looks pretty close
to a real lambda character, but that’s not going to happen.) But
having punctuation, rather than the word`lambda`, makes a surprising
difference to the way my eyes read code.

For example, you could write a method that acts like a `while` loop.

``` ruby
def my_while(cond, &body)
  while cond.call
    body.call
  end
end
```

In Ruby 1.8  and 1.9, you could call this as

``` ruby
a = my_while lambda { a < 5 } do
  puts a
  a += 1
end
```

But my brain finds that seriously hard to scan. The Ruby
1.9 `->` syntax makes it slightly (just slightly, mind you) better:

``` ruby
a = my_while -> { a < 5 } do
  puts a
  a += 1
end
```

I suspect this is just a question of time. In a year or so, we’ll
parse the `->` syntax in our heads without thinking twice. Once it
does become natural, I suspect we’ll find all sorts of new uses for
procs.

