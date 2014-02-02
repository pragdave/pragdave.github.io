---
layout: post
title: "First Kill the Architects"
date: 2003-05-06 19:00:00 -0600
comments: true
categories: []
---

I’m over in Bergen for the <a
href="http://roots.dnd.no/">rOOts</a> conference. Martin Fowler gave
an interesting 30 minute talk on the role of architecture in software
development, and on how the forces that drive architecture also drive
other aspects of the overall process. He started by mentioning Ralph
Johnson’s discussion of architecture; we define architectures to
document the things that we perceive as being hard to change. Being
agile, Martin then went on to say that the role of an architect is to
make himself redundant: to find ways of implementing systems which can
roll with the punches, and where everything is amenable to change. As
an example, he talks about databases and schemas. Conventional
thinking tells us that database schemas are hard to change: once you
code to a schema, every change involves updating the database, the
code, and also all the data affected by the change. As a result,
people tend to treat schemas as scary things: we define them and then
code around them. At Thoughtworks, though, they have developed
techniques for incremental migration through schema changes: the
database, data, and code all update in parallel. As a result, the
schema no longer has to be defined up front: is is no longer an
architectural element.


The driver for all this, of course, is flexibility: we need to find
ways of writing applications that work in the face of a set of
volatile requirements. Cut down the number of up-front constraints,
and we increase our degrees of freedom. If also helps us start
delivering earlier, allowing us to get feedback ad refine our
applications as we go.


The alternative to killing all the architects, of course, is to kill
all the developers. Rather than spending time coding flexible
applications, find ways of throwing together disposable solutions to
business problems at greatly reduced cost. Don’t worry about
flexibility: if the application no longer works when the environment
changes, throw it away and write it again. If the cost of code is
small, then the investment can be written off in almost no time.

