---
layout: post
title: "Pattern Matching and Parsing"
date: 2014-02-12 18:52:45 -0600
comments: true
categories: 
---

It turns out that pattern matching and data structure decomposition
are a wonderful tool for doing parsing of nonregular grammars (such as
Markdown).

<!-- more -->

I'm working on writing a Markdown parser in the
[Elixir](http://pragprog.com/titles/elixir) language. It's something I
do in new languages when I get the time, because parsing Markdown is
nontrivial—the syntax is decidely nonregular.

Anyway, I've hacked up (and thrown away) Ruby and Javascript
implementations, and decided to give Elixir a go.

Most of the Markdown parsers out there use regular
expressions to scan and transform their input.[^1] I started off doing
the same, but quickly bumped into all the nastiness that this approach
entails.

Then I realized that the so-called block-level Markdown elements can
be parsed differently. Rather than try to do it in one pass, I'm
taking two.

On the first pass, I just look at each line, categorizing it. Typical
categories might be _blank line_, _rule_, _heading_, and so on. But
there are some things that can't be decided by looking at just one
line. For example, a setext heading looks like this:

```
and here a paragraph ends.

This is the Heading
===================

And here is the body…
```

That is, the heading is a blank line, a line of text, a line
containing equals signs (or hyphens), and another blank line.

In the design I'm playing with, these kinds of headings (and other
structures that require more context than a single line to parse) are
recognized by the second pass through the lines.

### Top-Level Driver

The top level code looks something like this:

``` elixir
def categorize(lines) do
  Stream.concat([[""], lines, [""]])             # start and end with a blank line
  |> Enum.map(&type_of/1)
  |> merge_compound_lines
end
```

The first line of the function takes the list of lines and turns them
into something that is streamable. At the same time, it prepends and
appends a blank line, because empty lines act as delimiters for
many block-level structures.

The `map` line applies the function `type_of` to each line.

### First Pass—Assigning a Type to Each Line

The
`type_of` function returns a description of each line. For example, a
blank line will be returned as `[type: :blankline]` and the atx-style
heading `### Conclusion` will be returned as `[type: :heading, level:
3, text: "conclusion"]`. The code that performs this mapping is
trivial:

``` elixir
def type_of(line) do
  cond do
    line =~ ~r/^\s*$/ ->
      [ type: :blankline ]

    match = Regex.run(~R/^(#{1,6})\s+(?|([^#]+)#*$|(.*))/, line) -> 
      [ _, level, heading ] = match
      [ type: :heading, level: String.length(level), text: String.strip(heading) ]
 #...
```

There are probably 15 or so of these line types. Two that
we'll be using in a minute are `:setext_underline_heading`, a line containing only
equals signs or hyphens, and `:textline`, a line containing text that doesn't
match any of the other types.

``` elixir
match = Regex.run(~r/^(=|-)+\s*$/, line) ->
  [ _, type ] = match
  level = if(String.starts_with?(type, "="), do: 1, else: 2)
  [ type: :setext_underline_heading, level: level ]

true ->  
  [ type: :textline, text: line ]
```


### Second Pass—Combining Lines into Blocks

So now we have a list of line types. We need to look for things such
as the setext-style heading. And it turns out that structure
decomposition lets us do this pretty painlessly. Here's the code for
the headings:

``` elixir
def merge_compound_lines(lines), do: merge_compound(lines, [])

def merge_compound([], result), do: Enum.reverse(result)

def merge_compound([ [type: :blankline] = blank, 
                     [type: :textline, text: heading],
                     [type: :setext_underline_heading, level: level],
                     [type: :blankline]
                   | rest
                   ],
                   result) 
do
  merge_compound(rest,
                 [ blank, 
                   [type: :heading, level: level, text: heading], 
                   blank 
                 | result])
end
```

The first function is just a convenience, calling the real worker
with an additional parameter to hold the result.

Then we have the 
function `merge_compound` that recursively processes the lines.

The interesting thing here is the function head that starts on
line 5. Remember we said that an setext heading is a blank line, a
line of text, the line of equals signs, and another blank line. See
how structure decomposition and pattern matching let us express this
directly in code:

