---
layout: post
title: "Telling, Asking, and the Power of Jargon"
date: 2014-02-11 09:50:22 -0600
comments: true
categories: 
---

## Some (Almost) Irrelevant Background

In 1993, the US Congress and the military hashed out a policy regarding
sexual orientation among those who served. Prior to this,
homosexuality was effectively banned. After the enactment of the new
policy in 1994, it was acceptable to be gay in the military as long as
you kept quiet about it. And, to help keep things quiet, the policy
also prohibited others from questioning anyone about their
orientation. The policy was called "Don't Ask, Don't Tell."

Clearly this was at best a transitional policy—although intended to
open the closet door and allow homosexuals to serve, it also had the
very negative effect of stigmatizing their status. They were no longer
in the closet—they were that nasty bump under the carpet.

DADT was repealed in 2011, as the Supreme Court has ruled that
sexual orientation cannot be considered by the military.

## Some (Slightly Less) Irrelevant Background

Back in 2003, Andy and I had a regular column in IEEE Software. In the
first issue of the year, we wrote an article called [The Art of Enbugging](http://www.ccs.neu.edu/research/demeter/related-work/pragmatic-programmer/jan_03_enbug.pdf). It
was about reducing the bugs in code by reducing coupling. We talked
about two kinds—behavior coupling (with references to the Law of
Demeter) and state coupling.

The state coupling discussion was about encapsulation, and we called it
"Tell, Don't Ask." (I think Andy coined the phrase, basing it off the
DADT meme).

The idea of Tell, Don't Ask, is that objects should take
responsibility for their state, and should not allow other objects to
bypass encapsulation and mess with the state. For example, we might
have a counter class. A good implementation might be

``` ruby
class Counter
  def initialize(initial_value=0)
     @value = initial_value
  end
  def increment(increment=1)
    @value.tap do
      @value += increment
    end
  end
end

c = Counter.new
5.times { c.increment }
```

Contrast that with one that leaks state:

``` ruby
class Counter
  attr_accessor :value
  def initialize(initial_value=0)
     @value = initial_value
  end
  def increment(increment=1)
    @value.tap do
      @value += increment
    end
  end
end

c = Counter.new
5.times do
  val = c.value
  val += 1
  c.value = val
end
```

Here, our `Counter` class has been relegated to being a data
store. Even through it knows how to increment its state, it provides
an API (via `attr_accessor`) to allow third parties to access and
manipulate that state.

Maybe one day the client comes to us and says that there's a new
business rule—the counter should cycle through values, rather than
incrementing forever. So we reimplement it:

``` ruby
class Counter
  attr_accessor :value
  def initialize(initial_value=0, max)
     @initial_value = initial_value
     @value         = initial_value
     @max           = max
  end
  def increment(increment=1)
    @value.tap do
      @value += increment
      @value  = @initial_value if @value > @max
    end
  end
end
```

Our implementation looks good, so we're dismayed when a colleague tells us
there's a bug:

```
c = Counter.new(0, 5)
10.times do
  val = c.value
  val += 1
  c.value = val
  puts c.value
end
```

It didn't reset at 5, they claim. And they're right, because the code
calling our object bypassed all the logic we added.

Rather than telling our object to increment its state, it fetched the
state, incremented it, and stored it back.

And this is why we say "Tell, Don't Ask."

Objects encapsulate state. Don't break that encapsulation.


# Ask, Don't Tell

Yesterday, Avdi Grimm tweeted about an article by Pat Shaughnessy
called [Use An Ask, Don’t Tell Policy With Ruby](http://patshaughnessy.net/2014/2/10/use-an-ask-dont-tell-policy-with-ruby).

The intent of the article is probably best summarized by this
paragraph in the middle:

> Don’t imagine you are the computer. Don’t think about how to solve a
> problem by figuring out what Ruby should do and then writing down
> instructions for it to follow. Instead, start by asking Ruby for the
> answer.

This idea is illustrated with before-and-after code snippets.

In fact, the article makes a good point. But it uses the wrong
terminology. The design practices it illustrates are nothing to do
with telling or asking. Instead they contrast _bottom-up_ versus
_top-down_ coding styles. In the bottom-up style, he solves the lowest
level problem (reading a file into an array of lines), then solves the
next higher level (find a target word in the array of lines), and so
on.

In the top-down solution, Pat starts by assuming he has the required
functionality to solve his problem, and then refines it by adding
successively lower levels of detail. Wirth called this approach
_Stepwise Refinement_.

My concern was that the article conflated the ideas of
"top-down/bottom-up" with "tell, don't ask." This kind of mingling
weakens the meaning of both ideas. In Ask, Don't Tell, "asking Ruby"
means _do top-down design_ and telling Ruby means _do bottom up
design._ In Tell, Don't Ask, tell means _instruct an object to do
something" and ask means to do something that _bypasses an object's
encapsulation_. There's nothing in common between the two uses. But if
people were to get used to having both around, the meanings would
become blurred, and the concepts would become less valuable.


# Back to Pat's Article

I was also nervous about the introduction of the word "Functional" in
the article. Here's the context:

### Learning From Functional Languages

In my opinion this code is better than what I showed earlier. Why?
They both work equally well. What’s the difference? Let’s take a look
at them side-by-side.

<table>
<tr><th>Imperative</th><th>&nbsp;</th><th>Functional</th></tr>
<tr>
<td style="vertical-align: top">
``` ruby
def parse(lines, target)
  flag = false
  result = []
  lines.each do |line|
    if line.include?(target)
      flag = true
    end
    result << line if flag
  end
  result
end
```
</td>
<td></td>
<td style="vertical-align: top">
``` ruby
def after(lines, target)
  target_index = (0..lines.size-1).detect do |i|
    lines[i].include?(target)
  end
  target_index ? lines[target_index..-1] : []
end
```
</td>
</tr>
</table>

I think I'd argue that both pieces of code were equally
functional. Perhaps the "functional" one is closer to nirvana as it
doesn't mutate the result array on each step, but ultimately neither
is a particularly functional style.

Again, does this matter? Yes, and for the same reason that the
Ask/Ask-Tell/Tell distinction does.

The Ruby community has shown an increasing tendency to say that
methods such as `detect` and `inject` make Ruby a functional
language. (Those fearing the wrath of the future moderate this by
saying Ruby has "functional elements" or can by written in a
"functional style.")

But this is not true. Functional programming is about
expressions. It's about composition. It's about transforming data, not
storing it. 

Ruby (and Python, and most other languages whose immediate parents are
object-based or imperative) is not a functional language.


# Names Are Important

When programmers talk to programmers, they use jargon.  By using
jargon words (or terms of the trade, as the fancy folk call them), we
communicate efficiently and effectively—we interact at a much deeper
level. Each piece of jargon is a shortcut for a whole lot of shared
experience, and by using jargon words, we root our conversation at a
deeper level.

But jargon has to be protected. Consistently misuse a jargon word, and
it loses it's deeper meaning. It it no longer evocative—it's just a
noise. And if our jargon becomes diluted, then we as an industry
become less efficient at communicating—we have to make explicit what
was once tacit. Our talk becomes pedestrian and pedantic, mechanical
rather than allusive. We lose the superpower of description. We become
a community which, like the 1990's military, doesn't ask and doesn't tell.

And where's the fun in that?




<!--  LocalWords:  stigmatizing Demeter meme def attr accessor API
 -->
<!--  LocalWords:  Avdi tweeted Shaughnessy Wirth conflated
 -->
