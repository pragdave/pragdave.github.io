---
layout: post
title: "Test-First Word Wrap in Erlang"
date: 2007-04-19 19:00:00 -0600
comments: true
categories: []
---



<img src="https://31.media.tumblr.com/500bb8a3ebe22cc464658c99808551c5/tumblr_inline_my11jjuj6F1rgo2z9.jpg"/>





I’m continuing to play with Erlang. This week, I needed to write some code that extracts information from a bunch of source files. Part of the output was supposed to be a list of strings, nicely word wrapped to fit on a terminal screen.


I decided to experiment with using a test-first approach to developing the word wrap function. I wrote unit tests that describe the functionality I want, and then wrote some code to make the tests run successfully.


To do that, I used the new EUnit-2.0 unit testing framework. It’s still under development, but it seems to work nicely (although I’d love for it to have an `assert_equal` method).

Installing EUnit

First, we’ll install EUnit from their Subversion repository:



```
  [dave/Erlang/common] svn co <a href="http://svn.process-one.net/contribs/trunk/eunit">http://svn.process-one.net/contribs/trunk/eunit</a>
  A    eunit/Emakefile
  A    eunit/sys.config
  A    eunit/include
   :     :     :
  [dave/Erlang/common] cd eunit
  [Erlang/common/eunit] make
   :     :     :

```



Now we need to add the EUnit library into your default Erlang path. Edit the file `.erlang` in your home directory (create it if it’s not there already) and add the line



```
  code:add_pathz("/Users/dave/Erlang/common/eunit/ebin").

```




(You’ll need to change the path to reflect the location where you downloaded EUnit. Remember to add the `/ebin` part at the end. And, yes, the “z” is really path of that line.)

EUnit In 60 Seconds

EUnit basically lets you run assertions against Erlang code. You can use it in a number of different modes. In our case we’ll include the tests in the same file that contains the code we’re testing. This is very convenient, but longer term it has a downside—anyone using your code will also need to have EUnit installed, even if they don’t want to run the tests. So, later we can split the tests into their own file.


The key to using EUnit is including the library in the source file containing the tests. That’s as simple as adding the line:



```
  -include_lib("eunit/include/eunit.hrl").

```



Any module that includes this line will automatically have a new function called `test/0` defined. This`test` function will automatically run all the tests in the module.


So, how do you define tests? As with any xUnit framework, you can write tests by defining regular methods that follow a naming convention. With EUnit, the convention is that the function name should end `_test`. The EUnit convention is that any test function that returns is considered to have completed successfully; any function that throws an exception is a failure. It’s common to use pattern matching as a kind of assertion:



```
  length_test()  ->  3 = length("cat").
  reverse_test() ->  [3, 2, 1] = lists:reverse([1,2,3]).

```



However, for simple tests, it’s easier to write a test generator. This is a function whose name ends`_test_` (with a final underscore). Test generators return a representation of the tests to be run. In our case, we’ll return a list of tests created using the EUnit `_assert` macro. We can rewrite our previous two test functions using a test generator called `demo_test_`:



```
  demo_test_() -> [
    ?_assert(3 == length("cat")),
    ?_assert([3, 2, 1] == lists:reverse([1,2,3]))
  ].

```



Here the generator returns an array containing two tests. The tests are written using the `_assert`macro. This takes a boolean expression (rather than a pattern) which is why we’re now using two equals signs.

Word Wrap

My application needs a library function which takes an array of strings and joins them together to form an array of lines where no line is longer than a given length. We’ll write a function `wrap/1` in a module called `text`. Let’s start with a basic test. If you wrap no words, you get a single empty line.



```
  -module(text).
  -export([wrap/1]).

  -include_lib("eunit/include/eunit.hrl").


  wrap_test_() -> [
    ?_assert(wrap([]) == [""])
  ].

```



This won’t compile: the `wrap/1` function hasn’t been defined. Getting it to pass this single test isn’t hard:



