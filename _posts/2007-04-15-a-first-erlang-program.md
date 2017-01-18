---
layout: post
title: "A First Erlang Program"
date: 2007-04-15
comments: true
tags: [ "erlang" ]
---

{%img1 right /img/erlang.jpg%}

One of the joys of playing at being a publisher is that I get to mess
around with the technology in books as those books are getting
written. Lately I’ve been having a blast with <a
href="http://armstrongonsoftware.blogspot.com/">Joe Armstrong</a>'s
new <a
href="http://pragmaticprogrammer.com/titles/jaerlang2/index.html">Erlang
Book</a>. At some point I’ll blog about the really neat way the Erlang
database unifies the set-based SQL query language and list
comprehensions (it’s obvious when you think about it, but it blew me
away when I first read it). But I just wanted to start off with some
simple stuff.

One of my standard Ruby examples is a program that fetches our book
sales ranks from Amazon using their REST interface. I thought I’d try
the exercise again in Erlang. In this first part we’ll write a simple
Erlang function that uses the Amazon <a
href="http://www.amazon.com/gp/browse.html?node=3435361">Web Services
API</a> to fetch the data on a book (identified by its ISBN). This
data is returned in XML, so we’ll then use some simple XPath to
extract the title and the sales rank.

My Erlang module is called `ranks`, and I store it in the
file`ranks.erl`. Because I’m just playing for now, the interface to
this module is simple: I’ll define a function
called`fetch_title_and_rank`. This returns a {_title, rank_}
tuple. So, I started off with something like this:

``` erlang
-module(ranks).
-export([fetch_title_and_rank/1]).

fetch_title_and_rank(ISBN) ->
  { "Agile Web Development with Rails", 1234 }.

```

The `-module` directive simply names the module. The next line tells
Erlang that this module exports a function
called `fetch_title_and_rank`. This method takes one parameter. (This
idea of specifying the number of parameters seems strange until you
realize that in Erlang the function signature is the function
name _and_ the parameter count. It is valid to export two functions
with the same name if they take a different number of arguments—as far
as Erlang is concerned they are different functions.)

Next we define the `fetch_title_and_rank` function. It takes a single
parameter, the book’s ISBN. In Erlang, variable names (including
parameters) start with uppercase letters. This takes a little getting
used to. Just to make sure thinks are wired up correctly, let’s try
running this code. In a command shell, I navigate to the directory
containing `ranks.erl` and started the interactive Erlang shell. Once
inside it, I compiled my module (using `c(ranks).`) and then invoke
the `fetch_title_and_rank` method.



```
dave[~/tmp 11:51:09] erl
Erlang (BEAM) emulator version 5.5.4 [source] ...

Eshell V5.5.4  (abort with ^G)
1> c(ranks).
./ranks.erl:11: Warning: variable 'ISBN' is unused
{ok,ranks}
2> ranks:fetch_title_and_rank("0977616630").
{"Agile Web Development with Rails",1234}

```

Let’s start wiring this up to Amazon.

To fetch information from Amazon using REST, you need to issue
an `ItemLookup` operation, specifying what you want Amazon to
return. In our case, we want the sales rank information, plus
something called the _small_ response group. The latter includes the
book’s title. The URL you use to get this looks like this (except all
on one line, and with no spaces):


```
<a href="http://webservices.amazon.com/onca/xml?">http://webservices.amazon.com/onca/xml?</a>
Service=AWSECommerceService
&SubscriptionId=<your ID goes here>
&Operation=ItemLookup
&ResponseGroup=SalesRank,Small
&ItemId=0977616630

```

The `ItemID` parameter is the ISBN of our book. Let’s write an Erlang
function that returns the URL to fetch the information for an ISBN.

```
-define(BASE_URL,
      "http://webservices.amazon.com/onca/xml?" ++
      "Service=AWSECommerceService" ++
      "&SubscriptionId=<" ++
          "&Operation=ItemLookup" ++
          "&ResponseGroup=SalesRank,Small" ++
          "&ItemId=").

amazon_url_for(ISBN) ->
  ?BASE_URL ++ ISBN.

```

This code defines an Erlang macro called `BASE_URL` which holds the
static part of the URL. The function`amazon_url_for` builds the full
URL by appending the ISBN to this. Note that both the macro and the
function use `++`, the operator that concatenates strings.

We now need to find a way of sending this request to Amazon and
fetching back the XML response. Here we bump into one of Erlang’s
current problems—it can be hard to browse the library
documentation. My solution is to <a
href="http://www.erlang.org/download.html">download the
documentation</a> onto my local box and search it there. I tend to use
both the HTML and the man pages. Figuring I wanted something HTTP
related, I tried the following:

