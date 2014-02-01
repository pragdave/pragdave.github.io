---
layout: post
title: "Sharing External ActiveRecord Connections"
date: 2006-01-03 19:00:00 -0600
comments: true
categories: ["deploying"]
---

I had a problem with a deployed Rails application today that Mike
Clark helped me track down.


It started after Mike and I migrated a Rails app to a new, zippier
server. Everything looked great (and the app ran a lot
faster). However, after a while, I started getting problems with a
database. To explain what went wrong, I need to chat a little about
the application.

This piece of code is an attempt to migrate functionality away from a
particularly nasty set of old CGIs, web applications, bailing wire,
chewing gum, and other historical crud. There’s a lot of existing
functionality, and I decided not to try to port it all across to Rails
on day one. Instead, I gave the Rails application its own database to
play with, and gave it access to the old legacy database for when it
needed to look up stuff in the existing system. To do that, I created
a set of ActiveRecord classes for the legacy tables, and explicitly
connected them to the legacy database, rather than the default Rails
application database. A typical legacy model class looked smething
like this:

``` ruby
  class LegacyOrder < ActiveRecord::Base
    set_table_name  "orders"
    set_primary_key "o_id"

    establish_connection "legacy_#{RAILS_ENV}"
    ...
  end

```

(The ”legacy_#{RAILS_ENV}” stuff lets me have development, test, and
production versions of the legacy database in my database.yml file.)

So far, so good. I had four different legacy tables I mapped this way,
and everything worked fine.

However, after a while, other applications accessing the legacy
database started failing, claiming they couldn’t connect. Sure enough,
it turned out that there were hundreds of active connections to that
database: the database wasn’t going to accept any more.

The problem was that I was creating way too many connections to the
legacy database. Each spawned Rails fcgi process established a
separate connection to the legacy database for each legacy
ActiveRecord class. That factor of four killed us.

But fixing it also raised an interesting question: in my original
code, I established a separate connection for each legacy table in
each running Rails process. This was clearly dumb. But what’s the best
way of sharing a single connection between all of the legacy model
objects in a Rails instance?

Some chatting on #rails-core came up wih three suggestions:

Create the connection once (perhaps in one of the environment files),
and then assign it to each of the legacy AR classes:

``` ruby
  legacy_connection = ActiveRecord::Base.mysql_connection(...)

  LegacyOrder.connection = legacy_connection
  LegacyLineItem.connection = legacy_connection
  ...

```

Establish the connection in one model, then use it in the others

``` ruby
 class LegacyOrder < ActiveRecord::Base
   establish_connection ...
 end

 class LegacyLineItem < ActiveRecord::Base
   connection = LegacyOrder.connection
 end

```

Somehow make all the legacy models share a common parent, and have
that parent own the connection.

Options (1) and (2) seemed messy: they added a bunch of coupling to
the code where it wasn’t really justified. Option (3) seemed like the
way to go. The only problem was that no one on #rails-core was sure it
would work…

It turns out it does.

``` ruby
  class LegacyBase < ActiveRecord::Base
    establish_connection ...
  end

  class LegacyOrder < LegacyBase
     ...
  end

  class LegacyLineItem < LegacyBase
    ...
  end

```

The parent class creates a single connection to the legacy database,
and all the child classes share it. The _reason_ it works is some
smarts in Rails.

It turns out that Rails does just about everything lazily. That
includes connecting to databases and reflecting on tables to extract
the schema (needed to build the internals of the models). This
improves performance, but it also makes this hack possible. In
general, you’d expect the LegacyBase class to map to a database table
called legacy_base. It would, if we ever tried to use it to access
data. But because we don’t, and because Rails only reflects on the
table the first time a data access occurs, we can safely create an
ActiveRecord class with no underlying database table.


This scheme lets me specify the legacy connection once, and share that
connection between all my legacy models. It’s tidy, expressive, and
saves resources.

