---
layout: post
title: "Our take on presenting code"
date: 2008-05-15 19:00:00 -0600
comments: true
categories: []
---

Back in March, Jim Weirich posted some notes on a clever technique for <a href="http://onestepback.org/index.cgi/General/PresentingCode.red">getting code into Keynote presentations</a>. It struck a chord with me, because I’ve been suffering the same problem for a long time now. Eventually, the pain of putting together the Studio content with Mike Clark and Chad Fowler drove me to find a solution. (The pain wasn’t working with Mike and Chad—it was creating and keeping up to date many hundreds of slides, most of which contained code.)


The solution we went with was based on the way we do code in the Bookshelf books. Rather than embedding the code in the slides, we write regular old programs. Then, in the slide material, we reference the source file (and optionally say which section of that source file), and the appropriate code gets dragged into the slide, syntax highlighted, and hyperlinked back to our editor. Here’s how it works.


**Create Your Material**


We’ve given up using Keynote and Powerpoint. They’re a pain with version control, and they make it easy to fall into the eye-candy trap, favoring glitz over content. Instead, we create our material is plain text files using Textile markup. Typically we use one file per major topic, and the use an index file to bring all these individual files together into a single overall presentation.


Within the material, we can include material from external files using the `:code` directive.


Here’s the source for an individual slide:



```
h1. const_missing
Correctly handles nested modules
:code code/meta/const_missing.rb
```



and here’s what appears on the screen:




<img src="https://31.media.tumblr.com/175f3c1f2a08c1cd81b73b2f25debdbf/tumblr_inline_my18zwwxQp1rgo2z9.jpg"/>




The code gets inserted onto the slide and is syntax highlighted. The blue text below the box shows the file name (so attendees can find it in their collateral material). It’s also a txmt: hyperlink—click it and the file opens in Textmate, so we can edit and run it.




<img src="https://31.media.tumblr.com/5e0a87aeac56fd722e7781c46362a4e8/tumblr_inline_my190q8gAs1rgo2z9.jpg"/>




**Using Parts of a Source File**

You often just want to show part of a larger source file. We do that by including `START:tag` and `END:tag`comments in the original source. (This works in any language, and not just Ruby source). In the slide markup, you indicate the part(s) you want to include in square brackets after the file name:



```
h1. method_missing
:code code/meta/my_ostruct.rb[impl class="code-small"]
```



This says to look at the source file `code/meta/my_ostruct.rb` and only include on the slide the stuff between `START:impl` and comments. We’ll also display it using the CSS class `code-small`.


The ability to include parts of code is invaluable when you’re doing a sequence of slides that builds a solution: you can show each part of a source file in turn.

**Building the Presentation**

The toolchain that takes all this is remarkably simple, because most of the work is done for us. We use a simple Ruby script that takes our original slides, embeds the source code from external files, and then runs Textile to produce an HTML version. We then add a header to that HTML that drags in two incredibly useful Javascript libraries.


For the presentation itself, we use Eric Meyer’s <a href="http://meyerweb.com/eric/tools/s5/">S5</a> system. It gives us nice looking slides, simple to use navigation, and lets us present in our own browsers or (potentially) on our students’.


For the syntax highlighting of code, we use <a href="http://code.google.com/p/syntaxhighlighter/">SyntaxHighlighter</a>. This clever piece of code doesn;t require you to mark up the code elements inthe HTML. Instead you just flag your `<pre>` blocks with an appropriate class and it does the parsing and highlighting in the browser. It means that really large decks can be a little slow to load (but the still beat Keynote on elaspsed time), but it also means your HTML is really clean.


Finally, we have a Rake task that lets us built the whole presentation or just individual chapters.


The whole thing took about 4 hours to get working, and probably another 4 hours on and off to tweak it based on experience. The code’s not really in a state that can be released (so please don’t ask), but it wouldn’t take much to produce something you could do the same with.

**It Actually Works in Practice!**

So far, we’ve done two studios using this stuff (Advanced Ruby and Erlang), and I’ve used it in a number of conference presentations. I wouldn’t switch back to regular presentation software for any code-based talk. (I’ll still use Keynote for non-code slides, though.)

A Few More Slides

Here’s the source:



```
h1. initialize_copy
Container wrappers such a OStruct have a potential problem
:code code/meta/my_ostruct_problem.rb[class=code-small]h1. initialize_copy:code code/meta/my_ostruct_ic.rb[impl class=”code-small”h1. const_missing* Module method whenever undefined constant references in that module** (Module is a module, and acts as a global place for @const_missing@)* Mostly used to autoload classes* Not as easy as it looks (Rails’ @dependencies.rb@ is 500 lines longh1. const_missing:code code/meta/const_missing_autoload.rb[class=code-small]
```



And here are the resulting slides:




<img src="https://31.media.tumblr.com/d4a757a187f6674478a0210f95864485/tumblr_inline_my194fqgpQ1rgo2z9.jpg"/>






<img src="https://31.media.tumblr.com/48391d43ad067dca71c8bc2834ff9404/tumblr_inline_my1957E61k1rgo2z9.jpg"/>






<img src="https://31.media.tumblr.com/59e37f7d199b274c3bd0eaceebcfad6f/tumblr_inline_my195tOhAH1rgo2z9.jpg"/>






<img src="https://31.media.tumblr.com/76d95a035ae3cf04648e4ee005eb2654/tumblr_inline_my1962U74V1rgo2z9.jpg"/>



