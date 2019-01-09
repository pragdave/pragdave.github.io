---
title:    Small is Beautiful—The Component Library
layout:   post
comments: true
tags:     programming elixir
---

For a while now I've been doing my
[Cassandra](https://en.wikipedia.org/wiki/Cassandra) impersonation,
telling everyone who'll listen (and quite a few folks who won't) that we
need to be writing code in smaller chunks. I know what happens when we
don't, as I was the author of one of the largest early Rails
applications (65kloc), and it became a nightmare to work with.

I don't want the same thing to happen in the Elixir world. But if I've
learned one thing, it's that you can't tell people that something is a
good idea and expect them to do it.

No, you have to make it _easier_ to do things the right way.

So, I'm releasing a first version of my Elixir [Component
library](https://github.com/pragdave/component).

This library makes it easy to write code as servers (global, dynamic,
pooled, and hungry consumer), and it makes it trivial to package these
servers as self contained Elixir applications (so they can be used as
dependencies in other applications).

For example, here's a trivial key value store, written as a simple
(nonserver) module:

~~~ elixir
defmodule KV do

  def create() do
    %{}
  end

  def add_entry(store, k, v) do
    Map.put(store, k, v)
  end

  def get_entry(store, k)
    Map.get(store, k)
  end
end
~~~

Call it like this:

~~~
iex> kv = KV.create
iex> KV.add_entry(kv, :name, "dave")
iex> KV.add_entry(kv, :language, "elixir")
iex> KV.get_entry(kv, :name)     # => "dave"
~~~

Let's use the component framework to turn this into a freestanding
component that can be added to any application as a dependency:

~~~ elixir
defmodule KV do

  use Component.Strategy.Dynamic,
      state_name: store,
      initial_state: %{},
      top_level: true

  def add_entry(store, k, v) do
    Map.put(store, k, v)
  end

  def get_entry(store, k)
    Map.get(store, k)
  end
end
~~~

Then update `mix.exs` to make `KV` your top-level application:

~~~ elixir
def application do
  [
    mod: { KV, [] },
    . . .
  ]
end
~~~

And run it from iex:

~~~
$ iex -S mix
iex> kv = KV.create
iex> KV.add_entry(kv, :name, "dave")
iex> KV.add_entry(kv, :language, "elixir")
iex> KV.get_entry(kv, :name)     # => "dave"
~~~

It runs as a supervised application with a dynamic supervisor managing
the individual server processes.

Anyway, the philosophy of all this is not to save on typing. Instead the
intent is to nudge people into writing their programs using lots of
small, independent components, linked via dependencies. That's how I've
been  coding for the last year or so, and so far I'm really, really
liking it.

Check out Component [on github](https://github.com/pragdave/component)