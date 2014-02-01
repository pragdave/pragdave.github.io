---
layout: post
title: "Topless Systems, Naked Objects"
date: 2003-03-06 19:00:00 -0600
comments: true
categories: []
---

When talking about the failings of top-down development, Bertrand
Meyer says “Real systems have no top.’[^1] And yet the GUI-based
applications we produce run counter to this: our code typically does
have a “top,” at least from the user’s perspective. The top in this
case is the user interface, the collection of mini-scripted activities
that we provide to allow our users to interact with our underlying
application. Everything else in a typical interactive application is
there simply to support this GUI, and this affects the way we both
design and implement the code.


Interestingly, Naked Object applications (<a
href="http://www.nakedobjects.org/"><a
href="http://www.nakedobjects.org">www.nakedobjects.org</a></a>)
do _not_ have a top in this sense: the user is instead presented with
a group of business classes and business objects. The user is free to
interact with them in any way that makes sense.


If Meyer is correct (and I think he is), then Naked Object systems do
indeed seem to be closer to the true spirit of OO development.


[^1]: Bertrand Meyer, _Object-Oriented Software Construction, 2nd ed_

