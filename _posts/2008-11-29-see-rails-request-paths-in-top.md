---
layout: post
title: "See Rails request paths in 'top'"
date: 2008-11-29
comments: true
tags: [ruby, rails, deploy]
---

During our sale, we had one particular request that came in and wedged
the application: every time it hit, the mongrel process size zoomed
steadily up to 500Mb, so we had to kill it. But finding out which
request was doing this was tricky. The log files didn’t help—with the
amount of traffic we were getting, it was a small needle and a large
haystack.

Eventually, we found the culprit. But it would have been a lot easier
if I’d thought of this hack on Friday, and not after the sale ended.

If you put this into your application controller:

``` ruby
before_filter :set_process_name_from_request

def set_process_name_from_request
  $0 = request.path[0,16]
end

after_filter :unset_process_name_from_request

def unset_process_name_from_request
  $0 = request.path[0,15] + "*"
end
```

then Ruby will set the cmd field in your process control block to the
first 16 characters of the request path. You can then use top to
see what request is being handled by each mongrel.

{% img top.jpg %}

Once the request has been handled, an asterisk sign is appended, so
you can see the last URL when a mongrel becomes idle. 

{% img top1.jpg %}

If your version of top doesn’t show the short command by default, use
the c keyboard command to see it.

This is probably common knowledge, but I thought it was cool.