```
  wrap([]) ->
      [ "" ].

```



We can run this in the Erlang shell:



```
  1> c(text).
  {ok,text}
  2> text:test().
    Test successful.
  ok

```



Let’s add the next test. Wrapping a single short word should result in a single line containing that word.



```
  wrap_test_() -> [
    ?_assert(wrap([]) == [""]),
    ?_assert(wrap(["cat"]) == ["cat"])
  ].

```



The tests now fail when we run them: our `wrap` function doesn’t yet know how to wrap strings:



```
  1> c(text).
  {ok,text}
  2> text:test().
  text:9:wrap_test_...*failed*
  ::{error,function_clause,
           [{text,wrap,[["cat"]]},{text,'-wrap_test_/0-fun-2-',0}]}

  =======================================================
    Failed: 1.  Aborted: 0.  Skipped: 0.  Succeeded: 1.  error

```



Let’s see if we can fix this. We’ll add a second version of the `wrap/1` function that knows how to wrap a single string. Do do this, we’ll use a key feature of Erlang.

Pattern Matching and Function Definitions

In the same way that Erlang uses pattern matching when evaluating the `=` operator, it also uses pattern matching when invoking functions. This is often illustrated with an inefficient implementation of a function to calculate the nth term in the Fibonacci sequence (the sequence that goes 0, 1, 1, 2, 3, 5, …, where each term is the sum of the preceding two terms).



```
  -module(fib).
  -export([fib/1]).

  fib(0) -> 1;
  fib(1) -> 1;
  fib(N) -> fib(N-1) + fib(N-2).

```



Here we have three definitions of the same function (note how they’re separated by semicolons, and terminated with a period). The first two match when the function is called with a parameter or zero or one. The third is called with any other parameter.


We can use this to define two versions of our `wrap/1` function, one for the case where it is called with no words in the list, the other when we have a single string.



```
  wrap([]) ->
    [ "" ];

  wrap([String]) ->
    [ String ].

```



The tests now pass.



```
  9> text:test().
    All 2 tests successful.

```



Add a test which wraps two strings, though, and our tests again fail:



```
  wrap_test_() -> [
    ?_assert(wrap([]) == [""]),
    ?_assert(wrap(["cat"]) == ["cat"]),
    ?_assert(wrap(["cat", "dog"]) == ["cat dog"])
  ].

```




```
  text:10:wrap_test_...*failed*
  ::{error,function_clause,
           [{text,wrap,[["cat","dog"]]},{text,'-wrap_test_/0-fun-4-',0}]}

```



We’re going to have to do some work. For a start, we’re going to have to rewrite our wrap methods to give them somewhere to store the result. Then they’re going to have to recurse over the input parameter list, adding each word to the output until the input is exhausted.

Building an Output List

We’re going to do two things here. The externally visible function, `wrap/1`, is simply going to invoke an internal function, `wrap/2`, passing it the word list and an addition parameter. This second parameter is the list that holds the results. Remember that in Erlang the number of arguments is part of a function’s signature, so `wrap/1` and `wrap/2` are separate functions.


Then we’re going to use our parameter matching trick to define two variants of `wrap/2`:



```
  % This is the exported function: it passes the initial
  % result set to the internal versions
  wrap(Words) ->
    wrap(Words, [""]).

  % When we run out of words, we're done    
  wrap([], Result) ->
    Result;

  % Otherwise append the next word to the result
  wrap([NextWord|Rest], Result) ->
    wrap(Rest, [ Result ++ NextWord]).

```



The second version of `wrap/2` uses a neat feature of Erlang list notation. The pattern `[NextWord|Rest]`matches a list whose head is matched with `NextWord` and whose tail is matched with `Rest`. If we invoked this function with:



```
  wrap([ "cat", "dog", "elk" ], Result).

```



then `NextWord` would be set to `"cat"` and `Rest` would be set to `["dog", "elk"]`.


Unfortunately, this fails our test:



