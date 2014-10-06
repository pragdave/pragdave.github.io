---
layout: post
title: "Thinking in Transforms—Handling Options"
date: 2014-10-05 07:15:21 -0500
comments: true
categories: [ "programming", "elixir" ]
---

I've been thinking a lot about the way I program recently. I even
[gave a talk about it](http://www.confreaks.com/videos/4119-elixirconf2014-opening-keynote-think-different) at the first
[ElixirConf](http://elixirconf.com/).

One thing I'm discovering is that transforming data is easier to think
about than maintaining state. I bumped into an interesting case of
this idea when adding option handling to
a library I was writing.

## DirWalker—Some Background

I'm working on an app that helps organize large numbers of photos
(about 3Tb of them). I needed to be able to traverse all the files in
a set of directory trees, and do it lazily. I wrote a GenServer where
the state is a list of the paths and files still be be traversed, and
the main API returns the next _n_ paths found by traversing the input
paths. The code that returns the next path looks something like this:

``` elixir
defp next_path([ path | rest ], result) do
  stat = File.stat!(path)
  case stat.type do
  :directory ->
    next_path([files_in(path) | rest], result)
  :regular ->
    next_path(rest, [ path | result ])
  true ->
    next_path(rest, result)
  end
end
```

So, if the next file in the list of paths to scan is a directory, we
replace it with the list of files in that directory and call
ourselves. Otherwise if it is a regular file, we add it to the result
and call ourselves on the remaining paths. (The actual code is more
complex, as it unfolds the nested path lists, and knows how to return
individual paths, but this code isn't the point of this post.)

Having added my DirWalker library to Hex.pm, I got a feature
request—could it be made to return the `File.Stat` structure along
with the path to the file?

I wanted to add this capability, but also to make it optional, so I
started coding using what felt like the obvious approach:

``` elixir
defp next_path([ path | rest ], opts, result) do
  stat = File.stat!(path)
  case stat.type do
  :directory ->
    next_path([files_in(path) | rest], result)
  :regular ->
    return_value = if opts.include_stat do
      {path, stat}
    else
      path
    end
    next_path(rest, [ return_value | result ])
  true ->
    next_path(rest, result)
  end
end
```

So, the function now has nested conditionals—never a good sign—but it
is livable-with.

Then I thought, “while I'm making this change, let's also add an
option to return directory paths along with file paths.” And my code explodes in terms of complexity:


``` elixir
defp next_path([ path | rest ], opts, result) do
  stat = File.stat!(path)
  case stat.type do
  :directory ->
    if opts.include_dir_names do
      return_value = if opts.include_stat do
        {path, stat}
      else
        path
      end
      next_path([files_in(path) | rest], [return_value | result])
    else
      next_path([files_in(path) | rest], result)
    end
  :regular ->
    return_value = if opts.include_stat do
      {path, stat}
    else
      path
    end
    next_path(rest, [ return_value | result ])
  true ->
    next_path(rest, result)
  end
end
```

So, lots of duplication, and the code is pretty much unreadable. Time
to put down the keyboard and take Moose for a walk.

As it stands, the options map represents some state—the values of the
two options passed to the API. But we really want to think in terms of
transformations. So what happens if we instead think of the options as
transformers?

Let's look at the `include_stat` option first. If set, we want to
return a tuple containing a path and a stat structure; otherwise we
return just a path. The first case is a function that looks like this:

``` elixir
fn path, stat -> { path, stat } end
```

and the second case looks like this:

``` elixir
fn path, _stat -> path end
```

So, if the `include_stat` value in our options was one of these two
functions, rather than a boolean value, our main code becomes simpler:

``` elixir
defp next_path([ path | rest ], opts, result) do
  stat = File.stat!(path)
  case stat.type do
  :directory ->
    if opts.include_dir_names do
      return_value = opts.include_stat.(path, stat)
      next_path([files_in(path) | rest], [return_value | result])
    else
      next_path([files_in(path) | rest], result)
    end
  :regular ->
    return_value = opts.include_stat.(path, stat)
    next_path(rest, [ return_value | result ])
  true ->
    next_path(rest, result)
  end
end
```

We can do the same thing with `include_dir_names`. Here the two functions are

``` elixir
fn (path, result)  -> [ path | result ] end)
```

and

``` elixir
fn (_path, result) -> result end

```

and now our main function becomes:

``` elixir
defp next_path([ path | rest ], opts, result) do
  stat = File.stat!(path)
  case stat.type do
  :directory ->
    return_value = opts.include_stat.(path, stat)
                |> opts.include_dir_names.(result)
    next_path([files_in(path) | rest], return_value)
  :regular ->
    next_path(rest, [ opts.include_stat.(path, stat) | result ])
  true ->
    next_path(rest, result)
  end
end
```

Changing the options from being simple state into things that transform values according the the _meaning_ of each option has tamed the complexity of the `next_path` function.

But we don't want the users of our API to have to set up transforming functions—that would force them to know our internal implementation details. So on the way in, we want to map their options (which are booleans) into our functions.

``` elixir
defp setup_mappers(opts) do
  %{
    include_stat:
      one_of(opts[:include_stat],
             fn (path, _stat) -> path         end
             fn (path, stat)  -> {path, stat} end),
    include_dir_names:
      one_of(opts[:include_dir_names],
             fn (_path, result) -> result            end, 
             fn (path, result)  -> [ path | result ] end)
  }
end

defp one_of(bool, if_false, if_true) do
  if bool, do: if_true, else: if_false
end
```

If you're interested in all the gritty details, the code is [in Github](https://github.com/pragdave/dir_walker/blob/master/lib/dir_walker.ex).

### My Takeaway

I wrote my first OO program (in Simula) back in 1974 (which is
probably before most Elixir programmers were born—sigh). During the
intervening years, I've developed many reflexes that made
object-oriented development easier. And now I'm having to rethink that
tacit knowledge.

Programming in Elixir encourages me to move away from state and to
think about transformations. As I force myself to apply this
change in thinking at all levels of my code, I discover interesting
and delightful new patterns of development.

And that's why I'm still having a blast, hacking out code, after all
these years. 







