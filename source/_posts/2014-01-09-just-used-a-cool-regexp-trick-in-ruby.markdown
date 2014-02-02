---
layout: post
title: "Just used a cool regexp trick in Ruby"
date: 2014-01-09 8:53:04 -0600
comments: true
categories: [ruby]
---

```
consonant  =-> (ch) { /\A[a-z&&[^aeiou]]\z/ =~ ch }
```



