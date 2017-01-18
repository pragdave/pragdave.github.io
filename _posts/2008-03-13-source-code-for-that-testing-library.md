---
layout: post
title: "Source Code for that Testing Library"
date: 2008-03-13
comments: true
tags: []
---


> Ring the bells that still can ring<br>
> Forget your perfect offering <br>
> There is a crack in everything<br>
> That’s how the light gets in.
> <footer class="blockquote-footer">Leonard Cohen</footer>

Yesterday, I posted on a trivial little testing library I hacked
together. Get the source through Rob’s git
repository (see below).

In the meantime, I discovered a problem with the idea of intercepting
comparison operators, the technique used by the `expect` method. Ruby
doesn’t really have `!=` and `!~` methods. Instead, the parser maps`(a
!= b)` into `!(a == b)`. This means that the ComparisonProxy cannot
intercept calls to either of these. This is a problem because

``` ruby
expect(1) != 1
```

actually passes, because it becomes `!(expect(1) == 1)`, and the
expect method is happy with that.

I’m betting there’s a way around this…

**Update: 14:26 CDT**.

Rob Sanheim has set up a Git repository for the code. He says

```
git clone git://github.com/rsanheim/prag_dave_testing.git

```

Michael Neumann suggested a way around the negated == and =~ tests
using source inspection:



``` ruby
class ComparatorProxy
   def ==(obj)
     # try to get the source code position of the call
     # and see if it's a != or a ==
   end
end
```




