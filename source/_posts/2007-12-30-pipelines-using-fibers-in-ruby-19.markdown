---
layout: post
title: "Pipelines Using Fibers in Ruby 1.9"
date: 2007-12-30 19:00:00 -0600
comments: true
categories: []
---

Users of the command line are familiar with the idea of building
pipelines: a chain of simple commands strung together to the output of
one becomes the input of the next. Using pipelines and a basic set of
primitives, shell users can accomplish some sophisticated
tasks. Here’s a basic Unix shell pipeline that reports the ten longest
.tip files in the current directory, based on the number of lines in
each file:



``` sh
wc -l *.tip | grep \.tip | sort -n | tail -10

```

Let’s see how to add something similar to Ruby. By the end of this set of two articles, we’ll be able to write things like

``` ruby
puts (even_numbers | tripler | incrementer | multiple_of_five ).resume

```

and a palindrome finder using blocks:

``` ruby
words = Pump.new %w{Madam, the civic radar rotator is not level.}
is_palindrome = Filter.new {|word| word == word.reverse}

pipeline = words .| {|word| word.downcase.tr("^a-z", '') } .| is_palindrome

while word = pipeline.resume
  puts word
end

```

Great code? Nope. But getting there is fun. And, who knows? The
techniques might well be useful in your next project.

### A Daily Dose of Fiber

