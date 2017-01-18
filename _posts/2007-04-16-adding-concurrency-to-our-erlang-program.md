---
layout: post
title: "Adding Concurrency to Our Erlang Program"
date: 2007-04-16
comments: true
tags: [ "erlang"]
---


{%img1 right /img/crosswalk.jpg%}

In our last thrilling installment, we used Erlang to fetch a book’s
title and sales rank from Amazon. Now let’s extend this to fetch the
data for multiple books, first one-at-a-time, and then in parallel.

> A word from our lawyers:
>
> Read your Amazon Terms of Service before trying this code. You may
> have limitations on the number of requests you can send per second or
> somesuch. This code is just to illustrate some Erlang constructs.


Let’s start with the function that fetches sales ranks in
series. We’ll pass it a list of ISBNs, and it will return a
corresponding list of {title, rank} tuples. For convenience, let’s
define a function that returns a list of ISBNS to check. (Later, we
can change this function to read from a database or a file). We’re
editing our file `ranks.erl`.



``` erlang
isbns() ->
  [ "020161622X", "0974514004", "0974514012", "0974514020", "0974514039",
    "0974514055", "0974514063", "0974514071", "097669400X", "0974514047",
    "0976694018", "0976694026", "0976694042", "0976694085", "097451408X",
    "0976694077", "0977616606", "0976694093", "0977616665", "0976694069",
    "0976694050", "0977616649", "0977616657"
   ].

```

Users of our code call the `fetch_in_series` function. It uses the
built-in `lists:map` function to convert our ISBN list into the result
list.


``` erlang
fetch_in_series() ->
  lists:map(fun fetch_title_and_rank/1, isbns()).

```



The first parameter to `lists:map` is the function to be applied to
each element in the ISBN list. Here we’re telling Erlang to call
the `fetch_title_and_rank` function that we defined in the first
article. The`/1` says to use the version of the function that takes a
single argument.

We need to export this function from the module before we can call it.

``` erlang
-export([fetch_title_and_rank/1, fetch_in_series/0]).

```

Let’s fire up the Erlang shell and try it.

```
1> c(ranks).
{ok,ranks}
2> ranks:fetch_in_series().
[{"The Pragmatic Programmer: From Journeyman to Master","4864"},
 {"Pragmatic Version Control Using CVS","288118"},
 {"Pragmatic Unit Testing in Java with JUnit","116011"},
 . . .
 
```

“But wait!” I hear you cry. “Isn’t Erlang supposed to be good at
parallel programming. What’s with all this
fetch-the-results-in-series” business?”

OK, let’s create a parallel version. We have lots of options here, but
for now let’s do it the hard way. We’ll spawn a separate (Erlang)
process to handle each request, and we’ll write all our own process
management code to coordinate harvesting the results as these
processes complete.

Erlang processes are lightweight abstractions; they are not the same
as the processes your operating system provides. Unlike your operating
system, Erlang is happy dealing with thousands of concurrent
processes. What’s more, you can distribute these processes across
servers, processors, and cores within a processor. All this is
achieved with a handful of basic operations. To send a tuple to a
process whose process ID is in the variable Fred, you can use:


``` erlang
Fred  ! {status, ok}

```

To receive a message from another process, use a `receive` stanza:

``` erlang
receive 
  { status, StatusCode } -> StatusCode
end

```

There’s something cool about the `receive` code. See the line

``` erlang
{ status, StatusCode } -> StatusCode

```

The stuff on the left hand side of the arrow is a pattern match. It
means that this receive code will only accept messages which are a two
element tuple where the first element is the atom `status`. This
particular receive stanza then strips out just the actual code part of
this tuple and returns it. In general a receive stanza can contain
multiple patterns, each with its own specialized processing. This is
remarkably powerful.

There’s one last primitive we need. The function `spawn` takes a
function and a set of parameters and invokes that function in a new
Erlang process. It returns the process ID for that subprocess.

Let’s write a simple, and stupid, example. This module
exports `test/1`. This function spawns a new process that simply
doubles a value. Here’s the code—we’ll dig into it in a second.


``` erlang
-module(parallel).
-export([test/1]).

test(Number) ->
  MyPID = self(),
  spawn(fun() -> double(MyPID, Number) end),
  receive
      { answer, Val } -> { "Child process said", Val }
  end.

double(Parent, Number) ->
  Result = Number + Number,
  Parent ! { answer, Result }.

```

Because we’re handling all the details ourselves, we have to tell the
process running the `double` function where to send its result. To do
that, we pass it two parameters: the first is the process ID of the
process to receive the result, and the second is the value to
double. The second line of the `double` function uses the `!` operator
to send the result back to the original process.

The original process has to pass its own process ID to
the `double` method. It uses the built-in `self()`function to get this
PID. Then, on the second line of the function, it invokes spawn,
passing it an anonymous function which in turn invokes double. There’s
a wee catch here: it’s tempting to write:

``` erlang
test(Number) ->
  spawn(fun() -> double(self(), Number) end),
  ...

```

This won’t work: because the anonymous function only gets executed
once the new process is started, the value returned by `self()` will
be that process’s ID, and not that of the parent.

Anyway, we can invoke this code using the Erlang shell:

```
1> c(parallel).
{ok,parallel}
2> parallel:test(22).
{"Child process said",44}

```

Back to Amazon. We want to fetch all the sales ranks in
parallel. We’ll start with the top-level function. It starts all the
fetcher processes running in parallel, then gathers up their results.


