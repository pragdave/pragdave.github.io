---
layout: post
title: "Reasons to Like Scripting Languages, #134"
date: 2004-06-28 19:00:00 -0600
comments: true
categories: []
---

Being able to read the source of the executing program enables a neat
‘usage’ trick.


Well-behaved command line programs (remember the command line?)
display a nice usage message when given invalid arguments. The message
describes what they do and how they should be invoked. Well-documented
command line programs also start with some kind of comment block. The
comment describes what they do and how they should be invoked.


Hmmm, seems like a violation of the DRY principle, having all that
information duplicated…


In Ruby (and most scripting languages, I suspect) it needn’t be. Let’s
assume that the top-level source file in your application starts with
a comment describing how it is used. We can then use the
built-incaller method, which returns call stack. The last element in
this array is the top level program. The entry is in the
form _filename:linenumber_, so we can use a simple regexp to extract
just the file name portion. We then open that source file and read in
the comment block, writing it out as a help message after stripping
the leading comment characters.


The show_usage method is pretty simple:



``` ruby
   def show_usage(msg=nil)
     name = caller[-1].sub(/:\d+$/, '')
     $stderr.puts "\nError: #{msg}" if msg
     $stderr.puts
     File.open(name) do |f|
       while line = f.readline and line.sub!(/^# ?/, '')
         $stderr.puts line
       end
     end
     exit 1
   end

```



An example of this method in use is the start of a simple utility I
wrote to record ad-hoc royalty payments to authors.



``` ruby
   # Pay an author a sum of money. We simply record the payment
   # in the author_royalty_payment table: the statement code
   # sorts it all out
   #
   # usage:
   #    ruby pay.rb   "Author Name"   1234.56   <checkno>
   #

   require "common"

   author = ARGV.shift    ||     show_usage("Missing author name")
   amount = ARGV.shift    ||     show_usage("Missing amount")
   amount = Money(amount) rescue show_usage("Invalid amount")
   check  = ARGV.shift    ||     show_usage("Missing check")

```



Trivial, I know, but I like the simplicity.

