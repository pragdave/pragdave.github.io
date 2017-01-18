---
layout: post
title: "Migrations Outside Rails"
date: 2006-07-17
comments: true
tags: [deploy, rails]
---

I’m about 3 weeks into the rewrite of the Active Record chapters for
the new <a href="http://pragmaticprogrammer.com/titles/rails2">Rails
book</a>. In the book, I try to demonstrate Active Record with real,
live code. At the same time, I don’t want to run every single piece of
code in the context of a Web application. So, I use Active Record
stand-alone, without having the rest of Rails loaded. All my
demonstration files start:

``` ruby
require "rubygems"
require_gem "activerecord"

```
and then include a call to `establish_connection` to connect to the database.

At this point, I’m up and running, and I can play with all the Active
Record functionality. But… I still wanted to create tables in the
underlying database. In the first edition, I used DDL to do this, but
in the second I wanted to use migrations.

My first hack was to use the fact that the various schema definition
methods are defined both for migrations and in every database
connection object. That let me use the following in my code:



``` ruby
ActiveRecord::Base.connection.instance_eval do
  create_table children, :force => true do |t|
    t.column :parent_id, :integer
    t.column :name,      :string
    t.column :position,  :integer
  end
end

```

I was pretty chuffed with this until Jamis Buck (who else) pointed out
a more elegant way:

``` ruby
ActiveRecord::Schema.define do
  create_table children, :force => true do |t|
    t.column :parent_id, :integer
    t.column :name,      :string
    t.column :position,  :integer
  end
end

```

As I see more and more people start to use Ruby (and Active Record) as
enterprise glue, being able to bring these kinds of Rails goodies to
non-Rails applications is a win all around.