``` erlang
fetch_in_parallel() ->
  inets:start(),
  set_queries_running(isbns()),
  gather_results(isbns()).

```

The first line of this method is a slight optimization. The HTTP
client code that we use to fetch the results actually runs behind the
scenes in its own process. By calling the `inets:start` method, we
precreate this server process.

Here’s the code that creates the processes to fetch the sales data:


``` erlang
set_queries_running(ISBNS) ->
  lists:foreach(fun background_fetch/1, ISBNS).

background_fetch(ISBN) ->
  ParentPID = self(), 
  spawn(fun() ->
              ParentPID ! { ok, fetch_title_and_rank(ISBN) }
        end).

```

The `lists:foreach` function invokes its first argument on each
element of its second argument. In this case, it invokes
the `background_fetch` function that in term calls `spawn` to start
the subprocess. Perhaps surprising is the fact that the anonymous
function acts as a closure: the values of `ParentID` and`ISBN` in its
calling scope are available inside the fun’s body, even though it is
running is a separate process. Cool stuff, eh?

There’s an implicit decision in the design of this code: I decided
that I don’t care what order the results are listed in the returned
list—I simply want a list that contains one title/rank tuple for each
ISBN. I can make use of this fact in the function that gathers the
results. It again uses `lists:map`, but bends its meaning
somewhat. Normally the map function maps an value onto some other
corresponding value. Here we’re simply using it to populate a list
with the same number of entries as the original ISBN list. Each entry
contains a result from Amazon, but it won’t be the result that
corresponds to the ISBN that is in the corresponding position in the
ISBN list. For my purposes, this is fine.


``` erlang
gather_results(ISBNS) ->      
  lists:map(fun gather_a_result/1, ISBNS).

gather_a_result(_) ->
  receive 
    { ok, Anything } -> Anything
  end.

```

Let’s run this:

```
1> c(ranks).
{ok,ranks}
2> ranks:fetch_in_parallel().
[{"The Pragmatic Programmer: From Journeyman to Master","6359"},
 {"Pragmatic Version Control Using CVS","299260"},
 {"Pragmatic Unit Testing in Java with JUnit","131616"},
 . . .

```

What kind of speedup does this give us? We can use the
built-in `timer:tc` function to call our two methods.

``` erlang
timer:tc(ranks, fetch_in_parallel, []).
   {1163694, . . .
timer:tc(ranks, fetch_in_series, []).  
   {3070261, . . .

```

The first element of the result in the wallclock time taken to run the
function (in microseconds). The parallel version is roughly 3 times
faster than the serial function.

So, do you have to go to all this trouble to make your Erlang code run
in parallel? Not really. I just wanted to show some of the nuts and
bolts. In reality, you’d probably use a library method, such as
the`pmap` function that Joe wrote for the <a
href="http://pragmaticprogrammer.com/titles/jaerlang/index.html">Programming
Erlang</a> book. Armed with this, you could turn the serial fetch
program to a parallel fetch program by changing


``` erlang
lists:map(fun fetch_title_and_rank/1, ?ISBNS).

```

to

``` erlang
 lib_misc:pmap(fun fetch_title_and_rank/1, ?ISBNS).

```

Now that’s an abstraction!

Anyway, here’s the current version of the `ranks.erl` program,
containing both the serial and parallel fetch functions.


``` erlang
-module(ranks).
-export([fetch_title_and_rank/1, fetch_in_series/0, fetch_in_parallel/0]).
-include_lib("xmerl/include/xmerl.hrl").

-define(BASE_URL,
        "http://webservices.amazon.com/onca/xml?Service=AWSECommerceService" 
        "&SubscriptionId=<your ID goes here>" 
        "&Operation=ItemLookup" 
        "&ResponseGroup=SalesRank,Small" 
        "&ItemId=").

isbns() ->
  [ "020161622X", "0974514004", "0974514012", "0974514020", "0974514039",
    "0974514055", "0974514063", "0974514071", "097669400X", "0974514047",
    "0976694018", "0976694026", "0976694042", "0976694085", "097451408X",
    "0976694077", "0977616606", "0976694093", "0977616665", "0976694069",
    "0976694050", "0977616649", "0977616657"
   ].

fetch_title_and_rank(ISBN) ->
  URL = amazon_url_for(ISBN),
  { ok, {_Status, _Headers, Body }} = http:request(URL),
  { Xml, _Rest } = xmerl_scan:string(Body),
  [ #xmlText{value=Rank} ]  = xmerl_xpath:string("//SalesRank/text()", Xml),
  [ #xmlText{value=Title} ] = xmerl_xpath:string("//Title/text()", Xml),
  { Title, Rank }.

amazon_url_for(ISBN) ->
  ?BASE_URL ++ ISBN.


fetch_in_series() ->
  lists:map(fun fetch_title_and_rank/1, isbns()).


fetch_in_parallel() ->
  inets:start(),
  set_queries_running(isbns()),
  gather_results(isbns()).

set_queries_running(ISBNS) ->
  lists:foreach(fun background_fetch/1, ISBNS).

background_fetch(ISBN) ->
  ParentPID = self(), 
  spawn(fun() ->
            ParentPID ! { ok, fetch_title_and_rank(ISBN) }
        end).

gather_results(ISBNS) ->      
  lists:map(fun(_) ->
          receive 
              { ok, Anything } -> Anything
          end
        end, ISBNS).
```

