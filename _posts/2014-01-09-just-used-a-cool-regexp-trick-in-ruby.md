---
layout: post
title: "Just used a cool regexp trick in Ruby"
date: 2014-01-09
comments: true
tags: [ruby]
---

```
consonant  =-> (ch) { /\A[a-z&&[^aeiou]]\z/ =~ ch }
```



