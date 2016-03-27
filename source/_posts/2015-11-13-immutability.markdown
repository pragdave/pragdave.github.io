---
layout: post
title: "Immutability, State, and Functions"
date: 2015-11-13 12:42:58 -0600
comments: true
categories:
---
Let's start with the obligatory call to authority:

> In functional programming, programs are executed by evaluating expressions, in contrast with imperative programming where programs are composed of statements which change global state when executed. Functional programming typically avoids using mutable state.
>
>  <cite>https://wiki.haskell.org/Functional_programming</cite>

Well, that seems pretty definitive. “Functional programming typically avoids mutable state.” Seems pretty clearcut.

But it's wrong.

Explaining why I thing that will involve a trip down the path I've been exploring over the last year or so, as I have tried to crystalize my thinking on the new styles of programming, and the role of transformation as both a top-down and bottom-up coding and design technique.

Let's start by thinking about state.

## Where Does a Program Keep Its State?

Programs run on computers, and at the lowest level their model of computation is tied to that of the machines on which the execute. Down at that low level, the state of a program is the state of the computer—the values in memory and the values in registers.[^fn:sideeffect] Some of those registers are used internally by the processor for housekeeping. Perhaps the most important of these is the program counter (PC). You can think of the PC as a pointer to the next instruction to execute.

We can take this up a level.  Here's a simple program:

``` elixir
"Cat"
|> String.downcase       # => "cat"
|> String.codepoints     # => [ "c", "a", "t" ]
|> Enum.sort             # => [ "a", "c", "t" ]
```
The `|>` notation is syntactic sugar for passing the result of a function as the first parameter of the next function. The preceding code is equivalent to

``` elixir
Enum.sort(String.codepoints(String.downcase("Cat")))
```

Thrilling stuff, eh?

Let's image we'd just finished executing the first  line. What is our state?

Somewhere in memory, there's a data structure representing the string "Cat".   That's the first part of our state.  The second part  is the value of the program counter. Logically, it's pointing to the start of line 2.

Execute one more line.   `String.downcase`  is passed the string "Cat". The result, another string containing "cat", is stored in a different place in our computer. The PC now points to the start of line 3.

And so it goes. With each step, the state of the computer  changes, meaning that the state of our program changes.

State is not immutable.

### Is This Splitting Hairs?

Yes and no.

Yes, because no one would argue that the state of a computer is unchanged during the execution of a program.

No, because people still say that immutable state is a characteristic of  functional programming. That's wrong. Worse, that also leads us to model programming wrongly. And that's what the rest of this post is about.

## What _Is_ Immutable?
Let's get this out of the way first. In a functional program, values are immutable. Look at the following code.

``` elixir
person = get_user_details("Dave")
debug_dump(person)
do_something_with(person)
debug_dump(person)
```

Let's assume that `get_user_details` returns some structured data,
which we dump out to some log file on line two. In a language with
immutable values, that data can never be changed. We know that nothing
in the function `do_something_with` can change the data referenced by
the `person` variable, and so the debugging we write on line 4 is
guaranteed to be the same as that created on line 2.

If we wanted to change the information for Dave, we'd have to create
copy of Dave's data:

``` elixir
person1 = change_subscription_status(person, :active)
```

Now we have the variable `person` bound to the initial value of the
Dave person, and `person1` references the version with a
changed subscription status.

If you've been using languages with mutable data, at this point you'll
have intuitively created a mental picture where `person` and `person1`
reference different chunks of memory. And you might be thinking that
this is remarkably inefficient. But in an immutable world, it needn't
be. Because the runtime knows that the original data will never be
changed, it can reuse much of it in `person1`. In principle, you could
have a runtime that represented new values as nothing more that a set
of changes to be applied to the original.

Anyway, back to state.

``` elixir
person = get_user_details("Dave")
do_something_with(person)
person1 = change_subscription_status(person, :active)
IO.inspect person1
~~~

Let's represent the state using a tuple containing the pseudo program
counter and the values bound to variables.

| Line | `person` | `person1` |
+------+----------+-----------+
|  1   |  —       |  —        |
|  2   |  value1  |  —        |
|  3   |  value1  |  —        |
|  4   |  value1  |  value2   |







[^fn:sideeffect]: Of course, in the real world, we also have to thing about all the extrinsic state—the real-time clock, the state of I/O devices and so on.
