---
layout: post
title: "Parameterizing types using pattern matching"
date: 2014-02-13 23:33:18 -0600
comments: true
categories: 
---

Elixir's pattern matching means we can extend the parsing of streams
by abstracting out type information.

A couple of days ago I wrote about using pattern matching to
[parse a stream of tokens](http://pragdave.me/blog/2014/02/12/pattern-matching-and-parsing/).

Today I came across an extension of this technique.

I spend some time this evening playing with the Markdown parser.

First, I created a pattern that looked at my token stream for
consecutive lines of indented code. I wanted to merge these into a
single `code` token containing all the lines. That is, I wanted to
make the following test pass.

``` elixir
  test "concatenates multiple code lines into one" do
    lines = ["p1", 
             "    code1",
             "    code2", 
             "    code3", 
             "p2"]
    assert categorize(lines) == [
       %{ type: :textline, text: "p1" }, 
       %{ type: :code,     text: ["code1", "code2", "code3"] },
       %{ type: :textline, text: "p2"}
    ]
  end
```

Using the same matching strategy I described in the previous post, the code was easy:

``` elixir
def merge_compound([ %{type: :code, text: t1},
                     %{type: :code, text: t2}
                   |
                      rest
                   ], result) do
  merge_compound( [ %{ type: :code, text: [ t2 | List.wrap(t1) ] } | rest],
                  result)
end
```

Then I looked a blockquotes. I had the same requirement—multiple
consecutive lines of blockquote should get merged into one blockquote
token. Here's the code for that:

``` elixir
def merge_compound([ %{type: :blockquote, text: t1},
                     %{type: :blockquote, text: t2}
                   |
                      rest
                   ], result) do
  merge_compound( [ %{ type: :blockquote, text: [ t2 | List.wrap(t1) ] } | rest],
                  result)
end
```

Eerily similar to the function that handles code lines, eh? Can we
remove the duplication? Sure thing—we can make the type (`:code` or
`:blockquote`) a variable in the pattern. The fact we use the same
variable for both tokens means it has to be the same for each, s we'll
match two code lines, or two blockquotes lines, but not a code line
followed by a blockquote.

We can then use a _guard clause_ to ensure that we only match when
this type is one of the two.

In the body of the function, we can use that same variable to generate
a new token of the correct type. The result looks something like this:

``` elixir
def merge_compound([ %{type: type, text: t1},
                     %{type: type, text: t2}
                   |
                      rest
                   ], result) 
when type in [:code, :blockquote] do
  merge_compound( [ %{ type: type, text: [ t2 | List.wrap(t1) ] } | rest],
                  result)
end
```

This made me very happy. But it gets even better.

Blockquotes have another behavior. After a blockquote line, you can be
lazy—immediately adjacent plain text lines are merged into the
blockquote. That is, you can write

<table>
<tr>
<td>
```
> now is the time
> for all good coders
> to try a functional language
```
</td>
<td style="padding: 0em 1em"> 
as
</td>
<td>

```
> now is the time
for all good coders
to try a functional language
```
</td></tr></table>

Clearly, code lines do not have this behavior. So, do we have to split
apart the function we just wrote? After all, code and blockquotes are
no longer identical.

No we don't. Because we're parsing a stream of tokens, and because we
can reinject tokens back into the stream, we can handle the extra
blockquote behavior using an additional pattern match. Our function
now looks like this:

``` elixir
def merge_compound([ %{type: type, text: t1},
                     %{type: type, text: t2}
                   |
                      rest
                   ], result) 
when type in [:code, :blockquote] do
  merge_compound( [ %{ type: type, text: [ t2 | List.wrap(t1) ] } | rest],
                  result)
end

# merge textlines after a blockquote into the quote
def merge_compound([ %{type: :blockquote, text: t1},
                     %{type: :textline,   text: t2}
                   |
                      rest
                   ], result) do
  merge_compound( [ %{ type: :blockquote, text: [ t2 | List.wrap(t1) ] } | rest],
                  result)
end
```

This makes me even happier.

### But you can take this too far…

You probably noticed we still have some duplication—the bodies of the two
functions are pretty much identical. Can we use guards to merge them? You bet:


``` elixir
def merge_compound([ %{type: type1, text: t1},
                     %{type: type2, text: t2}
                   |
                      rest
                   ], result) 
when (type1 == type2 and type1 in [:code, :blockquote])
  or (type1 == :blockquote and type2 == :textline) do
  merge_compound( [ %{ type: type1, text: [ t2 | List.wrap(t1) ] } | rest],
                  result)
end
```

However, I think that this is taking things too far, simply because
there's a lot of logic in the guard clause. So I backed this change out
and went back to the simpler form with two separate functions.

### Streams and Filters

One of the reasons I'm enjoying this coding exercise so much is this
style of using streams and functions that parse them reminds me of two
very elegant techniques from our past.

First, we're processing streams of stuff using a succession of
functions, each of which maps the stream into something else. This is
very similar to the Unix shell _pipeline_ facility, where you pipe the
output of one command into the input of another. This let's you use
small, focused filters (count words, sort lines, look for a pattern)
and then combine them in ways that the original writers never imagined.

Second, our use of pattern matching and guards really is a simple form
of parsing. And I'm attracted to programming solutions that
incorporate parsers, because parsers are a great way of separating
_what to do_ from _what to do it to_. This kind of structure leads to
highly decoupled (and easily tested) code.

So, I'm just a few days into the experiment, but I've already learned
a lot. And I suspect this knowledge will dramatically impact my
programming style going forward.
