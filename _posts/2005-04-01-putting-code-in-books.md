---
layout: post
title: "Putting Code in Books"
date: 2005-04-01
comments: true
tags: [ "publishing" ]
---

Maybe there’s something to synchronicity. In the last month, I’ve had
4 or 5 people all ask me about (or e-mail with quotes about) putting
source code in books. So, just because it isn’t written down anywhere
else, I thought I’d jot down some notes.

When we wrote Pragmatic Programmer, we knew we were going to be
including a fair amount of code. We wanted it to look decent, and we
also wanted it to be correct. For us, that meant that we needed to be
able to run most of the code shown in the book.

We used TeX to do the book typesetting (the book was printed from a
high-resolution Postscript file), so that gave us a lot of flexibility
(the power of plain text…). In particular, it let me implement a
preprocessor to handle all the code in the book.

For the short code snippets, you could say:

``` tex
   \begin{code}
     a = 1;
     b = 2;
     System.out.println(a+b);
   \end{code}

```

Now we’ve started the Pragmatic Bookshelf, and we have external
authors. Rather than expect them to wrestle with TeX, we switched to
an XML-based markup. Using it, you’d instead write:

``` tex
   <code>
     a = 1;
     b = 2;
     System.out.println(a+b);
   </code>

```

The preprocessor finds all these code blocks and did the necessary magic to format them nicely. If you wanted syntax highlighting, you had to tell it the language:


``` xml
   <code language="c">
     for (int i = 0; i < 10; i++) {
       printf("i = %d\n", i);
     }
   </code>

```

There are many other options: font size, line numbering, indentation, and so on.

We keep the bigger code samples in source files that can be compiled
and tested. These are included in the books by specifying a file name
(which also triggers the correct syntax highlighting):


``` xml
   <code file="code/fib.c" />

```

Sometimes we have running examples, or the need to show just a small
part of a larger program. To handle this, the preprocessor allows you
to specify tags. Inside the source file, you delimit chunks of text
with START:_tag_ and END:_tag_ in the code’s comments. Only those
chunks are then copied to the final book.



``` xml
   <code file="code/fib.c" part="setup"/>

```

For Ruby code, we get a bit fancier. One major difference is that we
want to show the results of executing Ruby code.

``` xml
  <code language="ruby">
    <run saying="This outputs">
      Dave
      says
    </run>
    a = gets
    b = gets
    puts a + " " + b
  </code>

```

We wanted to book to show:

```
        a = gets
        b = gets
        puts a + " " + b

   This outputs

        Dave says

```

The preprocessor can also extract and cross reference the code from
books. The online <a
href="http://www.pragmaticprogrammer.com/titles/ruby/code/index.html">summary</a> of
the Ruby book’s code (including things like “show hidden code”) is
cross referenced to page numbers and generated automatically by the
preprocessor, TeX, and a wee bit of post-processing glue.


The nice thing about all this (particularly with Ruby books) is that
we know that the results shown in the book are correct as of the time
of writing: every single one of those results is produced afresh each
and every time the book is formatted. And when Ruby changes and things
break, the book just plain stops formatting. It’s also nice to be able
to pull a sequence of extracts from a single program source file: it’s
a great way of ensuring they are consistent.


It’s true that XML and other plain-text based documentation systems
can be a bear to use at times, but that’s a price we’re happy to pay
in exchange for the flexibility of being able to pre- and post process
the book as it is formatted.

