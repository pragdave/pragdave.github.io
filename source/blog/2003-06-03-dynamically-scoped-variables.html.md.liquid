---
layout: post
title: "Dynamically Scoped Variables"
date: 2003-06-03
comments: true
tags: [ "ruby" ]
---

Whenever I write complex systems, I find I need a way to keep context
information lying around. For example I may pick up a set of user
preferences for colors at the top level of some code, but then I need
them when I get fifteen levels deep, somewhere within the bowels of a
component’s paint method. Or perhaps I get a database connection at
the start of request handling, but then need to use it when I get
deeply nested inside some application code.


These types of scenario seem to have no easy answer. Sometimes you
solve it by passing a common parameter to all your methods. This
parameter then contains references to all the context information
needed by the application code. But this is a messy approach: it means
that all your methods have to accept and pass on a parameter that they
don’t necessarily need themselves.


A variant of the above is to pass the context object to every
constructor, and then store a reference in an instance variable. This
suffers from the same drawbacks; every object is carrying around
payload that it might not itself need.


Sometimes you can get away with using singletons to store this kind of
stuff, but this rapidly breaks down (or at least becomes unwieldy) in
the face of multi-threading.


There is another answer, though: _dynamically scoped variables_.


Most languages offer lexically-scoped variables. When a program is
compiled, variable names are looked up by first examining the
enclosing scope, then the scope that lexically encloses that scope,
and so on. Variables are bound according to their static location in
the source code.


However, another kind of variable binding is remarkably useful for
passing around context information. Dynamically scoped variables are
resolved not at compile time but at run time. When a dynamically
scoped variable is referenced, the runtime looks for an appropriate
variable in the current stack frame. If none is found, it looks in the
caller’s stack frame, and then in that stack frame’s caller, and so
on. That way you can set the context in one method, then call multiple
levels deep, and still reference it.


Many languages offer dynamically scoped variables: Lisp, TCL,
Postscript, and Perl to name a few. In Perl, you could use local to
achieve the effect:



``` perl
  sub update_widget() {
      print "<$color>$name</$color>\n";
  }

  sub update_screen() {
      update_widget;
  }

  sub do_draw() {
      local $name = "dave";
      local $color = "red";
      update_screen();
  }

```



Although easy to use, locals in Perl are hard to control. And Perl’s
features don’t help me much anyway; I needed a Ruby solution. I came
up with something that’ll let me do the following.



``` ruby
  def update_widget
    name = find_in_context(:name)
    color = find_in_context(:color)
    puts "<#{color}>#{name}</#{color}>"
  end

  def update_screen
    update_widget
  end

  with_context(:name => 'dave', :color => 'red') do
    update_screen
  end

```



The `with_context` block establishes a set of dynamic variables (the
parameters to the call). Within any method called at any level during
the execution of the `with_context` block, a call
to `find_in_context` looks up the appropriate dynamic variable’s value
and returns it.

The implementation I came up with allows nested dynamic scopes, so the code:

``` ruby
  with_context(:name => 'dave', :color => 'red') do
    with_context(:name => 'fred', :color => 'green') do
      update_screen
    end
    update_screen
  end

```

outputs:

``` ruby
  <green>fred</green>
  <red>dave</red>

```

The actual implementation itself is a tad ugly (and I’d welcome
alternatives), but right now I view it as something of a singing pig.

``` ruby
  def with_context(params)
    finder = catch(:context) { yield }
    finder.call(params)  if finder
  end

  def find_in_context(name)
    callcc do |again|
      throw(:context, proc {|params|
        if params.has_key?(name)
          again.call(params[name])
        else
          raise "Can't find context value for #{name}"
        end
      })
    end
  end

```


Update…

And of course, it took less than eight hours for a more elegant
implementation to surface (I love the Ruby community). Tanaka Akira
posted:


``` ruby
  def with_context(params)
    Thread.current[:dynamic] ||= []
    Thread.current[:dynamic].push params
    begin
      yield
    ensure
      Thread.current[:dynamic].pop
    end
  end

  def find_in_context(name)
    Thread.current[:dynamic].reverse_each {|params|
      return params[name] if params.has_key? name
    }
    raise "Can't find context value for #{name}"
  end

```

Update #2…

And Avi Bryant massages the original into this masterpiece of minimalism…

``` ruby
  def with_context(params)
   k, name = catch(:context) {yield; return}
   k.call(params[name] || find_in_context(name))
  end

  def find_in_context(name)
    callcc{|k| throw(:context, [k, name])}
  end
```


