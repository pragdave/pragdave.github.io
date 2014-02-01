---
layout: post
title: "See Rails request paths in 'top'"
date: 2008-11-29 19:00:00 -0600
comments: true
categories: []
---

During our sale, we had one particular request that came in and wedged the application: every time it hit, the mongrel process size zoomed steadily up to 500Mb, so we had to kill it. But finding out which request was doing this was tricky. The log files didn’t help—with the amount of traffic we were getting, it was a small needle and a large haystack.

Eventually, we found the culprit. But it would have been a lot easier if I’d thought of this hack on Friday, and not after the sale ended.

If you put this into your application controller:



```
before_filter :set_process_name_from_request

def set_process_name_from_request
  $0 = request.path[0,16]
end

after_filter :unset_process_name_from_request

def unset_process_name_from_request
  $0 = request.path[0,15] + "*"
end
```



then Ruby will set the cmd field in your process control block to the first 16 characters of the request path. You can then use top to see what request is being handled by each mongrel.



<img src="https://31.media.tumblr.com/28ac6f40c9115c64702b0bd7383f06c4/tumblr_inline_my1bogZBkM1rgo2z9.jpg"/>



Once the request has been handled, an asterisk sign is appended, so you can see the last URL when a mongrel becomes idle. 



<img src="https://31.media.tumblr.com/2cbaaaf73b2cdf827c0d0f7be90b88b7/tumblr_inline_my1bq7OMLl1rgo2z9.jpg"/>





If your version of top doesn’t show the short command by default, use the c keyboard command to see it.

This is probably common knowledge, but I thought it was cool.
