---
layout: post
title: "Fun with Ruby 1.9 Regular Expressions"
date: 2008-10-15
comments: true
tags: [ "ruby" ]
---

I’ve reorganized the regular expression content in the new Programming
Ruby, and added some cool new advanced examples. This one’s fairly
straightforward, but I love the fact that I can now start refactoring
my more complex patterns, removing duplication.


The stuff below is an extract from the unedited update. It’ll appear
in the next beta. It follows a discussion of named groups, `\k` and
related stuff.

There’s a trick which allows us to write subroutines inside regular
expressions. Recall that we can invoke a named group using `\g<name>`,
and we deﬁne the group using `(?<name>...)`. Normally, the deﬁnition
of the group is itself matched as part of executing the
pattern. However, if you add the sufﬁx `{0}` to the group, it means
“zero matches of this group,” so the group is not executed when ﬁrst
encountered.


``` ruby
sentence = %r{ 
    (?<subject>   cat   | dog   | gerbil    ){0} 
    (?<verb>      eats  | drinks| generates ){0} 
    (?<object>    water | bones | PDFs      ){0} 
    (?<adjective> big   | small | smelly    ){0} 

    (?<opt_adj>   (\g<adjective>\s)?     ){0} 

    The\s\g<opt_adj>\g<subject>\s\g<verb>\s\g<opt_adj>\g<object> 
}x

md = sentence.match("The cat drinks water") 
puts "The subject is #{md[:subject]} and the verb is #{md[:verb]}"
 
md = sentence.match("The big dog eats smelly bones") 
puts "The adjective in the second sentence is #{md[:adjective]}" 

sentence =~ "The gerbil generates big PDFs" 
puts "And the object in the last is #{$~[:object]}" 

```

_produces:_

```
The subject is cat and the verb is drinks 
The adjective in the second sentence is smelly 
And the object in the last is PDFs 

```
Cool, eh?

