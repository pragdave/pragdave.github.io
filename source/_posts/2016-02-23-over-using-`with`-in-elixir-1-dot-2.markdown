---
layout: post
title: "(Over)using `with` in Elixir 1.2"
date: 2016-02-23 22:41:10 -0600
comments: true
categories: elixir
---

Elixir 1.2 introduced a new expression type, `with`.
It's so new that the syntax highlighter I use from this
blog doesn't know about it.

`with` is a bit like `let`
in other functional languages, in that it defines a local scope for
variables. This means you can write something like

``` elixir
owner = "Jill"

with name  = "/etc/passwd",
     stat  = File.stat!(name),
     owner = stat.uid,
do:
     IO.puts "#{name} is owned by user ##{owner}"

IO.puts "And #{owner} is still Jill"
```

The `with` expression has two parts. The first is a list of
expressions; the second is a `do` block. The inital expressions are
evaluated in turn, and then the code in the `do` block is evaluated.
Any variables introduced inside a `with` are local to that `with`. The
the case of the example code, this means that the line `owner =
stat.uid` will create a new variable, and not change the binding of
the variable of the same name in the outer scope.

On its own, this is a big win, as it lets us break apart complex
function call sequences that aren't amenable to a pipeline. Basically,
we get temporary variables. And this makes reading code a lot more
fun.

For example, here's some code I wrote a year ago. It handles the
command-line options for the Earmark markdown parser:

``` elixir
defp parse_args(argv) do
  switches = [
    help: :boolean,
    version: :boolean,
    ]
  aliases = [
    h: :help,
    v: :version
  ]

  parse = OptionParser.parse(argv, switches: switches, aliases: aliases)

  case parse do

  { [ {switch, true } ],  _,  _ } -> switch
  { _, [ filename ], _     } -> open_file(filename)
  { _, [ ],          _ }     -> :stdio
    _                        -> :help
  end
end
```

Quick! Scan this and decide how many times the `switches`
variable is used in the function. You have to stop and parse the code
to find out. And given the ugly `case` expression at the end, that
isn't trivial.

Here's how I'd have written this code this morning:

``` elixir
defp parse_args(argv) do
  parse =
    with switches = [ help: :boolean, version: :boolean ],
         aliases  = [ h: :help, v: :version ],
    do:
         OptionParser.parse(argv, switches: switches, aliases: aliases)

  case parse do
    { [ {switch, true } ],  _,  _ } -> switch
    { _, [ filename ], _     }      -> open_file(filename)
    { _, [ ],          _ }          -> :stdio
      _                             -> :help
  end
end
```

Now the scope of the switches and aliases is explicit—we know that
can't be used in the `case`.

There's still the `parse` variable, though. We _could_ handle this
with a nested `with`, but that would proably make our function harder
to read. Instead, I think I'd refactor this into two helper functions:

``` elixir
defp parse_args(argv) do
  argv
  |> parse_into_options
  |> options_to_values
end

defp parse_into_options(argv) do
  with switches = [ help: :boolean, version: :boolean ],
       aliases  = [ h: :help, v: :version ],
  do:
       OptionParser.parse(argv, switches: switches, aliases: aliases)
end

defp options_to_values(options) do
  case options do
    { [ {switch, true } ],  _,  _ } -> switch
    { _, [ filename ], _     }      -> open_file(filename)
    { _, [ ],          _ }          -> :stdio
      _                             -> :help
  end
end
```

Much better: easier to read, easier to test, and easier to change.

Now, at this point you might be wondering why I left the `with`
expression in the `parse_into_options` function. A good question, and
one I'll ty to answer after looking at the second use of `with`.

## `with` and Pattern Matching

The previous section parsed command line arguments. Let's change it up
(slightly) and look at validating options passed between functions.

I'm in the middle of writing an Elixir interface to GitLab, the open
source GitHub contender. It's a simple but wide JSON REST API, with
dozens, if not hundreds of available calls. And most of these calls
take a set of named parameters, some required and some optional. For
example, the API to create a user has four required parameters (email,
name, password, and username) along with a bunch of optional ones
(bio, Skype and Twitter handles, and so on).