```
dave[Downloads/lib 12:04:07] ls **/*http*
inets-4.7.11/doc/html/http.html        
inets-4.7.11/doc/html/http_base_64.html 
inets-4.7.11/doc/html/http_client.html  
inets-4.7.11/doc/html/http_server.html 
inets-4.7.11/doc/html/httpd.html
inets-4.7.11/doc/html/httpd_conf.html
inets-4.7.11/doc/html/httpd_socket.html
inets-4.7.11/doc/html/httpd_util.html

```

Opening up <a
href="http://pragdave.pragprog.com/pragdave/page/6/...">`http.html`</a> revealed
the `http:request` method.

``` erlang
request(Url) -> {ok, Result} | {error, Reason}
```

This says that we give the `request` method a URL string. It returns a
tuple. If the first element of the tuple is the atom `ok`, then the
second element is the result for the request. If the first element
is `error`, the second element is the reason it failed. This technique
of returning both status and data as a tuple is idiomatic in Erlang,
and the language makes it easy to handle the different cases.

Let’s look a little deeper into the successful
case. The `Result` element is actually itself a tuple containing a
status, the response headers, and the response body.


So let’s take all this and develop our `fetch_title_and_rank` method a
little more.

``` erlang
fetch_title_and_rank(ISBN) ->
  URL = amazon_url_for(ISBN),
  { ok, {Status, Headers, Body }} = http:request(URL),
  Body.

```

We call our `amazon_url_for` method to create the URL to fetch the
data, then invoke the `http:request`library method to fetch the
result. Let’s look at that second line in more detail.

The equals sign in Erlang looks like an assignment statement, but
looks are deceptive. In Erlang, the equals sign is actually a pattern
matching operation—an assertion that two things are equal. For
example, it is perfectly valid in Erlang to say

```
6> 1 = 1.
1
7> 9 * 7 = 60 + 3.
63

```

So what happens when variables get involved? This is where it gets
interesting. When I say


``` erlang
A = 1.

```

I’m not assigning 1 to the variable A. Instead, I’m matching A against
1 (just like 9*7 = 60+3 asserts that the results of the two
expressions are the same). So, does A match 1? That depends. If this
is the first appearance of A on the left hand side of an equals sign,
then A is said to be unbound. In this condition, Erlang says to itself
“I can make this statement true if I give A the value 1,” which is
does. From this point forward, A has the value 1 (in the current
scope). If we say `A = 1.` again in the same scope in our Erlang
program, A is no longer unbound, but this pattern match succeeds,
because `A = 1.`is a simple assertion of truth. But what happens if we
say `A=2.`?


{% raw %}

```
10> A = 1.
1
11> A = 1.
1
12> A = 2.

=ERROR REPORT==== 16-Apr-2007::12:32:36 ===
Error in process <0.55.0> with exit value: {{badmatch,2},[{erl_eval,expr,3}]}

** exited: {{badmatch,2},[{erl_eval,expr,3}]} **

```
{% endraw %}

We get an error: Erlang was unable to match the values on the left and
right hand sides of the equals, so it raised
a `badmatch` error. (Erlang error reporting is, at best, obscure.)

So, back to our HTTP request. I wrote


``` erlang
{ ok, {Status, Headers, Body }} = http:request(URL)

```

The left hand side matches a tuple. The first element of the tuple is
the atom `ok`. The second element is another tuple. Thus the entire
expression only succeeds if `http:request` returns a two element tuple
with `ok` as the first element and a three element tuple as the second
element. If the match succeeds, then the
variables `Status`, `Headers`, and `Body` are set to the three
elements of that second tuple.

(An aside for Ruby folk: you can do something similar using an obscure
Ruby syntax. The statement


``` erlang
rc, (status, headers, body) = [ 200, [ "status", "headers", "body" ] ]

```

will leave `headers` containing the string `"headers"`.)

In our Erlang example, what happens if `http:request` returns an
error? In this case, the first element of the returned tuple will be
the atom `error`. This won’t match the left hand side of our
expression (because the atom `error` is not the same as the atom `ok`)
and we’ll get a badmatch error. We won’t bother to handle this
here—it’s someone else’s problem.

Let’s compile our program.

```
1> c(ranks).
./ranks.erl:13: Warning: variable 'Headers' is unused
./ranks.erl:13: Warning: variable 'Status' is unused
{ok,ranks}

```

Erlang warns us that we have some unused variables. Do we care? To a
point. I personally like my compilations to be clean, so let’s fix
this. If you prefix a variable’s name with an underscore, it tells the
Erlang compiler that you don’t intend to use that variable. As a
degenerate case, you can use just a lone underscore, which means “some
anonymous variable.” So, we can fix our warnings by writing either

