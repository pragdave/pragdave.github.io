---
layout: post
title: "Pipelines Using Fibers in Ruby 1.9—Part II"
date: 2008-01-01 19:00:00 -0600
comments: true
categories: []
---

In the <a href="http://pragdave.pragprog.com/post/70437993965/pipelines-using-fibers-in-ruby-1-9">previous post</a>, I developed a class called `PipelineElement`. This made it relatively easy to create elements that act as producers and filters in a programmatic pipeline. Using it, we could write Ruby 1.9 code like:



```
    10.times do
      puts (evens | multiples_of_three | multiples_of_seven).resume
    end

```



The construct in the loop is a pipeline containing three chunks of code: a generator of even numbers, a filter that only passes multiples of three, and another filter that passes multiples of seven. Numbers are passed from the producer to the first filter, and then from that filter to the next, until finally popping out and being made available to `puts`.


However, creating these pipeline elements is still something of a pain. It turns out that we can simplify things when it comes to creating filters. In the implementation I’ll show here, we’ll only handle the case of simple _transforming filters_—filters that take an input, do something to it, and write the result to the filter chain.


Let’s revisit the `PipelineElement` class



```
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

```



The `process` method is the driving loop. It reads the next input from the pipeline, then calls`handle_value` to deal with it. In the base class, `handle_value` simply echoes the input to the output-real filters subclass `PipelineElement` and subclass this method.


Let’s make a small change to the `handle_value` method.



```
    def handle_value(value)
      output(transform(value))
    end

    def transform(value)
      value
    end

```



By doing this, we’ve split the transformation of the incoming value into a separate method. And the work done by this method no longer uses any of the state in the PipelineElement object, which means we can also do it in a block in the caller’s context. Let’s change our `PipelineElement` class to allow this. We’ll have the constructor take an optional block, and we’ll use that block in preference to the`transform`. Here’s another listing, showing just the changed methods.



```
    class PipelineElement

      def initialize(&block)
        @transformer = block || method(:transform)
        @fiber_delegate = Fiber.new do
          process
        end
      end

      # ...

      def handle_value(value)
        output(@transformer.call(value))
      end
    end

```



This illustrates a cool (and underused) feature of Ruby. Method objects (created with the `method(...)`call) are duck-typed with proc objects: we can use `.call(params)` on both. This is a great way of letting users of a class change its behavior either by subclassing and overriding a method, or by simply passing in a block.


With this change in place, we can now write transforming filters using blocks. This is a lot more compact that the previous subclassing approach.



```
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

    tripler     = PipelineElement.new {|val| val * 3}
    incrementer = PipelineElement.new {|val| val + 1}

    5.times do
      puts (evens | tripler | incrementer ).resume
    end

```



This outputs 1, 7, 13, 19, and 25.


**Different Kinds of Filter**


This approach works well if all we want is transforming filters. But what if we would also like to simplify filters that either pass of don’t pass values based on some criteria? A block would seem like a great way of specifying the condition, but we’ve already used our one block parameter up. Subclassing to the rescue. We can create two subclasses, `Transformer` and `Filter`. One sets the `@transformer` instance variable to any block it is passed. The other sets `@filter`. Here’s the relevant code:



```
    class PipelineElement

      attr_accessor :source

      def initialize(&block)
        @transformer  ||= method(:transform)
        @filter       ||= method(:filter)
        @fiber_delegate = Fiber.new do
          process
        end
      end

      # ...

      def handle_value(value)
        output(@transformer.call(value)) if @filter.call(value)
      end

      def transform(value)
        value
      end

      def filter(value)
        true
      end
    end

    class Transformer < PipelineElement
      def initialize(&block)
        @transformer = block
        super
      end
    end

    class Filter < PipelineElement
      def initialize(&block)
        @filter = block
        super
      end
    end

```



Thus equipped, we can write:



```
    tripler          = Transformer.new {|val| val * 3}
    incrementer      = Transformer.new {|val| val + 1}
    multiple_of_five = Filter.new {|val| val % 5 == 0}

    5.times do
      puts (evens | tripler | incrementer | multiple_of_five ).resume
    end

```



**Moving The Blocks Inline**


Our final hack lets us move the blocks directly into the pipeline.


