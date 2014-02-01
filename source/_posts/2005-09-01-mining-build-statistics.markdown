---
layout: post
title: "Mining Build Statistics"
date: 2005-09-01 19:00:00 -0600
comments: true
categories: []
---

Mike Clark’s been posting some interesting views of CruiseControl
build statistics (<a
href="http://www.pragmaticautomation.com/cgi-bin/pragauto.cgi/Monitor/AnotherBuildFrequencyInkblot">here</a> and <a
href="http://www.pragmaticautomation.com/cgi-bin/pragauto.cgi/Monitor/WhatsYourBuildFrequency">here</a>). These
are cool pictures, and I suspect there’s a bunch of information to be
gleaned from them:

* what’s the blob density (how frequently do folks check in)?
* are they mostly red or mostly blue (red is broken builds)?
* after a red blob, how many more red blobs do you see before you get
  a blue one?

That last statistic is one I think might be interesting. If you were
to plot a histogram of the number of sequences of red blobs of length
one, length two, length three, and so on, what would it look like? If
it is heavily weighted to the low end, then you’re looking at a team
that fixes <a href="http://www.artima.com/intv/fixit.html">broken
windows</a>.


I’m sure that there’s a lot more cool stuff in these pictures, but I’m
impressed at how quickly things jump out at you, and just how much
tacit information they convey. Maybe project tea-leaf reading will
become a sought-after discipline…

