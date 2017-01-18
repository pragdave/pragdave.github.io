---
layout: post
title: "Class factories in Coffeescript"
date: 2014-01-28
comments: true
tags: [javascript, design]
---


There’s a neat trick for dynamically constructing heterogeneous
classes using a single factory function in CoffeeScript.(This is
probably a common pattern among Coffeescript cognoscenti, but I hadn’t
bumped into it, so I thought it was worth jotting down.)


I’m in the middle of writing a CoffeeScript application which handles
a variety of related but different user interface widgets. I’d
normally treat each as an independent class, and use mixins for the
common functionality. But in this particular app, it turns out to be
incredibly convenient to have a single factory method that takes a DOM
element and uses a data-type attribute to generate an object of the
correct class. That is, given


``` html
<article class="widget" data-type="Wibble">
    …
</article>
```

I’d want an object of class `Wibble`, and given

``` html
<article class="widget" data-type="Wobble">
    …
</article>
```

I’d want a `Wobble` object.

The initialization code to create these objects will look something like


``` javascript
$(".widget").map(function (_,el) { return Widget.for_element($(el)) })
```

Here’s what I came up with for the `for_element` factory method.


``` coffeescript
class Widget
    @for_element: (el) ->
        type = el.data("type")
        new @[type](el)

    constructor: (@el) ->

class Widget.Wibble extends Widget
    constructor: (el) ->
        # subclass-specific stuff
        superclass Widget.Wobble extends Widget
    constructor: (el) ->
        # subclass-specific stuff
        super
```

The fun part of this is that by namespacing the individual widget
subclasses in the parent `Widget` class, I can use `new @[type](el)`
to look up the subclass in the factory, and then instantiate the
object.


