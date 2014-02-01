---
layout: post
title: "Shoulda used this earlier"
date: 2008-04-27 19:00:00 -0600
comments: true
categories: []
---

In many ways, testing software is like going out and getting exercise. You know you should do it, and you know it does you good, but it’s also pretty easy to find an excuse to skip it (I’ll make it up tomorrow).


So anything that makes testing easier is good, because it cuts down on the excuses not to do it.


One thing I’ve never really liked about the conventional xUnit-style testing frameworks was the setup and teardown structure. In these frameworks, a test case is a class, and setup and teardown are implemented by methods in that class. Each test is also a method, so the basic flow is



```
  for each test method in the class
    run setup
    run the test method
    run teardown
  end

```



Nice and simple. Each test method got the benefit of a standard environment created by the setup method, and the teardown method got the job of tidying up after.


Except… when I’m writing tests, I typically want to set up lots of different scenarios. I’ll want A and B and C, then A and B but not C, then A and not B, then A and D, and so on. I had two choices—write lots of test case classes, using subclassing to inherit common setup behavior, or write per-test method setup code (often factored out into helpers). In the end, I almost always did the latter, And that was tedious, and it made it harder to see the tests for the setup code.


I flirted with RSpec. Its spec framework seemed to have what I wanted. But I just couldn’t get myself to enjoy using it. (I think it’s a cat people/dog people kind of thing)

Enter shoulda

Then, a couple of weeks back, Mike Clark and Chad Fowler introduced me to <a href="http://www.thoughtbot.com/projects/shoulda">shoulda</a>. Shoulda isn’t a testing framework. Instead, it extends Ruby’s existing Test::Unit framework with the idea of test_contexts_. A context is a section of your test case where all the test methods have something in common. At it simplest, a context could be simply used as an annotation device (and, yes, this is a silly example):



```
context "My factorial method" do
  should "return 1 when passed 0" do
    assert_equal 1, fact(0)
  end
  should "return 1 when passed 1" do
    assert_equal 1, fact(1)
  end
  should "return 6 when passed 3" do
    assert_equal 6, fact(3)
  end
end    

```



The stuff in a context can share common setup code—just write a `setup` block.



```
class CartTest < Test::Unit::TestCase

  context "An empty cart" do
    setup do
      @cart = orders(:wilmas_empty_cart)
    end

    should "have no line items" do
      assert_equal 0, @cart.line_items.size
    end

    should "have a zero price" do
      assert_equal 0, @cart.price
    end
  end

  context "Some other context..." ...
  end
end

```



So now, within a single test case I can set up multiple contexts, and each context can have its own environment.


But, take it back to my original problem. I often want to set up hierarchies of related environments for my tests. The shaoulda code handles this wonderfully, because it lets me nest contexts. For example, I’m adding a feature to our store that gives customers some additional information if, during checkout, their credit card transaction was initially rejected because the address was wrong, and was then accepted when they fixed the address. I wanted two tests, one without the prior address error, and one with.


To set up this environment, I needed to set up a shopping cart, create a dummy response from our payment gateway, and post that response to the application. In the case of the prior address error, I also wanted to inject an entry containing that error into the transactions associated with the order prior to generating the response.


With shoulda, I simply created some nested contexts. The top level context did the shared setup, and the inner contexts then set up appropriate environments for their tests. It looked like this:



```
  context "Checking out"  do
    setup do
      @cart = cart_named(:freds_full_cart)
      @cart.prepare_for_store_authorize!
      @params = approved_authnet_response(@cart)
    end                  
    
    context "with no AVS errors in CC transaction history" do
      setup do
        post :post_from_authnet_authorize, @params
      end

      should_redirect_to "{:action => :receipt}"
    end 
    
    context "with AVS errors in CC transaction history" do
      setup do
        avs_error = CcTransaction.new(:response_code => 2, :response_reason_code => 27)
        @cart.cc_transactions << avs_error
        post :post_from_authnet_authorize, @params
      end

      should_redirect_to "{:action => :explain_avs_mismatch}"
    end
  end 

```



The outer setup gets run before the execution of each of the inner contexts. And the setup in the inner contexts gets run when running that context. And shoulda keeps track of it all, so I get very natural error messages if an assertion fails. For example, if the test in the second context above fails, I’d get



```
Checking out with AVS errors in CC transaction history should 
redirect to "{:action => :explain_avs_mixsmatch}". 

```



So, now, I can finally set up my hierarchies of test environments in a natural way. It isn’t revolutionary. It’s just one less excuse for not testing…

