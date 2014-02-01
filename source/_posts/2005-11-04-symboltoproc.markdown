---
layout: post
title: "Symbol#to_proc"
date: 2005-11-04 19:00:00 -0600
comments: true
categories: []
---

The <a href="http://extensions.rubyforge.org/">Ruby Extensions
Project</a> contains an absolutely wonderful hack. Say you want to
convert an array of strings to uppercase. You could write

``` ruby
  result = names.map {|name| name.upcase}

```

Fairly concise, right? Return a new array where each element is the
corresponding element in the original, converted to uppercase. But if
you include the Symbol extension from the <a
href="http://extensions.rubyforge.org/">Ruby Extensions Project</a>,
you could instead write

``` ruby
  result = names.map(&:upcase)

```

Now that’s concise: apply the upcase method to each element
of names. So, how does it work?

It relies on Ruby doing some dynamic type conversion. Let’s start at the top.

When you `say names.map(&xxx)`, you’re telling Ruby to pass
the Proc object in `xxx` to `map` as a block. If `xxx` isn’t already
a Proc object, Ruby tries to coerce it into one by sending it
a `to_proc` message.

Now `:upcase` isn’t a Proc object—it’s a symbol. So when Ruby
sees `names.map(&:upcase)`, the first thing it does is try to convert
the Symbol `:upcase` into a Proc by calling `to_proc`. And, by an
incredible coincidence, the extension project has defined
a `to_proc` method for class Symbol. It looks like this:

```ruby
    def to_proc
      proc { |obj, *args| obj.send(self, *args) }
    end

```

It creates a Proc which, when called on an object, sends that object
the symbol itself. So, when `names.map(&:upcase)` starts to iterate over
the strings in names, it’ll call the block, passing in the first name
and invoking its upcase method.


It’s an incredibly elegant use of coercion and of closures.

