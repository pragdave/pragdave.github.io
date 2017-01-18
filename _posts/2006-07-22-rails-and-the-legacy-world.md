---
layout: post
title: "Rails and the Legacy World"
date: 2006-07-22
comments: true
tags: []
---

I gave what turned out to be a slightly controversial <a
href="http://blog.scribestudio.com/articles/2006/06/30/railsconf-2006-keynote-series-dave-thomas">keynote
at RailsConf</a>. In it, I pointed out that people (like me) who can
use Rails on green-field projects are incredibly privileged. We get to
code using cool technologies in an incredibly agile, reactive
environment, producing applications that just work.

But, at the same time, there are a whole lot of people who don’t get
to enjoy the world of Rails.

I see these people regularly: I talk at <a
href="http://nofluffjuststuff.com/">No Fluff symposia</a> around the
country, a great set of shows aimed at Java developers. I’m the
outsider, normally giving a full day’s worth of talks on Ruby and
Rails. And, in a way, it makes me sad to do it, because I often see
folks get really excited about the possibilities present in Rails only
then to realize that they’ll be going back to work on Monday with no
real hope of using what they’d just seen. These folks come to me
during the breaks and talk about how bad their world currently is, and
how much better it would be if only they could use Rails. If only…

Sometimes, the things that block these people are not technical
issues: companies have policies dictating that all work is done in
Java (or .NET, or whatever). But many times the road blocks are
technical. In their particular environment, with legacy code and
legacy databases, they need to be able to do things that Rails just
doesn’t support out of the box—more complex schemas, staged
deployment, and so on.

So, in my keynote, I asked a simple question. Can we, as a community,
do anything to make the lives of these developers easier. Can we find
a way of bringing them in out of the cold?

Clearly, I believe the answer is yes. As I said in Chicago, the answer
is not to change Rails. Instead, the answer is to use the fact that
Rails is based on Ruby, and Ruby gives developers incredible power to
extend existing code in directions not anticipated by the original
developers. I asked the community to consider creating extensions to
Rails to allow currently disenfranchised developers to join the party.

This seems to have touched people’s nerves. Some have reacted
violently against the idea, others have welcomed it. It’s an
interesting, although ultimately sterile, debate. If people need
changes to Rails, Ruby will let them do it.

An interesting example is Greg Houston’s recent blog post, <a
href="http://ghouston.blogspot.com/2006/07/let-activerecord-support-enterprise.html">Let
ActiveRecord support Enterprise Databases</a>. (Uh oh! He used
the _enterprise_ word). He describes a problem he faces trying to use
Active Record migrations to maintain a legacy schema. The
database-neutral migrations didn’t give him the kind of control he
needed, so his post describes how he extended Active Record to do what
he wants (including a very simple but nicely powerful trick to make
migrations spit out SQL, rather than execute it). And, importantly, he
did all this as a regular user of Rails: he didn’t need any changes to
the framework or any endorsement of his work by the core team. (He
does, however, make a good point at the end of his post. If Active
Record had an extension API it would make it easier for these kinds of
plugins to survive changes to the core code base.)

Greg’s post is a basic experience report: he took what he needed from
Rails, extended it where necessary, and solved a business problem. By
blogging, he’s shown other developers just how to solve this category
of problem. A .NET developer needing to manage a legacy SqlServer
schema could read his post and realize that something that seemed
impossible in Rails is actually fairly easy. One more person can join
the party.

You could argue that the stuff in Greg’s post is just a simple matter
of coding. There’s nothing stopping any .NET developer downloading
Rails and making the simple changes he’s suggesting.

But the reality is that you have to have a good idea that this kind of
thing is possible before you invest time in the exercise. If you’re a
Java or .NET developer looking for salvation, and you spend some time
looking at Rails, you’ll currently come across a lot of information
explicitly telling you that Rails is never going to address the issues
you face—Rails is explicitly **not** ”enterprise.” And so you’d move
on. And you’d be missing an incredible opportunity.

And this is one of the challenges I’d like us, the Rails and Ruby
communities, to address. While keeping the Rails core focused on new
ways of writing web applications, I’d like others of us to find ways
of educating corporate software developers, showing them that they can
also bring our technologies into their daily lives—using Ruby as an <a
href="http://pragmaticprogrammer.com/titles/fr_eir">enterprise</a> <a
href="http://blogs.pragprog.com/cgi-bin/pragdave.cgi/Tech/UnsetGlue.html">glue
language</a> and Rails as a viable enterprise web development
platform.

Should Rails be everything to everyone?

No.

Should Rails be “marketed” as a replacement for J2EE or .NET?

God forbid.

But there are a whole group of people out there who _could_ be using
Rails now but aren’t, simply because they don’t know that it is up to
their challenges. And I’d like to try to help these folks.

Let’s not be the only people having fun.