I wanted my interface code to validate that the parameters passed to
it met the GitLab API spec, so I wrote a simple option checking
library. Here's some idea of how it could be used:

``` elixir
@create_options_spec %{
  required: MapSet.new([ :email, :name, :password, :username ]),
  optional: MapSet.new([ :admin, :bio, :can_create_group, :confirm,
                         :extern_uid, :linkedin, :projects_limit,
                         :provider, :skype, :twitter, :website_url ])
}

def create_user(options) do
  { :ok, full_options } = Options.check(options, @create_options_spec)
  API.post("users", full_options)
end
```

The options specification is a Map with two keys, `:required` and `optional`.
We pass it to `Options.check` which validates that the options passed
to the API contains all required values and any additional values are
in the optional set.

Here's a first implementation of the option checker:

``` elixir
def check(given, spec) when is_list(given) do
  with keys = given |> Dict.keys |> MapSet.new,
  do:
       if opts_required(keys, spec) == :ok && opts_optional(keys, spec) == :ok do
         { :ok, given }
       else
         :error
       end
end
```

We extract the keys from the options we are given, then call two
helper methods to verify that all required values are there and that
any other keys are in the optional list. These both return `:ok` if
their checks pass, `{:error, msg}` otherwise.

Although this code works, we sacrificed the error messages to keep it
compact. If either checking function fails to return `:ok`, we bail
and return `:error`.

This is where `with` shines. In the list of expressions between the
`with` and the `do` we can use `<-`, the new _conditional pattern match_ operator.


``` elixir
def check(given, spec) when is_list(given) do
  with keys = given |> Dict.keys |> MapSet.new,
       :ok <- opts_required(keys, spec),
       :ok <- opts_optional(keys, spec),
  do:
       { :ok, given }
end
```

The `<-` operator does a pattern match, just like `-`. If the match
succeeds, then the effect of the two is identical—variables on the
left are bound to values if necessary, and execution continues.

`=` and `<-` diverge if the match fails. The `=` operator will raise
and exception. But `<-` does something sneaky: it
terminates the execution of the `with` expression, but doesn't raise
an exception. Instead the `with` returns the value that couldn't be
matched.

In our option checker, this means that if both the required and
optional checks return `:ok`, we fall through and the `with` returns
the `{:ok, given}` tuple.

But if either fails, it will return `{:error, msg}`. As the `<-`
operator won't match, the with clause will exist early. Its value will
be the error tuple, and so that's what the function returns.

### The Point, Labored

The new `with` expression gives you two great features in one tidy
package: lexical scoping and early exit on failure.

It makes your code better.

Use it.

A lot.

## Here's Where I Differ with José

Johnny Winn interviewed José for the <a href="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/245652921&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false&amp;visual=true">Elixir Fountain</a> podcast a few
weeks ago.

The discussion turned to the new features of Elixir 1.2, and José
described `with`. At the end, he somewhat downplayed it, saying you
rarely needed it, but when you did it was invaluable. He mentioned
that there were perhaps just a couple of times it was used in the
Elixir source.

I think that `with` is more than that. You rarely _need_ it, but you'd
often benefit from using it. In fact, I'm am experimenting with using
it every time I create a function-level local variable.

What I'm finding is that this discipline drives me to create simpler,
single-purpose functions. If I have a function where I can't easily
encapsulate a local within a `with`, then I spend a moment thinking
about splitting it into two. And that split almost always improves my
code.

So that's why I left the `with` in the `parse_into_options` function
earlier.

``` elixir
defp parse_into_options(argv) do
  with switches = [ help: :boolean, version: :boolean ],
       aliases  = [ h: :help, v: :version ],
  do:
       OptionParser.parse(argv, switches: switches, aliases: aliases)
end
```

It isn't needed, but I like the way it delineates the two parts of the
function, making it clear what is incidental and what is core. In my
head, it has a narrative structure that simple linear code lacks.

This is just unfounded opinion. But you might want to experiment with
the technique foe a few weeks to see how it works for you.
