---
title:    Elixir Project Structure
layout:   post
comments: true
tags:     programming elixir ruby javascript go
---

> I think the way we organize our projects' files obscures the code
> and make simple things complex. We do it not because we want to, but
> because we feel we need to in order to tame complexity. There's
> another way: stop writing complex code.

### The Smoking Guns

Here's the result of running `mix new my_app --sup`:

~~~
my_app
├── config
│   └── config.exs
├── lib
│   ├── my_app
│   │   └── application.ex
│   └── my_app.ex
├── mix.exs
├── README.md
└── test
    ├── my_app_test.exs
    └── test_helper.exs
~~~
{: .dirtree }

Here's a Ruby project created with `bundle gem my_app`:

~~~
my_app/
├── bin
│   ├── console
│   └── setup
├── Gemfile
├── lib
│   ├── my_app
│   │   └── version.rb
│   └── my_app.rb
├── my_app.gemspec
├── Rakefile
└── README.md
~~~
{: .dirtree }

Here's a JavaScript project:

~~~
├── dist
│   ├── app.js
│   └── index.html
├── node_modules
├── src
│   ├── lib
│   │   ├── login.js
│   │   └── user.js
│   ├── app.js
│   └── index.html
├── gulpfile.js
├── package.json
└── README
~~~
{: .dirtree }

And here's the recommended Go project tree:

~~~
project-layout/
├── api
│   └── README.md
├── assets
│   └── README.md
├── build
│   ├── ci
│   ├── package
│   └── README.md
├── cmd
│   ├── README.md
│   └── _your_app_
├── configs
│   └── README.md
├── deployments
│   └── README.md
├── docs
│   └── README.md
├── examples
│   └── README.md
├── githooks
│   └── README.md
├── init
│   └── README.md
├── internal
│   ├── app
│   │   └── _your_app_
│   ├── pkg
│   │   └── _your_private_lib_
│   └── README.md
├── LICENSE.md
├── Makefile
├── pkg
│   ├── README.md
│   └── _your_public_lib_
├── README.md
├── scripts
│   └── README.md
├── test
│   └── README.md
├── third_party
│   └── README.md
├── tools
│   └── README.md
├── vendor
│   └── README.md
└── web
    ├── app
    ├── README.md
    ├── static
    └── template
~~~
{: .dirtree }

Let's look at just the top level directory of each:


<table>
<tr>
<th>Elixir</th>
<th>Ruby</th>
<th>JavaScript</th>
<th>Go</th>
</tr>
<tr valign="top">
<td>
<pre class="dirtree"><code>
my_app
├── config
├── lib
├── mix.exs
├── README.md
└── test
</code></pre>
</td>

<td>
<pre class="dirtree"><code>
my_app/
├── bin
├── Gemfile
├── lib
├── my_app.gemspec
├── Rakefile
└── README.md
</code></pre>
</td>
<td>
<pre class="dirtree"><code>
├── dist
├── node_modules
├── src
├── gulpfile.js
├── package.json
└── README
</code></pre>
</td>
<td>
<pre class="dirtree"><code>
project-layout/
├── api
├── assets
├── build
├── cmd
├── configs
├── deployments
├── docs
├── examples
├── githooks
├── init
├── internal
├── LICENSE.md
├── Makefile
├── pkg
├── README.md
├── scripts
├── test
├── third_party
├── tools
├── vendor
└── web
</code></pre>
</td>
</tr>
</table>

Now let's imagine we can find an alien, unsullied by the preconceptions
and practices of us developer folk. Let's call this individual Normal
Human Being.

We show these structures to Normal and ask "what's going on here?"
Normal thinks about this for a while.

"Well," they say, "I imagine that you organize your thinking
hierarchically _(how quaint)_ and that you put the most important things
at the top level. Doing things this was means that you can then split
each top-level important thing into subthings at the next level in your
hierarchy."

"So, based on what I see across this selection of programming languages,
you're showing me four projects where the most important thing about the
code is the boilerplate housekeeping. Clearly, you must be seriously
advanced if this trumps the actual code that you write."

Once they realized that they were wrong, and that, yes, we do worship
housekeeping, the NHBs invaded the planet, conquering us without a shot
being fired (largely because we were still waiting for NPM install
to run on the fire control computers).

### First, Choose The Correct Problem

I believe the reason for these baroque structures is simple: in the past
we learned that when we write complex applications, things got out of
hand. We ended up with directories with random names, some containing
hundreds of files, each project different from the others.

So we fixed the wrong problem.

We said, "if we impose a strict structure on our projects, we can tame
this complex katamari damacy of files."

But what we _should_ have said was, "let's not write such big projects."

### Break It Down

Imagine if instead we could build our code using lots of individual
components, and that each component could fit into a single source file
of (at most) a couple of hundred lines.

What would the project directory tree look like then?

~~~
├── my_app.ex               ← source of component
├── meta.yml                ← dependencies, build options, etc
└── tests/
~~~
{: .dirtree }


The README is simply the leading comment block in the source file. The
build tool uses the metadata to find and resolve dependencies, compile
the source, and construct an executable.  For a component with no
dependencies that followed the default conventions of the language, and
which used doctests, the
component could be as simple as:

~~~
└─ my_app.ex               ← source of component
~~~
{: .dirtree }

### You May Say I'm Bikeshedding

And I am. Project directory structure is definitely not a big problem.

But the fact that we had to invent these structures, which hide the
actual code of our project two, three, or more levels deep in a
directory tree, is a smoking gun. We are writing all our code in a
single project; a single application. The lessons of the [monorail](https://www.somethingsimilar.com/2012/07/23/monorail/)
seem to have been forgotten. Frameworks such as Phoenix encourage you to
bundle application logic into the web serving codebase. Deployment tools
make it simpler to release monolithic applications. And coupling between
components only increases.

### You May Say I'm A Dreamer…

…but I am experimenting with possible solutions. I'm working on a proof
of concept library that makes it easier to write distributed, concurrent
components in Elixir. I'm playing with a tool that makes it easier to
assemble these components into deliverable solutions, and to deploy
those assemblies to a dynamic cloud of machines. It's way too early to
say I have a solution to any of this. But I do have something I can
experiment with.

I gave a talk about this at
[Empex](http://empex.co/events/2018/conference.html) last month.

<iframe width="960" height="540" src="https://www.youtube.com/embed/6U7cLUygMeI" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

Things
have changed even since then. But I'm still convinced we need to rething
how we write code.