``` elixir
def merge_compound([ [type: :blankline] = blank, 
                     [type: :textline, text: heading],
                     [type: :setext_underline_heading, level: level],
                     [type: :blankline]
                   |
                     rest], result) do
```

This particular function will only be called if passed a list
that starts with those four elements.

Then, having recognized it, the body of the function replaces the
matched lines with new lines—a blank, a heading, and another blank. We
add these three to the result list by calling ourselves recursively:

``` elixir
merge_compound(rest,
              [ blank, 
                [type: :heading, level: level, text: heading], 
                blank 
              |
                result
              ])
```

And so it goes for the other complex block types.

### Pattern Matching Is Stream Parsing

In functional programming, your code is basically

```
input → some_function → output
```

You then use composition to break `some_function` into successively
lower levels of abstraction until you are dealing with primitive
values and built-in functions, at which point the decomposition can
stop.

```
input → some_function → output
         __/     \__
        /           \
        → fn1 → fn2 →
     ___ /   \__
    /           \
    → fn3 → fn4 →
```

If you look at it this way your program is basically a pipeline. A stream
of data enters it, gets analyzed, broken apart, piped
through a sequence of functions, mapped into something different, and
reassembled into the output.

That's where pattern matching comes it, destructuring the stream
of data and selecting what functions to apply.

And that's the cool part. If you think of your code this way, then
you're actually using pattern matching to parse the stream of data as
it passes through. If you can express your input as some kind of
grammar, then your program is something that transforms data that
matches that grammar.

This isn't just some kind of fancy abstraction, because knowing the
grammar you are working with can greatly simplify your code. For
example, if you know that your business rules are [context
free](http://en.wikipedia.org/wiki/Context-free_grammar), then you
also know that the code that parses and processes the corresponding
data can operate in isolation—it is automatically decoupled.

I'd written code this way in Elixir, but hadn't really thought
about it in terms of parsing until now. Now I'm starting to see more
and more of what I do in terms of grammars and production rules. 


### An Aside—Listening to the Angel on your Shoulder (or the Dog on Your Rug)

This writing of a Markdown parser is a
[CodeKata](http://codekata.com) that I do periodically. Writing the
Elixir version, I confidently set off down the same road I took with
the Javascript version.

Now Elixir isn't as natural at string processing as Javascript. As a
result, the road started to get a little twisty. I found myself doing
nonfunctional things. I found myself writing longish functions. I
found myself worrying about the efficiency of various operations.

And I kept at it. I wasn't going to give in. It didn't feel right, but
I WAS NOT GOING TO BE BEATEN.

{%imgcap right /img/Rubber_duck_assisting_with_debugging.jpg By Tom Morris (Own work)<br/>[CC-BY-SA-3.0 <http://creativecommons.org/licenses/by-sa/3.0> or <br/>GFDL <http://www.gnu.org/copyleft/fdl.html>, via Wikimedia Commons%}

In the old days, I'd describe my programming problems to a
[rubber duck](http://en.wikipedia.org/wiki/Rubber_duck_debugging). Nowadays
I've graduated to Moose, a twelve-year-old black lab whose ability to look
disgusted at the ways of people is unsurpassed. When I grumbled
about the problems I was having to Moose, he simply raised an eyebrow,
turned over, and went back to sleep. Which, of course, is shorthand
for “if the code is telling you that it's hard to do it this way, stop
doing it this way.”

So I threw away perhaps a day's work and reimplemented it using
pattern matching and streams in an hour or two.

It just feels a lot better.

And that's one of the reasons to get into the habit of practicing code
kata. The fact that it took a day to recognize I was heading into a
swamp is very sad, but the kata let me make that mistake in a
noncritical environment.

I was doing the Markdown kata for the n<sup>th</sup> time. This
time I learned not to fall into the rut of doing it the same way each
time, and I came away promising myself I'd listen to that feeling of
disquiet sooner in future.





[^1]: There are exceptions, of course. There are a number of PEG [markdown](https://github.com/jgm/peg-markdown) [parsers](http://hasseg.org/peg-markdown-highlight/), and some cool implementations in [Haskell](http://hackage.haskell.org/package/markdown-0.1.0.1/docs/Text-Markdown.html) and (my favorite) [OCaml](https://github.com/gildor478/ocaml-markdown).
