---
layout: post
title: "Deploying Elixir"
date: 2013-12-20 14:06:00 -0600
comments: true
categories: []
---
When any serious app is 100% done, there’s another 50% left to do, and that 50% is deployment. For complicated or large apps, there’s no easy way to do this.


A reader asked me about Elixir and deployment:



{%blockquote%}


There is definitely a lot of excitement around Elixir and I like it. What I am concerned with is are their any production deployment issues with Elixir? I have not don’t one myself but Elixir depends a lot on Erlang and Erlang libraries which have some kind of unique release process or so I have been told. I am not sure if I understood it correctly but I believe Erlang is released in such a away that it is self reliant and doesn’t depend on any external dependencies. How would Elixir behave if the system Erlang version moves ahead?


{%endblockquote%}


And I responded:


Elixir is just Erlang, as far as Erlang is concerned. This means that Elixir code can be deployed alongside Erlang code—the two coexist.


However, you have to be careful when looking at Erlang deployments.  Up until now, these have tended to be large-scale, distributed, and highly redundant systems. The goal has been seriously high reliability. Now no system like this can be deployed just by pushing a button—there’s a lot of planning, and a lot of configuration and scripting.


As a result, a “classical” Erlang deploy can be a big beast. Your Elixir code can join in this fun if it wants to.


But Elixir also offers simpler options. For example, deploying an Erlixir web app to Heroku is just about as easy as deploying any app to Heroku—just push to a repository.


So the short answer is that deployment in any language is not just one topic—it varies greatly depending on the application’s characteristics. At the large scale end, Erlang (and by extension Elixir) has a great story—it is mature and proven. At the small scale, deployments such as Heroku make it easy. And in the middle—well, that’s where the interesting stuff will happen.


