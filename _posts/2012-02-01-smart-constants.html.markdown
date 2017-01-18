---
layout: post
title: Smart Constants
date: 2012-02-01
comments: true
categories: []
---

I’ve been really enjoying James Edward Gray II’s <a
href="http://subinterest.com/rubies-in-the-rough">Rubies in the Rough</a> articles. Every couple of weeks, he publishes something that
is guaranteed to get me thinking about some aspect of coding I hadn’t
considered before.


His <a
href="http://subinterest.com/rubies-in-the-rough/10-test-driving-an-algorithm-part-1"> latest
article</a> is part I of an exploration of an algorithm for the <a
href="http://puzzlenode.com/puzzles/11-hitting-rock-bottom">Hitting Rock Bottom</a> problem posed by Gregory Brown & Andrea Singh. At
its core, the problem asks you to simulate pouring water into a 2D
container, filling it using a simple set of rules.

As I was coding up my solution, I found I had code like

``` ruby
case 
  when cave.cell_below == " "        then cave.move_down
  when cave.cell_to_the_right == " " then cave.move_right
  # ...
  else
    cave.move_up
    cave.move_left until cave.cell == "~"
    # ...
```

Here ” “ is a cell containing air, and ”~” a watery cell. So clearly
we should create some named constants for that:

``` ruby
AIR   = " "
WATER = "~"

case 
  when cave.cell_below == AIR        then cave.move_down
  when cave.cell_to_the_right == AIR then cave.move_right
  # ...
  else
    cave.move_up
    cave.move_left until cave.cell == WATER
    # ...
```

But it occurred to me that we could use Ruby’s singleton methods to
give AIR and WATER a little smarts:

``` ruby
WATER = "~"
AIR   = " "
[WATER, AIR].each do |content|
  def content.in?(cell)
    cell == self
  end
end

# ...
case 
when AIR.in?(cave.cell_below)        then cave.move_down
when AIR.in?(cave.cell_to_the_right) then cave.move_right
# ...
else
  # ...
  cave.move_left until WATER.in?(cave.cell) if AIR.in?(cave.cell)
```

Now you could argue that the cave object should do this: cave.watery?,
or that the individual elements in the cave should be objects that
know their moisture content, rather than simply characters. I don’t
agree with the first (simply because the cave is the container, and
the water/air is the separate stuff that goes into that container). I
have a lot of sympathy for the second, and I’d probably end up there
given a sufficiently large nudge during a refactoring. 

``` ruby
WATER = "~"
AIR   = " "
[WATER, AIR].each do |content|
  def content.in?(cell)
    cell == self
  end
end

# ...
case 
when AIR.in?(cave.cell_below)        then cave.move_down
when AIR.in?(cave.cell_to_the_right) then cave.move_right
# ...
else
  # ...
  cave.move_left until WATER.in?(cave.cell) if AIR.in?(cave.cell)  
```

But, for the problem at hand, simply decorating the two constants with
a domain method seems to result in code that is a lot more
readable. It isn’t a technique I’d used before, so I thought I’d
share.


(And remember to check out <a
href="http://subinterest.com/rubies-in-the-rough">Rubies in the Rough</a>…)