Let’s look at the actual pipeline code:



```
    puts (evens | tripler | incrementer | multiple_of_five ).resume

```



Those pipe characters are simply calls to the | method in class `PipelineElement`. And methods can take block arguments, right? So what stops us writing



```
    puts (evens | {|v| v*3} | {|v| v+1} | multiple_of_five ).resume

```



It turns out that Ruby stops us. The brace characters are taken to be hash parameters, not blocks, so Ruby gets its knickers in a twist. Fortunately, that’s easily fixed by making the method calls explicit.



```
    puts (evens .| {|v| v*3} .| {|v| v+1} .| multiple_of_five ).resume

```



Now we just need to make the | method accept an optional block. If the block is present, we use it to create a new transformer.



```
    def |(other=nil, &block)
      other = Transformer.new(&block) if block
      other.source = self
      other
    end

```



Ruby 1.9 lets you chain method calls across lines, so we can tidy up our pipeline visually.



```
    5.times do
      puts (evens 
            .| {|v| v*3}
            .| {|v| v+1}
            .| multiple_of_five 
           ).resume
    end

```



A Palindrome Finder


Let’s finish with another trivial example. We’ll create a generic producer class that takes a collection and passes it, one element at a time, into the pipeline.



```
    class Pump < PipelineElement
      def initialize(source)
        @source = source
        super()
      end
      def process
        @source.each {|item| Fiber.yield item}
        nil
      end
    end

```



Now we can write a simple palindrome finder (a palindrome is a word which is the same when spelled backwards).



```
    words = Pump.new %w{Madam, the civic radar rotator is not level.}
    is_palindrome = Filter.new {|word| word == word.reverse}

    pipeline = words .| {|word| word.downcase.tr("^a-z", '') } .| is_palindrome

    while word = pipeline.resume
      puts word
    end

```



This outputs: madam, civic, radar, rotator, level.


But what if we instead want to show each word in the input stream, and flag it if it is a palindrome? That’s easily done, but we won’t do it the easy way. Instead, let’s show a more convoluted method, because it might be useful in the general case.


There’s no law to say that a transformer that receives a string as input has to write a string as output. It could, if it wanted to, write an array. Or a structure. So we could write:



```
    WordInfo = Struct.new(:original, :forwards, :backwords)

    words = Pump.new %w{Madam, the civic radar rotator is not level.}

    normalize = Transformer.new {|word| [word, word.downcase.tr("^a-z", '')] }

    to_word_info = Transformer.new do |word, normalized|
      reversed = normalized.reverse
      WordInfo.new(word, normalized, reversed)
    end

    formatter = Transformer.new do |word_info|
      if word_info.forwards == word_info.backwords
        "'#{word_info.original}' is a palindrome"
      else
        "'#{word_info.original}' is not a palindrome"
      end
    end

    pipeline = words | normalize | to_word_info | formatter

    while word = pipeline.resume
      puts word
    end

```



This outputs



```
    'Madam,' is a palindrome
    'the' is not a palindrome
    'civic' is a palindrome
    'radar' is a palindrome
    'rotator' is a palindrome
    'is' is not a palindrome
    'not' is not a palindrome
    'level.' is a palindrome

```



**So, What’s the Point?**


>


Is this a great way of writing a palindrome finder? Not really. But…


What we’ve done here is turned the way a program works on it’s head. We’ve written chunks of isolated code, each of which either filters or transforms an input. We’ve then independently knitted these chunks together. That’s a high degree of decoupling. We can also leave it until runtime to determine what gets put into the pipeline (and the order that it appears in the pipeline), which means we can move more power into the hands of our users.


Could we have done all this without Fibers? Of course. Could we do it without Ruby 1.9? Absolutely. But sometimes factors come together which lead us to experiment with new ways of thinking about our code.


This pipeline stuff is not revolutionary, and it isn’t generally applicable. But it’s fun to play with. And, for me, that’s the main thing.


**A Wee Postscript**


All this content is stuff that I decided not to include in the <a href="http://pragprog.com/titles/ruby3">third edition of the PickAxe</a>. It didn’t work in the section on fibers, because it uses programming techniques not yet covered. It didn’t work later because, as an example of various programming techniques, it is just too long.