```
  1> c(text).    
  {ok,text}
  2> text:test().
  text:10:wrap_test_...*failed*
  ::{error,{assertion_failed,[{module,text},
                              {line,10},
                              {expression,
                                  "wrap ( [ \"cat\" , \"dog\" ] ) == [ \"cat dog\" ]"},
                              {expected,true},
                              {value,false}]},
           [{text,'-wrap_test_/0-fun-4-',0}]}

  =======================================================
    Failed: 1.  Aborted: 0.  Skipped: 0.  Succeeded: 2.

```



This is where I wish EUnit had an `assert_equals` function that could report the actual and expected values. However, I can still invoke my wrap method from the shell to see what it’s returning. (Stop press: EUnit does have the equivalent, and I didn’t notice it. It’s called `assertMatch(Expected, Actual)`. Sorry.)



```
  3> text:wrap(["cat", "dog"]).
  ["catdog"]

```



Oops. We forgot the space between words. We need to add this when we add a word to an existing line, but only if that line is not empty. See how we use pattern matching to distinguish a list containing an empty line from one containing a non-empty one.



```
  % This is the exported function: it passes the initial
  % result set to the internal versions
  wrap(Words) ->
    wrap(Words, [""]).

  % When we run out of words, we're done    
  wrap([], Result) ->
    Result;

  % Adding a word to an empty line
  wrap([NextWord|Rest], [ "" ]) ->
    wrap(Rest, [ NextWord]);

  % or to a line that's already partially full  
  wrap([NextWord|Rest], [ CurrentLine ]) ->
    wrap(Rest, [ CurrentLine ++ " " ++ NextWord]).

```



Now our tests pass again:



```
  1> c(text).
  {ok,text}
  2> text:test().              
    All 3 tests successful.
  ok

```


When Clauses

For testing purposes, let’s assume that we wrap lines longer than 10 characters. That means that if we give our method the strings “cat”, “dog”, and “elk”, we’ll expect to see two lines in the output (because “cat<space>dog<space>elk” is 11 characters long). Time for another test.



```
  wrap_test_() -> [
    ?_assert(wrap([]) == [""]),
    ?_assert(wrap(["cat"]) == ["cat"]),
    ?_assert(wrap(["cat", "dog"]) == ["cat dog"]),
    ?_assert(wrap(["cat", "dog", "elk"]) == ["cat dog", "elk"])
  ].

```



We don’t even have to run this to know it will fail: our `wrap` function knows nothing about line lengths. Time for some code. We’re now going to have to treat out result as a list or strings, rather than a single string. We’re also going to have to deal with the case where there’s not enough room in the current output line for the next word. In that case we have to add a new empty line to the function’s result and put the word into it.



```
  wrap(Words) ->
    wrap(Words, [""]).

  % When we run out of words, we're done    
  wrap([], Result) ->
    Result;

  % Adding a word to an empty line
  wrap([NextWord|Rest], [ "" | PreviousLines ]) ->
    wrap(Rest, [ NextWord | PreviousLines ]);

  % or to a line that's already partially full  
  % there are two cases:
  % 1. The word fits
  wrap([NextWord|Rest], [ CurrentLine | PreviousLines ]) 
    when length(NextWord) + length(CurrentLine) < 10 ->
    wrap(Rest, [ CurrentLine ++ " " ++ NextWord | PreviousLines ]);

  % 2. The word doesn't fit, so we create a new line    
  wrap([NextWord|Rest], [ CurrentLine | PreviousLines ]) ->
    wrap(Rest, [ NextWord, CurrentLine | PreviousLines ]).


This introduces a new Erlang feature—you can further qualify the pattern
matching used to determine which function is selected using a when
clause. In our case, the parameter patterns for the last two definitions of the
wrap/2 method are the same. However, the first of them has a
whenclause
```



. This means that this function will only be selected if the length of the current output line plus the length of the next word is less that our maximum line length (hard coded to 10 in this case).


Unfortunately, our tests fail:



