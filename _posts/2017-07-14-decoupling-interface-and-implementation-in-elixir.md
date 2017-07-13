---
layout: post
title: Splitting APIs, Servers, and Implementations in Elixir
date: 2017-07-14
comments: true
tags: programming elixir
---

> tldr; I think the conventional way of structuring Elixir code
> could be improved by paying more attention to decoupling.

I just finished writing the first of my Coding Gnome courses. This one
was an <a href="https://codestool.coding-gnome.com">introduction to
Elixir</a> for experienced programmers.

I tried to concentrate on partitioning code in a reasonable manner. I
didn't use the traditional Elixir scheme, which comes from a mating of
Ruby and Erlang project layouts. Instead, I tried to come at it with a
fresh eye, asking myself how the various aspects of the code could
best be decoupled.

## Separating Execution Strategy from Logic

Elixir and Erlang have an interesting execution module. You program
using processes and message passing, but they abstract this into the
concept of _servers_. You call a function (typically
`GenServer.call(pid, args)`) and this in turn send a message to the
server identified by `pid`. Inside that server, you write callback
functions that are invoked in response to these messages.

In real life, no one wants to write a server whose API involves such
convolution. So the convention arose that you'd provide an API layer
to your server, written in the same module. Here's an example, stolen
from the Elixir guide, and cut down somewhat:

~~~ elixir
defmodule KV.Registry do
  use GenServer

  ##############
  # Client API #
  ##############

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def create(server, name, value) do
    GenServer.call(server, {:store, name, value})
  end

  ####################
  # Server Callbacks #
  ####################
  
  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  def handle_call({:store, name, value}, _from, names) do
    {:reply, Map.put(names, name, value)}
  end
end
~~~

Here the top half of the module is the public facing API, and the
lower half is the code that runs in a separate process and that
implements the functionality.

I've never been comfortable with this. It seems to bury the important
part—the actual implementation—in amongst all kinds of GenServer
housekeeping. It also makes the development of the code a lot
trickier—you have to write the server at the same time that you write
the implementation.

So in the course I recommended a different approach—one that I've been
using personally for a while. In it, I write the application
functionality in its own module, under `lib/`. This has no GenServer
support—after all, it's just the app logic.

~~~ elixir
defmodule Kv.Impl do       # in lib/kv/impl.ex

  def new() do
    %{}
  end

  def lookup(names, name) do
    Map.fetch(names, name)
  end

  def store(names, name, value) do
    Map.put(names, name, value)
  end

end
~~~

That makes it easier to see what's going on. I can also write tests
directly against this logic.

Now, here's the weird part. You might look at this and say that here's
the module that other applications should call. But I think that's not
the case. Let's instead declare the API in the top-level `kv.ex` file:

~~~
lib
├── kv
│   └── impl.ex
└── kv.ex               # <- the API belongs in here
~~~

Right now, this API just calls directly down to the implementation.

~~~ elixir
defmodule Kv do

  defdelegate new(),                     to: Kv.Impl
  defdelegate lookup(names, name),       to: Kv.Impl
  defdelegate store(names, name, value), to: Kv.Impl

end
~~~

Also pretty clean, right?

So now we have a working application (aka library), and people can
start using it.

### Bring On the Server

Circumstances change, and our library needs to become a full server.

We write the server code in `lib/server.ex`.

~~~ elixir
defmodule Kv.Server do
  use GenServer
  alias Kv.Impl

  def init(store) do
    { :ok, store }
  end

  def handle_call({:lookup, name}, _, store) do
    result = Impl.lookup(store, name)
    { :reply, result, store }
  end

  def handle_cast({:store, name, value}, store) do
    { :reply, Impl.store(store, name, value) }
  end
end
~~~

This is just pure server code—no API, and no application logic. 

Finally, we change the API in the top-level `kv.ex` file:

~~~ elixir
defmodule Kv do

  def new() do
    { :ok, names } = GenServer.start_link(Kv.Server, %{})
    names
  end
  
  def lookup(names, name) do
    GenServer.call(names, {:lookup, name})
  end
  
  def store(names, name, value) do
    GenServer.cast(names, { :store, name, value })
    names
  end

end
~~~

The only slightly strange thing is that `store()` returns the server
pid. Doing so maintains the same API that we had previously, where the
`store()` function returned the updated map. In both cases, the return
value simply represents an (opaque) updated state.

As a result, we now have:

~~~
lib
├── kv
│   ├── impl.ex . . . . . . .   Application implementation
│   └── server.ex . . . . . .   GenServer implementation
└── kv.ex . . . . . . . . . .   API
~~~

This is the scheme I now use, and so far I much prefer it to the
conventional one.

## Bonus Section

### Subservers

What if my application needs its own GenServers as part of its
implementation? Well, just follow the same pattern, but one level down
the directory tree:

~~~
lib
├── kv
│   ├── bucket
│   │   ├── impl.ex
│   │   └── server.ex
│   ├── bucket.ex
│   ├── impl.ex
│   └── server.ex
└── kv.ex
~~~

The rule here is that no one outside the application is allowed to
call functions outside `lib/kv.ex`.

### Applications are Components

Although the good folks who brought us Erlang were really, really
smart people who produced designs for a future that did not yet exist,
they really weren't that good at naming things. 

One of the most confusing names is _application_. 

In "the real world" an application is something you deliver to the end
user. A payroll system is an application. A word processor is an
application.

But in Erlang, and hence Elixir, an application is a self-contained
bundle of modules and resources with its own lifecycle. The Logger,
for example, is an application. The elixir compiler contains over a
dozen. 

Erlang applications are really just components.

But because the word application is so ingrained in us developers, it
is hard to remember this. And so we have a tendency to throw all our
code into a single directory tree because, after all, it's the
application.

So I'm trying to retrain my brain by writing my code as series of
separate applications, each as small as I can make it. And I'm not
using umbrella projects for this, because I want to be able to share
these components across different projects.

So, next time you're writing a killer Phoenix app, think about why you
have Ecto in your web tier. Shouldn't the business logic be out in its
own application? And why do you have contexts in the web layer? Maybe
the contexts each correspond to an external app.

Decouple. You know it makes sense.

<div class="thinkific-product-card" data-btn-txt="Free Preview" data-btn-txt-color="#ffffff" data-btn-bg-color="#4c1130" data-card-type="card" data-link-type="landing_page" data-product="127256" data-embed-version="0.0.2" data-card-txt-color="#ffffff" data-card-bg-color="#a64d79" data-store-url="https://courses.thinkific.com/embeds/products/show"><div class="iframe-container"></div><script type="text/javascript">document.getElementById("thinkific-product-embed") || document.write('<script id="thinkific-product-embed" type="text/javascript" src="https://assets.thinkific.com/js/embeds/product-cards-client.min.js"><\/script>');</script><noscript><a href="https://coding-gnome.thinkific.com/courses/elixir-for-programmers" target="_blank">Free Preview</a></noscript></div>

