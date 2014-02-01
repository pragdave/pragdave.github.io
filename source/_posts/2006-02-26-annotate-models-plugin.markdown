---
layout: post
title: "Annotate Models Plugin"
date: 2006-02-26 19:00:00 -0600
comments: true
categories: []
---

Rails model files contain no information on the tables they
represent. This is a good thing in general, because it reduces
duplication—add a column to a table, and there’s no configuration to
update in the model.

However, when you’re writing code, it’s sometimes nice to be able to see just what attributes a model has.

Enter _annotate models_, a really trivial Rails plugin I hacked up in
the plane back from the first <a
href="http://nofluffjuststuff.com/">No Fluff</a> of the year. The
plugin adds a comment block to the top of each model file, documenting
the schema. If you update the schema, run it again and it updates the
comment.


``` ruby
# Schema as of Mon Feb 27 00:55:58 CST 2006 (schema version 7)
#
#  id                  :integer(11)   not null
#  name                :string(255)
#  description         :text
#  image_location      :string(255)
#  price               :float         default(0.0)
#  available_at        :datetime
#

class Product < ActiveRecord::Base

  validates_presence_of :name, :description
  . . .

```

Install using:

``` sh
$ script/plugin install <a href="http://repo.pragprog.com/svn/Public/plugins/annotate_models">http://repo.pragprog.com/svn/Public/plugins/annotate_models</a>

```

and run with:

``` sh
$ rake annotate_models

```

It only handles models directly under app/models. And, as it’s new,
you’d be advised to back up your model files before running it.