```
1> text:test().              
text:11:wrap_test_...*failed*
::{error,{assertion_failed,[{module,text},
                            {line,11},
                            {expression,
                                "wrap ( [ \"cat\" , \"dog\" , \"elk\" ] ) == [ \"cat dog\" , \"elk\" ]"},
                            {expected,true},
                            {value,false}]},
         [{text,'-wrap_test_/0-fun-6-',0}]}

=======================================================
  Failed: 1.  Aborted: 0.  Skipped: 0.  Succeeded: 3.
error

```



Running `text:wrap` manually shows why:



```
2> text:wrap(["cat", "dog", "elk"]).
["elk","cat dog"]

```



We’re building the result list backwards, adding each successive line to the front of it, rather than the back. We could fix that by changing the way we add lines to the list, but, like Lisp, Erlang favors list manipulations that work on the head of the list, not the last element. It turns out to be both idiomatic and more efficient to build the result the way we’re doing it, and then to result the resulting list before returning it to our caller. That’s a simple change to our exported `wrap/1` function.



```
  wrap(Words) ->
    lists:reverse(wrap(Words, [""])).

```



Now all out tests pass.


So, let’s review our tests. We have covered an empty input set, a set that fits on one line, and a set that (just) forces the result to take more than one line. Are there any other cases to consider? It turns out that there’s (at least) one. What happens if a word is too long to fit on a line on its own? Let’s see:



```
  wrap_test_() -> [
    ?_assert(wrap([]) == [""]),
    ?_assert(wrap(["cat"]) == ["cat"]),
    ?_assert(wrap(["cat", "dog"]) == ["cat dog"]),
    ?_assert(wrap(["cat", "dog", "elk"]) == ["cat dog", "elk"]),
    ?_assert(wrap(["cat", "dog", "hummingbird", "ibix"]) == ["cat dog", "hummingbird", "ibix"])
  ].

```



Run the tests:



```
1> c(text).                         
{ok,text}
2> text:test().
  All 5 tests successful.
ok

```


Wrapping Up

Using simple tests like this are a great way of designing some code. They’re also a goo way to teach yourself the language. As I was writing this code, I used the tests to test my understanding of Erlang semantics.


**Update:** Kevin Smith has produced a wonderful screencast on EUnit as episode 5 of his <a href="http://pragprog.com/screencasts/v-kserl/erlang-by-example">Erlang by Example</a> series.

The Final Program


```
-module(text).
-export([wrap/1]).

-include_lib("eunit/include/eunit.hrl").

wrap_test_() -> [
  ?_assert(wrap([]) == [""]),
  ?_assert(wrap(["cat"]) == ["cat"]),
  ?_assert(wrap(["cat", "dog"]) == ["cat dog"]),
  ?_assert(wrap(["cat", "dog", "elk"]) == ["cat dog", "elk"]),
  ?_assert(wrap(["cat", "dog", "hummingbird", "ibix"]) == ["cat dog", "hummingbird", "ibix"])
].

% This is the exported function: it passes the initial
% result set to the internal versions
wrap(Words) ->
    lists:reverse(wrap(Words, [""])).

% When we run out of words, we're done  
wrap([], Result) ->
    Result;

% Adding a word to an empty line
wrap([ NextWord | Rest ], [ "" | PreviousLines ]) ->
    wrap(Rest, [ NextWord | PreviousLines ]);

% Or to a line that's already partially full. There are two cases:
% 1. The word fits
wrap([ NextWord | Rest ], [ CurrentLine | PreviousLines ]) 
  when length(NextWord) + length(CurrentLine) < 10 ->
    wrap(Rest, [ CurrentLine ++ " " ++ NextWord | PreviousLines ]);

% 2. The word doesn't fit, so we create a new line  
wrap([ NextWord | Rest], [ CurrentLine | PreviousLines ]) ->
    wrap(Rest, [ NextWord, CurrentLine | PreviousLines ]).
```


