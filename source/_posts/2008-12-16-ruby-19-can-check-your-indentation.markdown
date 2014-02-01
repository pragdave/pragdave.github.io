---
layout: post
title: "Ruby 1.9 can check your indentation"
date: 2008-12-16 19:00:00 -0600
comments: true
categories: []
---

All Ruby programmers regularly encounter the mystical error “syntax error, unexpected $end, expecting keyword_end.” We know what it means: we left off an end somewhere in the code. As Ruby compiled our source, it keeps track of nesting, and when it reached the end of file ($end), it was expecting to see one more end keyword, and none was there.


So, we trundle back through the source, and after a while discover we’d deleted just one too many lines during that last edit.


Ruby 1.9 makes that easier. For example, here’s a source file:


**class** Example  **def** meth1    **if** Time.now.hours > 12      puts “Afternoon”  **end********  def** meth2    # …  **end****end**


Run it through Ruby 1.9, and you’ll get the same old error message:


dave[RUBY3/Book 8:26:48*] **ruby t.rb**   t.rb:10: syntax error, unexpected $end, expecting keyword_end


But add the -w flag, and things get more interesting.


dave[RUBY3/Book 8:26:51*] **ruby -w t.rb**t.rb:5: warning: mismatched indentations at ‘end’ with ‘if’ at 3t.rb:9: warning: mismatched indentations at ‘end’ with ‘def’ at 2t.rb:10: syntax error, unexpected $end, expecting keyword_end


It’s the small things in life…

