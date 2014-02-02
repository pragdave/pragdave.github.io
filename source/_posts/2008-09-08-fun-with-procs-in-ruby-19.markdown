---
layout: post
title: "Fun with Procs in Ruby 1.9"
date: 2008-09-08 19:00:00 -0600
comments: true
categories: ["ruby"]
---

Ruby 1.9 adds a lot of features to `Proc` objects.

Currying is the ability to take a function that accepts _n_ parameters
and fffgenerate from it one of more functions with some parameter
values already filled in. In Ruby 1.9, you create a curry-able proc by
cthe `curry` method on it. If you subsequently call this curried proc
with fewer parameters than it expects, it will not execute. Instead,
it returns a new proc with those parameters already bound.

Let’s look at a trivial example. Here’s a proc that simply adds two
values:

```ruby
plus = lambda {|a,b| a + b}
puts plus[1,2]
```

I’m using the `[ ]` syntax to invoke the proc with arguments, in this
case 1 and 2. The code will print 3.

Now let’s have some fun.

``` ruby
curried_plus = plus.curry n
# create two procs based on plus, but with the first parameter 
# already set to a value
plus_two = curried_plus[2]
plus_ten = curried_plus[10]

puts plus_two[3]
puts plus_ten[3]
```

On line 1, I create a curried version of the `plus` proc. I then call
it twice, but both times I only pass it one parameter. This means it
cannot execute the body. Instead, each time it returns a new proc
which is like the original, but which has the first parameter preset
to either 2 or 10. In the last two lines, I call these two new procs,
supplying the missing parameter. This means they can execute normally,
and the code outputs 5 and 13.

You can have a lot of fun with currying, but that’s not why we’re here today.

Over the weekend, Matz added a new method to the `Proc` class. You can
now use `Proc#===` as an alias for `Proc.call`. So, why on earth would
you want to do that? Well, remember that `===` is used to match terms
in a case statement. Over of the <a
href="http://www.aimred.com/news/developers/2008/08/14/unlocking_the_power_of_case_equality_proc/">AimRed blog</a>, they noted that this feature could be used to make the
matching in case statements actually execute code. In their example,
they manually added the `===`method to class `Proc`

``` ruby
class Proc
  def ===( *parameters )
    self.call( *parameters )
  end
end
```

Then you can write something like

``` ruby
sunday = lambda{ |time| time.wday == 0 }
monday = lambda{ |time| time.wday == 1 }
# and so on...

case Time.now
when< sunday
<  puts "Day of rest"
when monday
  puts "work"
# ...
end
```

See how that works? As Ruby executes the case statement, it looks at
each of the parameters of the`when` clauses in turn. For each, it
invokes its `===` method, passing that method the original case
discriminator (Time.now in this example). But with the
new `===` method in class `Proc`, this will now execute the proc,
passing it Time.now as a parameter.

While updating the <a
href="http://pragprog.com/titles/ruby3">PickAxe</a>, I noticed that
Matz liked this so much that it is now part of 1.9. And it means we
can combine this trick with currying to write some fun code:


``` ruby
is_weekday = lambda {|day_of_week, time| time.wday == day_of_week}.curry

sunday    = is_weekday[0]
monday    = is_weekday[1]
tuesday   = is_weekday[2]
wednesday = is_weekday[3]
thursday  = is_weekday[4]
saturday  = is_weekday[6]

case Time.now
when sunday
  puts "Day of rest"
when monday, tuesday, wednesday, thursday, friday
  puts "Work"
when saturday 
  puts "chores"
end
```

Is this incredibly efficient? Not really :) But it opens up quite an
interesting set of possibilities.

