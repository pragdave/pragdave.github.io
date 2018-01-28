---
title: Dynamix Supervisors replace :simple_one_for_one
layout: post
comments: true
tags: programming elixir
---

Elixir 1.6 replaced the old `:simple_one_for_one` supervisor strategy
with shiny the new `DynamicSupervisor` module.

As well as giving you the old ability to spawn multiple instances of the same server, dynamic supervisors let you run different server modules under the same supervisor, all created at runtime.

Here's a short video showing how I changed my Hangman game over.

<iframe src="https://player.vimeo.com/video/253159406?title=0&byline=0&portrait=0" width="640" height="360" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>