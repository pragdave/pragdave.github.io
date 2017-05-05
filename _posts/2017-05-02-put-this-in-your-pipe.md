---
title:  Put This in Your Pipe(line)
layout: post
tag:    programming elixir
---

We know that Elixir programming is about transforming state, and `|>`
operator plays the starring role in making that happen. But sometimes
you can't just change two named functions together—the output of one
doesn't match the first parameter of the next. Until I discovered this
trick, I had to break the pipeline and assert the interim result to a
local variable, or write a private function that massaged the value
into the right format.

This video shows you some ways of overcoming this.
It's probably not new, ut I haven't seen the technique in code that
I've read.

<a href="https://player.vimeo.com/216107561" title="click to
play video"> 
{% image mix_generator.png  class:img-fluid %}
</a>
