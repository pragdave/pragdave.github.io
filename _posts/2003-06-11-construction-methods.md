---
layout: post
title: "Construction Methods"
date: 2003-06-11
comments: true
tags: [ "ruby", "design"]
---

A recent thread in ruby-talk reminded me of a change in the way I’ve
been writing classes over the last year or so.


In the past, I used to enjoy the ability to overload constructors. To
create a rectangle given two points, I might write:


``` java
  Point p1 = new Point(1,1);
  Point p2 = New Point(3,4);

  rect = new Rectangle(p1, p2)

```

Alternatively, I might want to create a rectangle given one point, a
width, and a height:


``` java
  rect = new Rectangle(p1, 2, 3);

```

Inside class Rectangle, I’d have two constructors:

``` java
  public Rectangle(Point p1, Point p2) { ... }

  public Rectangle(Point p1, double width, double height) { ... }

```

The problem with this approach is that is breaks down when the
different styles of constructor can’t be distinguished based on
argument type. It also makes the code harder to read: if you see


``` java
  new Rectangle(p, r, t);

```

where are the hints as to what’s going on?

So now when I write a class with multiple construction requirements, I
tend make the constructor itself private, so it can’t be called
outside of the class. Instead I use a number of static (class) methods
to return new objects. These methods can have descriptive names
(often with_xxx, for_xxx, orhaving_xxx), and I don’t have to worry
about parameter types. As a silly example, the following Ruby class
has three constructor methods, letting me build a square by giving its
area, its diagonal, or a side. What it won’t let you do is construct
the object by calling new, as the constructor itself is private.



``` ruby
  class Square
     def Square.with_area(area)
        new(Math.sqrt(area))
     end

     def Square.with_diagonal(diag)
         new(diag/Math.sqrt(2))
     end

     def Square.with_side(side)
         new(side)
     end

     private_class_method :new

     def initialize(side)
       @side = side
     end

  end

  s1 = Square.with_area(4)
  s2 = Square.with_diagonal(2.828427)
  s3 = Square.with_side(2)

```

Of course this is nothing new to Smalltalk folks (nor is it
particularly new or revolutionary elsewhere). However, it does seem to
be less common than it should be in the Java world. Just because
you _can_overload constructors doesn’t mean that it’s the best way to
code your classes.