Ruby 1.9 adds support for Fibers. At their most basic, let you create
simple generators (much as you could do previously with blocks. Here’s
a trivial example: a fiber that generates successive Fibonacci
numbers:

``` ruby
fib = Fiber.new do
  f1 = f2 = 1
  loop do
    Fiber.yield f1
    f1, f2 = f2, f1 + f2
  end
end

10.times { puts fib.resume }

```

A fiber is somewhat like a thread, except you have control over when
it gets scheduled. Initially, a fiber is suspended. When you resume
it, it runs the block until the block finishes, or it hits
a `Fiber.yield`. This is similar to a regular block yield: it suspends
the fiber and passes control back to the `resume`. Any value passed
to `Fiber.yield` becomes the value returned by `resume`.

By default, a fiber can only yield back to the code that resumed
it. However, if you require the `"fiber"`library, Fibers get extended
with a `transfer` method that allows one fiber to transfer control to
another. Fibers then become fully fledged coroutines. However, we
won’t be needing all that power today.

Instead, let’s get back to the idea of creating pipelines of
functionality in code, much as you can create pipelines in the shell.

As a starting point, let’s write two fibers. One’s a generator—it
creates a list of even numbers. The second is a consumer. All it does
it accept values from the generator and print them. We’ll make the
consumer stop after printing 10 numbers.

``` ruby
evens = Fiber.new do
value = 0
loop do
  Fiber.yield value
  value += 2
end
end

consumer = Fiber.new do
10.times do
  next_value = evens.resume
  puts next_value
end
end

consumer.resume

```

Note how we had to use `resume` to kick off the consumer. Technically,
the consumer doesn’t have to be a Fiber, but, as we’ll see in a
minute, making it one gives us some flexibility.

As a next step, notice how we’ve created some coupling in this
code. Our `consumer` fiber has the name of the evens generator coded
into it. Let’s wrap both fibers in a method, and pass the name of the
generator into the `consumer` method.

``` ruby
def evens
Fiber.new do
  value = 0
  loop do
    Fiber.yield value
    value += 2
  end
end
end

def consumer(source)
Fiber.new do
  10.times do
    next_value = source.resume
    puts next_value
  end
end
end

consumer(evens).resume

```

OK. Let’s add one more fiber to the weave. We’ll create a filter that
only passes on numbers that are multiples of three. Again, we’ll wrap
it in a method.


``` ruby
def evens
Fiber.new do
  value = 0
  loop do
    Fiber.yield value
    value += 2
  end
end
end

def multiples_of_three(source)
Fiber.new do
  loop do
    next_value = source.resume
    Fiber.yield next_value if next_value % 3 == 0
  end
end
end

def consumer(source)
Fiber.new do
  10.times do
    next_value = source.resume
    puts next_value
  end
end
end

consumer(multiples_of_three(evens)).resume

```

Running this, we get the output

```
0
6
12
18
. . .

```

This is getting cool. We write little chunks of code, and then combine
them to get work done. Just like a pipeline. Except…

We can do better. First, the composition looks backwards. Because
we’re passing methods to methods, we write

``` ruby
consumer(multiples_of_three(evens))

```

Instead, we’d like to write

``` ruby
evens | multiples_of_three | consumer

```

Also, there’s a fair amount of duplication in this code. Each of our
little pipeline methods has the same overall structure, and each is
coupled to the implementation of fibers. Let’s see if we can fix this.

### Wrapping Fibers

As is usual when we’re refactoring towards a solution, we’re about to
get really messy. Don’t worry, though. It will all wash off, and we’ll
end up with something a lot neater.

First, let’s create a class that represents something that can appear
in our pipeline. At it’s heart is the`process` method. This reads
something from the input side of the pipe, then “handles” that
value. The default handling is to write that value to the output side
of the pipeline, passing it on to the next element in the chain.


``` ruby
class PipelineElement

  attr_accessor :source

  def initialize
    @fiber_delegate = Fiber.new do
      process
    end
  end

  def resume
    @fiber_delegate.resume
  end

  def process
    while value = input
      handle_value(value)
    end
  end

  def handle_value(value)
    output(value)
  end

  def input
    source.resume
  end

  def output(value)
    Fiber.yield(value)
  end
end
```

When I first wrote this, I was tempted to make `PipelineElement` a
subclass of `Fiber`, but that leads to coupling. In the end, the
pipeline elements delegate to a separate `Fiber` object.

The first element of the pipeline doesn’t receive any input from prior
elements (because there are no prior elements), so we need to override
its `process` method.


``` ruby
class Evens < PipelineElement
   def process
     value = 0
     loop do
       output(value)
       value += 2
     end
   end
end

evens = Evens.new
```

Just to make things more interesting, we’ll create a
generic `MultiplesOf filter, so we can filter based on any number, and
not just 3:`

``` ruby
class MultiplesOf < PipelineElement
  def initialize(factor)
    @factor = factor
    super()
  end
  def handle_value(value)
    output(value) if value % @factor == 0
  end
end

multiples_of_three = MultiplesOf.new(3)
multiples_of_seven = MultiplesOf.new(7)
```

Then we just knit it all together into a pipeline:

``` ruby
multiples_of_three.source = evens
multiples_of_seven.source = multiples_of_three

10.times do
  puts multiples_of_seven.resume
end
```

We get 0, 42, 84, 126, 168, and so on as output. (Any output stream
that contains 42 must be correct, so no need for any unit tests here.)

But we’re still a little way from our ideal of being able to pipe
these puppies together. It’s a good thing that Ruby let’s us override
the “|” operator. Up in class`PipelineElement`, define a new method:

``` ruby
def |(other)
  other.source = self
  other
end
```

This allows us to write:

``` ruby
10.times do
  puts (evens | multiples_of_three | multiples_of_seven).resume
end
```
or even:

``` ruby
pipeline = evens | multiples_of_three | multiples_of_seven

10.times do
  puts pipeline.resume
end
```

Cool, or what?


### In The Next Thrilling Installment

The next post will take these basic ideas and tart them up a bit,
allowing us to use blocks directly in pipelines. We’ll also reveal why
our `PipelineElement` class I just wrote is somewhat more complicated
than might seem necessary. In the meantime, here’s the full source of
the code so far.

``` ruby
class PipelineElement

  attr_accessor :source

  def initialize
    @fiber_delegate = Fiber.new do
      process
    end
  end

  def |(other)
    other.source = self
    other
  end

  def resume
    @fiber_delegate.resume
  end

  def process
    while value = input
      handle_value(value)
    end
  end

  def handle_value(value)
    output(value)
  end

  def input
    source.resume
  end

  def output(value)
    Fiber.yield(value)
  end
end

##
# The classes below are the elements in our pipeline
#
 class Evens < PipelineElement
   def process
     value = 0
     loop do
       output(value)
       value += 2
     end
   end
 end

class MultiplesOf < PipelineElement
  def initialize(factor)
    @factor = factor
    super()
  end
  def handle_value(value)
    output(value) if value % @factor == 0
  end
end

evens = Evens.new
multiples_of_three = MultiplesOf.new(3)
multiples_of_seven = MultiplesOf.new(7)

pipeline = evens | multiples_of_three | multiples_of_seven

10.times do
  puts pipeline.resume
end
```


