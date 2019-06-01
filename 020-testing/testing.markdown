# Testing Basics

## What Is the Point Of Writing Tests?

Before starting writing tests, we should ask ourselves the fundamental questions: what's the point of doing that? How are we going to benefit from writing tests? It's a complicated and time-consuming process, do the benefits outweigh the costs?

The essential benefit of writing tests is a confidence that the code we wrote works. The only alternative to writing tests is "testing" manually (e.g., by clicking through the different scenarios using the browser) which requires a lot of effort as well and doing it over and over again will eventually take much more time than writing automated tests.

It is not only when implementing new features that we need to verify if our application works fine - having well-written and the comprehensive test suite is also crucial when modifying existing behavior and doing refactoring. Can you imagine testing manually every possible scenario after applying every minor change? Neither can I. That way we get a powerful anti-regression tool which provides instant feedback. We've modified some code, and we have failing tests? Awesome! We know from the very beginning that *something* is not right and we can quickly fix it.

Another important aspect of writing automated tests is the ease of finding bugs. Imagine that you are maintaining a huge application and the users start complaining that some feature doesn't work as it should. How fast can you identify the culprit without test suite? It would certainly take a lot of time. With well-written tests, it would take much less time to find where the problem is. Not only do you have a feedback from higher-level acceptance tests that are interacting with real UI that *something* is not right, but also the unit tests that deal with much smaller scope will tell you what the issue is.

An extra advantage of writing automated tests (mostly applicable when doing **TDD**) is clarifying the intentions - you need to precisely define the consecutive steps to execute some logic, which helps to break the functionality into smaller, more manageable pieces. That way you easily become more productive and focused on the current task.

Thanks to having automated test-suite we come more productive and confident about our code which makes any changes easier and indirectly, by investing time in writing good tests, we save time on arduous debugging.

## Test-Driven Development

You've most likely heard the term **Test-Driven Development** or **Test-First Approach**. What do they mean and how they are different?

According to [Growing Object Oriented-Software Guided By Tests](http://www.growing-object-oriented-software.com) by Steve Freeman and Nat Pryce, a classic book about TDD, the idea of it is to *"write the tests for your code before writing the code itself"*. Well, that seems very similar to **Test-First Approach**, which is also about writing the tests before the code. The difference between those is subtle, and quite often those terms are used interchangeably.

**Test-First Approach** is about starting with a test and writing a minimal amount of code to make the test(s) pass. It is also the case in **TDD**. However, the important aspect of **Test-Driven Development** is **refactoring** phase, which helps with achieving a proper design - that way **TDD** also serves as a design tool, which doesn't matter that much in case of **Test-First Approach**.

To put it simply:

```
Test-First Approach + Refactoring => Test-Driven Development
```

## Why Is It Important To Write Tests First?

Now that we know that writing tests is pretty much essential in the long-term perspective, we should answer one more question: why does it even matter to write tests first? Why can't we just write the code and then add a couple of tests to verify if the features work as expected?

There are few reasons behind it. The fundamental one is that you can't be really sure that the test indeed works unless you've seen it failed. It is quite easy to have a false-positive in a test - the situation where the functionality doesn't work as intended, yet the tests are still passing. It might be just a coincidence (maybe something returned `undefined` but not because such value was supposed to be returned, but because it's never been defined in the first place!). Maybe you misused some testing library's feature which resulted in having such problem. You can still work around those issues and add tests later which happens quite often when working on the legacy apps. Nevertheless, it's simply safer, and it just takes less time to write the tests first without trying to apply some hacks later.

The other reason in that the tests may guide the design. When writing the implementation code, you're probably not focusing on the ease of testing as the primary thing, but rather the ease of writing the code itself. However, the easier the code is to test, the easier it is to use. It quite often results in better interfaces and overall design with less coupling between objects and having more cohesive units. Writing tests first doesn't necessarily guarantee that the code will always be well-designed; nevertheless, it's more likely to be the case than when writing the tests after the implementation.

Keep in mind that those rules are not hard laws or dogmas. Sometimes you may be implementing a feature that you've implemented already few times before or maybe something is just trivial, and you already have an idea about the entire design. Tests are for making out lives as developers easier. If you think there is no risk of writing the code first, then go ahead. I just wouldn't suggest making it a default approach and would rather stay with writing the tests first unless I'm 100% sure that I can do otherwise.

Also, when thinking about the tests as a tool for guiding the design, it's pretty convenient to do the testing from the outside in.

## Testing From The Outside-In

Testing from the outside in simply means starting from the higher-level tests and working from that point to lower-level tests.

