---
layout: post
title: "Why I Like Scripting Languages, Reason #259"
date: 2004-07-13
comments: true
tags: []
---

The libraries bundled with Ruby 1.8 make it a breeze to munge RSS information into a web page.


Mike Clark’s running a <a href="http://www.pragmaticautomation.com/">Project Automation</a> site, with tie-ins to his new book. We have the book’s home page on our <a href="http://pragmaticprogrammer.com/starter_kit/au">site</a>, where we maintain a <a href="http://pragmaticprogrammer.com/starter_kit/au/resources.shtml">subpage</a> where we’ll be hosting various add-on goodies related to automation, and we wanted to excerpt the most recent news items from Mike’s page onto ours.


I know there are lots of programs out there to extract entries from an RSS feed. I know I could have used curl and XSLT. But having spent the last week revising PickAxe 2, I felt like coding. And it turns out that the solution is pretty simple. And, even better, all the libraries it uses come bundled with Ruby 1.8—no messy downloads required…



```
     require 'rss/0.9'
     require 'open-uri'
     require 'rdoc/template'
     require 'net/ftp'

     TEMPLATE = %{
     <div class="blogentries">
     START:entries
       <div class="blogentry">
         <a href="%link%"><span class="blogentrytitle">%title%</span></a>
         <div class="blogentrydescription">
           %description%
         </div>
       </div>
     END:entries
     </div>
     }

     TMP_FILE = "/tmp/topfive"
     BLOG_URL = ARGV[0] || fail "Missing URL"

     open(BLOG_URL) do |http|
       result = RSS::Parser.parse(http.read, false)
       entries = result.items.map do |item|
         {
           'title'       => item.title,
           'link'        => item.link,
           'description' => item.description
         }
       end

       File.open(TMP_FILE, "w") do |f|
         t = TemplatePage.new(TEMPLATE)
         t.write_html_on(f, 'entries' => entries)
       end
     end

      Net::FTP.open('www.pragmaticprogrammer.com') do |ftp|
       <a href="http://ftp.login">ftp.login</a>('user, 'passwd')
       <a href="http://ftp.chdir">ftp.chdir</a>('starter_kit/au')
       <a href="http://ftp.put">ftp.put</a>(TMP_FILE, 'topfive', 1024)
     end
```


