---
layout: post
title: "Quick Ruby Quiz"
date: 2007-03-07
comments: true
tags: [ruby]
---

I was talking to the Dallas Ruby group a couple of days ago, and
showed them the following code:

``` ruby
class Fred
  class << self
    def self.say_hello
      puts "Hi!"
    end
  end
end
```

Someone asked whether it was possible to call
the `say_hello` method. It is. How many ways can you find?