Usually, it means writing a failing acceptance test for a particular feature, then writing some integration tests (in Ember applications those will be mostly components' integration tests) and ending with some unit tests for models, services, etc. It also means that there might be a reverse order of passing tests - the first passing test could be a model unit test, then component integration test and the last passing one could be the acceptance test that was written first.

The opposite approach to outside-in is the inside-out approach where you focus on isolated units and defer the decision how they are going to interact with each other. This strategy isn't necessarily wrong though - sometimes you may not know how to test given feature from the higher-level perspective. This might happen when you are implementing non-trivial functionality with some complex behavior - one example would be drag and drop. In such case, you may prefer starting with some lower level test (maybe with an integration one or even unit tests) and get back to acceptance tests later. You may lose some benefits of full TDD approach like the tests guiding your design, but still, there is a place for the outside-in approach. However, I believe by default you should always start with the outside-in approach and only try the inside-out approach if the former doesn't work well in particular use case.

## TDD vs. BDD

So far I haven't mentioned anything about **Behavior-Driven Development (BDD)** - a term which seems to be used quite often and sometimes even as the opposite approach to TDD.

Nevertheless, I believe there is no any major difference between those two. BDD advocates starting development by writing acceptance tests first, focusing on behavior. But this is the same as TDD done with the outside-in approach! Also, [Growing Object Oriented-Software Guided By Tests](http://www.growing-object-oriented-software.com), which is a classic on TDD, clearly says that starting with end-to-end (acceptance) tests is essential and that one should focus on describing the behavior, not the API of the objects.

Just to keep things simple and not introduce any confusion, I'll stick to **TDD** term later in the book, which might mean the same thing as **BDD** if you are more used to that phrase.

## Classification Of Tests

Based on the scope of tests and a number of layers of the application they involve, there are three levels of tests:

* Acceptance tests (end-to-end tests) - these tests cover all layers of the application and simulate user interaction, e.g., by filling forms and clicking the buttons in the browser. They are automated equivalent of manual testing by interacting with the application yourself.

* Integration tests - these tests involve multiple layers of an application, but they don't run the entire app. In context of Ember applications, those are mostly component tests which also involve components' collaborators (like injected services) or isolated and simplified user interaction (e.g., rendering and submitting a form from the component, but outside the context of the rest of the application)

* Unit tests - they are checking if the behavior of a particular unit is right. Note that it isn't necessarily about one object - a unit can be composed of multiple objects, but some of them they might be implementation details, or they don't exist outside given context.

## Test Pyramid

If you are a seasoned developer you've most likely heard about the concept of [Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html) which illustrates the idea that unit tests should be the fundament of your test suite on top of which you should have some integration tests and few acceptance tests, which will verify if the app truly works.

In case of server-side applications (or in general non-client-side applications) this makes a lot of sense - you don't want your UI interactions to make the majority of your tests as it's quite tricky to test all the edge cases that way and such tests are simply slow comparing to the unit or even integration tests. However, when it comes to Single Page Applications, it's quite the opposite - the entire application serves the purpose of the UI! The priorities are different, so is the test pyramid. In Ember apps (or any other SPAs) the acceptance tests may not necessarily make the majority of your tests (well, at least in terms of the amount, they are most likely going to take most of the time when running the entire test suite though), but as you will see in the next chapters the unit tests don't matter that much as you may initially think.

Some layers like routes and their hooks might not even be worth testing with unit tests at all as the acceptance tests will cover them as well. Unit testing actions in components also might not bring much value - perhaps the logic inside that action works fine, but you don't know if they are going to be executed properly. It's much safer to test the actions via component integration tests, which will provide us with a feedback not only about the logic itself but also if the component is wired-up properly and if it executes proper actions when handling some event.

However, unit tests remain quite important for testing edge cases and complex computed properties as they require much less overhead and are faster.

Considering the tests' structure in typical Ember application, it's probably no longer valid to talk about "pyramid" of tests. Rather, we may end up with Testing Cube without a clear foundation and a clear peak like in case of a pyramid, but with all three layers (acceptance, integration, and unit) mixed in different proportions and with all of them creating the foundation of solid test-suite.

## To Test Or Not To Test

As already stated before, there are some layers or part of those layers that might be not worth unit testing at all. I believe this is mostly true for testing hook methods' behavior in routes like `beforeModel`, `model` or `afterModel`, actions and most of the computed properties in components and arguably controllers. Let's break these three layers down and see what the better way to test them is:

* **routes** - hooks like `beforeModel`, `model` or `afterModel` are in most cases pretty simple and they in general fetch data from the remote API, do some transitions based on some conditions, etc. As those are hook methods, they are strictly connected to the request of the application and executed under specific circumstances, so such methods make a poor unit and it doesn't make much sense to test them in isolation. It's more convenient and safer to test them using acceptance tests as you will make sure that the route behaves properly in real-world interaction. Actions are a different story though. Some actions could be tested via acceptance tests as well, but if you have some complex logic there with multiple edge cases, writing unit tests would certainly help. You can either test all the edge cases in the route action itself or extract the logic to another object an just check if the right method is called on this object and the expected arguments are passed.

* **controllers** - they are said to be replaced eventually by routable components, but until this feature is ready, we need to learn how to test them. Controllers in Ember serve a role of a top-level component for given route. It's not currently possible to totally give up on controllers as they handle query params and transitions (though the latter can be handled on route-level with [route actions](https://github.com/DockYard/ember-route-action-helper)). Testing controllers highly depends on the current design of your application and if it's a new controller or some already existing controller which is packed with logic. For new controllers, I would suggest keeping some actions and computed properties to a minimum in the controller and moving actions to routes (that are modifying the data, just like the ol' good [Data Down Actions Up](http://www.samselikoff.com/blog/data-down-actions-up/) paradigm recommends) and moving other actions and computed properties to components. Query params should be tested via acceptance tests as it doesn't make much sense in isolation, they are bound to request cycle. That way we would end up with no unit tests for controllers. For already existing ones, you may approach testing actions exactly in the same way as for route actions - unit test the behavior or delegation. For computed properties though you should write proper unit tests and test all the edge cases unless it's something trivial that is already covered in acceptance tests.

* **components** - most of the tests you should be writing for components should be integration tests unless you have a very specific reason for writing unit tests. The integration tests are pretty simple to set up, and even if you have complex actions, you can just extract the behavior to a service, inject stubbed service in the test and verify if the right method on the service was called with expected arguments. Actions are never the isolated units; they are called as the result of some user interaction so they should be tested that way. Some user interactions might be difficult to simulate in integration tests, and such actions could be potential candidates for unit testing, but by default, it's better to always start with an integration test. And what about the computed properties? Unless they are very complex, you should also stick to integration tests.

All this means that the majority of the unit tests you will be writing will cover models and services.

\pagebreak