``` erlang
{ ok, {_Status, _Headers, Body }} = http:request(URL),

```

or

``` erlang
{ ok, {_, _, Body }} = http:request(URL),

```

I mildly prefer the first form, as it helps me remember what those
elements in the tuple are when I reread the program later.

Now we can recompile and run our code:

```
1> c(ranks).
{ok,ranks}
2> ranks:fetch_title_and_rank("0977616630").
"<?xml version=\"1.0\" encoding=\"UTF-8\"?><ItemLookupResponse
xmlns=\"http://webservices.amazon.com/AWSECommerceService/2005-10-05\">
<OperationRequest><HTTPHeaders><Header ...
   ... <SalesRank>1098</SalesRank>
   ... <Title>Agile Web Development with Rails (Pragmatic
        Programmers)</Title>...
   ...

```

Cool! We get a boatload of XML back. (If you’re running this at home,
you’ll need to substitute your own AWS subscription ID into the
request string to make this work.) Now we need to extract out the
title and the sales rank. We could to this using string operations,
but wouldn’t it be more fun to use XPath? Another quick filesystem
scan reveals the xmerl library, which both generates and parses
XML. It also supports XPath queries. To use this, we first scan the
Amazon response. This constructs an Erlang data structure representing
the original XML. We then call the `xmerl_xpath` library to find the
elements in this data structure matching our query.


``` erlang
-include_lib("xmerl/include/xmerl.hrl").

fetch_title_and_rank(ISBN) ->
  URL = amazon_url_for(ISBN),
  { ok, {_Status, _Headers, Body }} = http:request(URL),
  { Xml, _Rest } = xmerl_scan:string(Body),
  [ #xmlText{value=Rank} ]  = xmerl_xpath:string("//SalesRank/text()", Xml),
  [ #xmlText{value=Title} ] = xmerl_xpath:string("//Title/text()", Xml),
  { Title, Rank }.

```

The `-include` line loads up the set of Erlang record definitions that
xmerl uses to represent elements in the parsed XML. This isn’t
strictly necessary, but doing so makes the XPath stuff a little
cleaner.

The line

``` erlang
{ Xml, _Rest } = xmerl_scan:string(Body),

```

parses the XML response, storing the internal Erlang representation in
the variable `Xml`.

Then we have the line


``` erlang
[ #xmlText{value=Rank} ]  = xmerl_xpath:string("//SalesRank/text()", Xml),

```

The notation `#xmlText` identifies an Erlang _record_. A record is
basically a tuple where each element is given a name. In this case the
tuple (defined in that `.hrl` file we included) is
called `xmlText`. It represents a text node in the
XML. The `xmlText` record has a field called `value`. We use pattern
matching to assign whatever is in that field to the variable Rank. But
there’s one more twist. Did you notice that we wrote square brackets
around the left hand side of the pattern match? Thats because XPath
queries return an array of results. By writing the left hand side the
way we did, we force Erlang to check that an array containing just one
element was returned, and then to check that this element was a record
of type `xmlText`. That’s pretty cool stuff—pattern matching extends
down deep into the bowels of Erlang.


The last line of the method simply returns a tuple containing the
title and the sales rank.


We can call it from the command line:

```
1> c(ranks).
{ok,ranks}
2> ranks:fetch_title_and_rank("0977616630").
{"Agile Web Development with Rails (Pragmatic Programmers)","1098"}

```

That’s it for now. Next we’ll look at fetching the data for multiple
books at once. In the meantime, here’s the full listing of
our `ranks.erl` file.



``` erlang
-module(ranks).
-export([fetch_title_and_rank/1]).
-include_lib("xmerl/include/xmerl.hrl").

-define(BASE_URL, 
      "http://webservices.amazon.com/onca/xml?" ++
      "Service=AWSECommerceService" ++
      "&SubscriptionId=<your id>" ++
      "&Operation=ItemLookup" ++
      "&ResponseGroup=SalesRank,Small" ++
      "&ItemId=").


fetch_title_and_rank(ISBN) ->
  URL = amazon_url_for(ISBN),
  { ok, {_Status, _Headers, Body }} = http:request(URL),
  { Xml, _Rest } = xmerl_scan:string(Body),
  [ #xmlText{value=Rank} ]  = xmerl_xpath:string("//SalesRank/text()", Xml),
  [ #xmlText{value=Title} ] = xmerl_xpath:string("//Title/text()", Xml),
  { Title, Rank }.

amazon_url_for(ISBN) ->
  ?BASE_URL ++ ISBN.
```


