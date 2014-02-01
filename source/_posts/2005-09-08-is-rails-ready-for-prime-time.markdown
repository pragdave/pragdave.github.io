---
layout: post
title: "Is Rails Ready for Prime Time?"
date: 2005-09-08 19:00:00 -0600
comments: true
categories: ["deployment"]
---

I give talks on Rails and Ruby to Java developers on average once
every two weeks. I’ve probably spoken to thousands of folks over the
last year. And I don’t think I’ve ever had a talk that didn’t end with
someone asking “that’s all very nice, but is Rails ready to be used
in _my_ company? Can I stop writing Java and start writing Ruby?”


As with most good questions, there’s no one simple answer. Here’s what
I tell people.

### First, Ask the Right Question

One of the main selling points for Java in the late 90’s was the idea
of having a language, runtime, and library set that could be used
everywhere. Use Java to code your cell phone, and use Java to code
your largest enterprise application. To some extent that thinking has
insinuated itself into the mind sets of many developers—they are
looking for one solution, one framework, and one language to solve all
their problems.


That’s silly. Some situations need one tool, other situations another
tool. Using the full might of a J2EE stack to write a small
stand-alone application is using a sledgehammer to crack a nut. But I
keep hearing the sound of nuts being pulverized as developers seem to
think that using anything other than J2EE is somehow unprofessional.


At the same time, there are situations that call for the shock and awe
that is J2EE. Some applications need to make use of facilities rolled
into the stack, and it would be crazy to reinvent the wheel.


So when people ask “should I be using Rails instead of Java?”, the
answer has to be “not exclusively: you’re likely to want to use
Rails _as well as_ Java.” Why? Because I’m a firm believer in having a
bag of tools at your disposal, tools that you know how and—most
importantly—when to use. When Rails is appropriate, you’re going to be
hard pressed to find a more productive environment.


And, even if Rails is the clear winner for a particular application,
developers face a second challenge. They have to convince their
companies to let them use it.


So the real questions are “when is Rails appropriate?”, and “how can I
introduce it where I work?”


Let’s start by looking at some of the hurdles Rails has to clear to
make it an appropriate choice where you work.

### Next, Make Sure It’s Possible

When shouldn’t you use Rails?

* _If you need to handle transactions across multiple
  databases._ Rails/Ruby doesn’t have two phase commit (yet).

* _If you have really strange database schemas._ ActiveRecord beats
  Hibernate when the schemas are fairly well structured. Hibernate
  wins when you have to map the schema-from-hell before using it
  inside your application.

* _If you’re adding small chunks of functionality to an existing,
  large application._ OK, this is contentious. If I was reading this,
  I’d probably fire up my mail client and complain that this is
  exactly when you _should_ use Rails. Integrate to the monster using
  web services, and add new functionality in something more malleable,
  such as Rails.


  Except… most monstrously large applications I’ve come across got
  there over time. They’re messy, hard to work with, and tightly
  coupled. If you wanted to expose parts of them via web services,
  you’d first have to restructure them to make those parts callable
  from the outside, and that probably isn’t worth the effort (if it’s
  possible at all).


* _The developers don’t want to._ If the rest of the developers don’t
  want to use Rails, then forcing them to help you create a pilot
  project is a simple recipe for embarrassment. Pull, don’t push, when
  it comes to change.


### Then, Make it Realistic

Companies are all different, and there’s no one road to Rails adoption.


In some environments, there may be no resistance to using Rails. I’ve
even heard of some places where the managers are working to persuade
the development staff to give Rails a try. Typically, it’s the small
and medium size businesses that have this kind of
flexibility. Companies such as <a
href="http://www.odeo.com/">Odeo</a> and <a
href="http://www.vitalsource.com/">VitalSource</a>embraced Rails as a
key component of their business plan.


Other companies, including most large ones, have a more conservative
approach when adopting new technologies. So how can a developer who’s
convinced that Rails would benefit their company get it into
production?


In general, I suggest an incremental approach. Start with small,
developer-focused applications. For example, a new table may have been
added to the database. Developers need to be able to maintain test
data in it, so they can continue to write parts of the larger (Java)
application. Whip up a quick Rails application in 20 minutes and leave
it running on a Webrick server somewhere. Folks will notice how easy
it seemed to be.


Maybe at some point the development group might need a web application
for their own use (change request trqcking, for example). Suggest
writing it in Rails. Mention that not only will it take less time (and
hence cost less in terms of overhead dollars), but it will also allow
the group to get some experience with the technology. This is where
you get to show off. First deliver a solid solution, then add stuff
such as Ajax support to show them how things might be (if only they
used Rails in all their applications…).


Then the time might come to roll out an inward-facing corporate
application. If the development team are now comfortable with the
technology, propose a Rails application. Now you’ll get experience
running Rails in a production environment.


Finally, once everyone is comfortable, think about rolling out an
externally-facing Rails application.

### Easing the Transition

Here are three suggestions for making the transition to Rails
applications less extreme:



* **Start using Rails Conventions in Your Java Applications**. Maybe
  you aren’t in a position to make the switch now. Even so, think
  about using some of the Rails conventions when you do things such as
  add new tables to your Java applications. Using the Rails naming
  schemes won’t make any difference to Hibernate, and you’ll be in a
  stronger position to write Rails applications against that
  schema. Even though the external application is still J2EE, you can
  write internal, ancillary applications in Rails. And if the schema
  is Rails friendly, the effort will be less.

* **Do parallel developments**. The jury is still out on the
  productivity increases that come from using Rails, but I see some
  very credible people talking about numbers in the 5-15x range. So if
  Rails really does let you write applications in 10-20% of the time
  you’d otherwise take, why not do a Rails development in parallel
  with the real one? If the main project is slated to take 5 months
  using J2EE, and after a month you have a working Rails version, your
  company gets to make a decision.

  They can use the Rails version, having invested 2 months of effort
  (one month for Rails, one month for the parallel Java team). This is
  a net saving of 3 months over the original 5 month estimate.

  They can choose not to use the Rails version. In this case they’ve
  spent an extra month, and learned something valuable. Is that extra
  month significant? Probably not—it seems to me that any project that
  comes in within 20% of its estimate is a raging (and unusual)
  success, so this extra time just gets swallowed by the general
  budget slop that surrounds all software development.

* **Make sure you know what you’re doing** before leaping into an
  ambitious project. As the cliché says, you only get one chance to
  make a first impression. If you want to show that Rails is viable in
  your company, then you need to make sure that all the folks doing
  the work on your first visible Rails project know what they’re
  doing. Think hard about the deployment and maintenance issues before
  committing. Choose something simple, and implement it well.



What do you think? Is all this realistic? Have you already introduced
Rails to your company? How’d it go?<a
href="mailto:dave@pragprog.com">Let me know.</a>

