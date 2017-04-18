---
title:  An Elixir Project Generator
layout: post
tag:    programming elixir
---

For the last year, I've had a ritual when creating new Elixir projects. 

I'd type `mix new my_app`, then spend the next 2 minutes tidying up
the generated files: removing the comments that obscured the code,
moving the volatile stuff in `mix.exs` into module attributes, adding
commas and the ends of lists, and so on.

Last month I decided that by investing just a couple of weeks, I could
save myself those two-minute housekeeping sessions. And so was
born [`mix_generator`](https://github.com/pragdave/mix_generator)
and [`mix_template`](https://github.com/pragdave/mix_template), an
open and extendable templating system for creating new projects.

I made a screencast showing how to use and extend it:


<a href="https://player.vimeo.com/video/213689412" title="click to play video">
{% image mix_generator.png  class:img-fluid %}
</a>
