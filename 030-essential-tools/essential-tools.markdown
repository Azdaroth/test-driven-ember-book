# Essential Tools

There are multiple tools that we'll be using in the next chapters of the book. Some of them will be introduced ad hoc when needed, but for now, let's focus on the essential ones.

## QUnit

### Introduction

[QUnit](https://qunitjs.com) is the default testing tool for Ember. Even though I used to be a [jasmine](https://jasmine.github.io) fanboy before I knew Ember, I quite quickly got used to QUnit and appreciated it for its simplicity.  The API is pretty limited, yet it offers everything you may need to write proper tests for your applications. Let's take a closer look how it works.

Here's a super short setup for QUnit:

```{.html .numberLines}
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width">
  <title>QUnit Example</title>
  <link rel="stylesheet" href="https://code.jquery.com/qunit/qunit-2.1.1.css">
</head>
<body>
  <div id="qunit"></div>
  <div id="qunit-fixture"></div>
  <script src="https://code.jquery.com/qunit/qunit-2.1.1.js"></script>
  <script src="tests.js"></script>
</body>
</html>
```

What we are doing here is fetching some stylesheets to have a clean and smooth testing page and the QUnit code itself. Let's add some tests to `tests.js` file and see QUnit in action:

``` {.javascript .numberLines}
QUnit.test("QUnit rockzzz", function(assert) {
  assert.ok(1 === 1, '1 should be equal to 1');
  assert.notOk(false, 'false if falsey');
  assert.equal(1 + 1, 2);
  assert.deepEqual([1, 2, 3], [1, 2, 3], 'deepEqual is so cool');
});
```

After opening the `tests.html` in a browser, we should see something like this:

![Qunit example](http://download.karolgalanciak.com/test-driven-ember/qunit_example.png)

### API Overview

#### Assertions

Let's start with explaining the syntax and then we will get back to the details of this tests' UI.

QUnit has a pretty limited API, it's not as flexible and elaborate as Jasmine, which syntax was inspired by powerful Ruby testing framework - [RSpec](http://rspec.info), but it's straightforward and easy to understand. We write test scenarios with `QUnit.test` method, which takes two arguments - the description of the test and callback where we put the test's body. The argument of the callback is `assert` object which contains the assertions. We can use `ok` or `notOk` assertions which check for truthiness or falseness and also assertions such as `equal` which performs non-strict comparison or `deepEqual` which according to the [docs](http://api.qunitjs.com/category/assert/) performs "a deep recursive comparison, working on primitive types, arrays, objects, regular expressions, dates, and function". It is possible also to provide an optional description of particular assertion as the last argument, which helps identify failures of the tests.

These are by no means the only capabilities of QUnit. Dealing with async functions is bread and butter when it comes to JavaScript. To make sure QUnit will wait for an asynchronous operation that is not finished you can use `async()` function. That way QUnit will wait until `done()` is called.

``` {.javascript .numberLines}
QUnit.test('async is awesome', function(assert) {
  const done = assert.async();

  setTimeout(function() {
    assert.ok(true, 'called from async function');
    done();
  }, 100);
});
```

QUnit doesn't provide any API for spying and mocking. Nevertheless, it is still possible to make sure some method or function is called. Just write an assertion within a given function and ensure that the right amount of assertions is called using `expect()`:

``` {.javascript .numberLines}
QUnit.test('testing with assert.expect', function(assert) {
  assert.expect(1);

  var $btn = $('btn');

  $btn.on('click', function() {
    assert.ok(true, 'the button was clicked');
  });

  $body.click();
});
```

If the total amount of assertions is not equal to the `count` argument passed to `expect()`, the tests will fail. That way we can make sure that all the expected assertions were performed.

There are also many other assertions available in QUnit, such as `assert.throws()` for catching the exceptions and I highly recommend to read the [official docs](http://api.qunitjs.com/category/assert/) for the quick overview, just to be aware of all of them.


#### Module And Hooks

In QUnit it's possible to group some tests in a `module` for clearer organization purposes, but also for providing hooks for what should happen `before` running tests, `beforeEach` test, `afterEach` test and `after` all tests. Check the following example:

``` {.javascript .numberLines}
QUnit.module('Awesomeness check', {
  before: function() {
    console.log('run me before all tests');
  },
  beforeEach() {
    console.log('run me before each test');
    this.awesomeFramework = 'Ember';
    this.isQUnitAwesome = true;
  },
  afterEach() {
    console.log('run me after each test');
  },
  after() {
    console.log('run me at the end');
  }
});

QUnit.test('Ember should be the awesome framework', function(assert) {
  assert.equal(this.awesomeFramework, 'Ember', 'Ember should be awesome');
});

QUnit.test('QUnit should be awesome', function(assert) {
  assert.ok(this.isQUnitAwesome, 'QUnit should be awesome');
});
```

We grouped some tests under a module with an awesome description and provided some hooks to demonstrate how they work. After running our test suite, all tests should pass, which will mean that the setup from `before` hook and assigning some values to `this` context works as expected and also the sequence of running the hooks is the same as discussed. After opening the console, we should see the following logs:

```
run me before all tests
run me before each test
run me after each test
run me before each test
run me after each test
run me at the end
```

#### QUnit UI

Let's get back to the cool UI we saw at the beginning of this chapter:

![Qunit example](http://download.karolgalanciak.com/test-driven-ember/qunit_example.png)

Besides showing all the tests and their statuses whether they are currently passing or not we have some options for customization:

* Hide passed tests - this options allows to not display the passed tests and only show the failed ones, which is what we want in most cases. If we tried to force some failure from the previous example and checked this checkbox, we would have the following result:

![Qunit failure example](http://download.karolgalanciak.com/test-driven-ember/qunit_example_hide_passed.png)

* Check for Globals - checking this options will make the QUnit check if some globals were introduced in any of the tests and fail those tests if that's the case. Let's get back to our initial example, introduce some global and take a look at the result:

``` {.javascript .numberLines}
QUnit.test("QUnit rockzzz", function(assert) {
  assert.ok(1 === 1, '1 should be qual to 1');
  assert.notOk(false, 'false if falsey');
  assert.equal(1 + 1, 2);
  assert.deepEqual([1, 2, 3], [1, 2, 3], 'deepEqual is so cool');

  window.uglyGlobal = 'fail the tests!';
});
```

After running the test suite, we will see the following result:

![Qunit Check for Globals example](http://download.karolgalanciak.com/test-driven-ember/qunit_example_globals.png)

* No try-catch - by default QUnit runs tests inside `try/catch` block, catches all the exceptions and then displays that some error has happened. Sometimes you may want QUnit to not catch these errors and get the "native" exception in the console - this is particularly useful when debugging as you will get the exact info where the problem happened.

* Module select - this select lets you pick a particular module that should be the subject of testing, useful especially in huge test suites.

* Filter input - this input allows to filter tests with a description matching the provided phrase, quite beneficial when you need to run only a particular subset of tests.

## ember-test-helpers & ember-qunit

**ember-test-helpers** provide the essential helpers required to test Ember applications. As this library is testing-framework-agnostic it requires some extra integration layer for some of the helpers, in our case it is ember-qunit, but it could also be something different like [ember-mocha](https://github.com/emberjs/ember-mocha).

Let's take a look at the provided helpers and how we can use them:

* `TestModule` (exposed as `moduleFor` in ember-qunit) - it's a basic building block for tests handling all the necessary setup and teardown essential to test given subject in the Ember ecosystem. It works for anything that could be looked up by Ember Resolver (models, components, services, etc.), but some of these layers have more dedicated helpers like `moduleForComponent`. Its basic usage is quite straight-forward: you just need to provide the name of the subject with its type:

``` {.javascript .numberLines}
moduleFor('service:current-user');
```

You can also pass an optional description, e.g., "Unit | Service | current -user" and config options, which is the most interesting part here.

With config options, you can pass callbacks such as `beforeEach` and `afterEach`, but also options which influence how the tests are being run.

When writing an integration test, you will need to pass `integration: true` option. And when you are unit testing some piece which depends on other parts of the application, you will need to pass the array of dependencies with `needs` option, like `needs: ['service:current-user']`. Other helpers which extend the behavior of `TestModule` (`moduleFor`) such as `TestModuleForComponent ` (`moduleForComponent`) introduce some more specific options, e.g. `unit` flag to indicate that you want to write a component unit test.

You may be wondering why passing the exact subject name is important. Let's take a look at this example of a basic service test:

``` {.javascript .numberLines}
import { moduleFor, test } from 'ember-qunit';

moduleFor('service:current-user', 'Unit | Service | current user');

test('it exists', function(assert) {
  const service = this.subject();

  assert.ok(service);
});
```

Somehow the service we wanted to test was properly initialized using `subject` function. `moduleFor` requires this full name exactly for this purpose - to find a factory and instantiate the object under the test.

Another important thing which `TestModule` (`moduleFor`) handles is contextualization of the tests. Check the following example:

``` {.javascript .numberLines}
import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';

moduleFor('service:invoice-price-calculator', 'Unit | Service |
  invoice-price-calculator');

test('it calculates net price for the invoice', function(assert) {
  const calculator = this.subject();

  const service_1 = Ember.Object.create({
    netPrice: 100,
  });
  const service_2 = Ember.Object.create({
    netPrice: 200,
  });
  const service_3 = Ember.Object.create({
    netPrice: 300,
  });
  const services = [service_1, service_2, service_3];

  assert.equal(calculator.calculateNetPrice(services), 600);
});

test('it calculates gross price for the invoice', function(assert) {
  const calculator = this.subject();

  const service_1 = Ember.Object.create({
    netPrice: 100,
  });
  const service_2 = Ember.Object.create({
    netPrice: 200,
  });
  const service_3 = Ember.Object.create({
    netPrice: 300,
  });
  const services = [service_1, service_2, service_3];
  const tax = Ember.Object.create({
    percentage: 10,
  });
  consts taxes = [tax];

  assert.equal(calculator.calculateGrossPrice(services, taxes), 660);
});
```

In both tests, we had to set up the same services, which is maybe not that bad for two tests but would certainly be a problem for a huge amount of tests. The great thing about the setup is that there is a shared context (`this`) between tests and setup callbacks! So we can assign all the values to `this` inside `beforeEach`:

``` {.javascript .numberLines}
import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';

moduleFor('service:invoice-price-calculator', 'Unit | Service |
  invoice-price-calculator', {
  beforeEach() {
    const service_1 = Ember.Object.create({
      netPrice: 100,
    });
    const service_2 = Ember.Object.create({
      netPrice: 200,
    });
    const service_3 = Ember.Object.create({
      netPrice: 300,
    });
    this.services = [service_1, service_2, service_3];
  },
});

test('it calculates net price for the invoice', function(assert) {
  const calculator = this.subject();

  assert.equal(calculator.calculateNetPrice(this.services), 600);
});

test('it calculates gross price for the invoice', function(assert) {
  const calculator = this.subject();

  const tax = Ember.Object.create({
    percentage: 10,
  });
  consts taxes = [tax];

  assert.equal(calculator.calcualteGrossPrice(this.services, taxes), 660);
});
```

Looks much better and much more DRY!

* `TestModuleForComponent` (`moduleForComponent`) - a specialized version of `TestModule` (`moduleFor`) help intended for testing components. By default, it's supposed to test components via integration tests, but you can also write unit tests by providing `unit: true` flag or the list of dependencies via `needs: []` in callbacks. This helper also provides `render` method which lets you render and test the component. Here's an example of a component and its integration test (which uses `htmlbars-inline-precompile` described later in this chapter):

``` {.javascript .numberLines}
// app/components/display-ember-awesomeness-status.js
import Ember from 'ember';

set {
  get,
} = Ember;

export default Ember.Component.extend({
  shouldShowStatus: false,

  actions: {
    showStatus() {
      set(this, 'shouldShowStatus', true);
    },
  }
});
```

```{.html .numberLines}
<!-- app/templates/components/display-ember-awesomeness-status.hbs -->
{{#if shouldShowStatus}}
  <p data-test="status">Ember is Awesome!</p>
{{else}}
  <button data-test="show-status-btn">Show status</button>
{{/if}
```

``` {.javascript .numberLines}
// tests/integration/components/display-ember-awesomeness-status-test.js
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

const {
  set,
} = Ember;

moduleForComponent('display-ember-awesomeness-status', 'Integration | Component |
  display ember awesomeness status', {
  integration: true
});

test('it shows status after clicking the button', function(assert) {
  assert.expect(2)

  const {
    $,
  } = this;

  this.render(hbs`{{display-ember-awesomeness-status}}`);

  assert.notOk($('[data-test=status]').length, 'status should be hidden');

  $('[data-test=show-status-btn]').click();

  assert.ok($('[data-test=status]').length, 'status should be visible');
});
```

As this helper is supposed to be used only for components, you don't need to pass the type of the subject, just the name of the component is sufficient.

* `TestModuleForModel` (`moduleForModel`) - a specialized version of `TestModule` (`moduleFor`), which provides extra setup and methods making testing models easier. It registers Application Adapter, allows you to access `store` via `this.store()` and overrides subject instantiation - by default it uses `store` to create new instances of the model with `store.createRecord()` passing the test subject as a model name:

``` {.javascript .numberLines}
// tests/unit/models/user-test.js
import { moduleForModel, test } from 'ember-qunit';

moduleForModel('user', 'Unit | Model | user', {
  needs: []
});

test('it exists', function(assert) {
  const model = this.subject();
  const store = this.store();

  assert.ok(model, 'model should exist');
  assert.ok(store, 'store should exist');
});
```

* `hasEmberVersion` - a nifty little helper for checking if you the current Ember version is equal to the specified one or higher concerning major and minor version. If you are developing some addon and want to use a feature introduced in Ember 2.10 and provide a fallback for the older versions, you can do it in the following way:

``` {.javascript .numberLines}
import hasEmberVersion from 'ember-test-helpers/lib/ember-test-helpers/has-ember-version';

if (hasEmberVersion(2, 10)) {
  executeLogicUsingFeatureAvailableFromThatEmberVersion();
} else {
  executeFallback();
}
```

* `wait` - a helper making it possible to wait until all the asynchronous operations, such as timers or HTTP requests, have been executed and only then doing the assertions. It is particularly useful when you don't want to stub out the behavior, but just test the behavior in more real-world circumstances. You will most likely need to use this helper along with QUnit's `async()` helper.

Imagine a simple use case where you need to hide some button after clicking on it after a particular period. This is how we could approach testing it:

``` {.javascript .numberLines}
// tests/integrations/components/hide-button-test.js
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import wait from 'ember-test-helpers/wait';

moduleForComponent('hide-button', 'Integration | Component | hide button', {
  integration: true
});

test('button is hidden after clicking on it', function(assert) {
  assert.expect(2);

  const done = assert.async();

  const {
    $,
  } = this;

  this.render(hbs`{{hide-btn}}`);

  assert.ok($('[data-test=hide-btn]').length, 'button should be visible');

  $('[data-test=hide-btn]').click();

  wait().then(() => {
    assert.notOk($('[data-test=hide-btn]').length, 'button should not be visible');
    done();
  });
});
```

And here is the component:

```{.html .numberLines}
<!-- app/templates/components/hide-btn.hbs -->
{{#unless hideBtn}}
  <button data-test="hide-btn" {{action "hide"}}>
    Hide me!
  </button>
{{/unless}}
```

``` {.javascript .numberLines}
// app/components/hide-btn.js
import Ember from 'ember';

const {
  run,
  set,
} = Ember;

export default Ember.Component.extend({
  hideBtn: false,

  actions: {
    hide() {
      run.later(this, function() {
        set(this, 'hideBtn', true);
      }, 2000);
    }
  }
});
```

And that's it! We don't need to stub any behavior in out tests or use `Ember.run.later()` (please, never ever do it) in our tests to make sure all the events have been processed.

The only concern here would be that this test takes more than 2 seconds to run. But we could quite easily make it faster by making delay time configurable from the outside:

``` {.javascript .numberLines}
// tests/integrations/components/hide-button-test.js
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import wait from 'ember-test-helpers/wait';

moduleForComponent('hide-button', 'Integration | Component | hide button', {
  integration: true
});

test('button is hidden after clicking on it', function(assert) {
  assert.expect(2);

  const done = assert.async();

  const {
    $,
  } = this;

  // let's change the delay time!
  this.render(hbs`{{hide-btn delayTime=0}}`);

  assert.ok($('[data-test=hide-btn]').length, 'button should be visible');

  $('[data-test=hide-btn]').click();

  wait().then(() => {
    assert.notOk($('[data-test=hide-btn]').length, 'button should not be visible');
    done();
  });
});
```

``` {.javascript .numberLines}
// app/components/hide-btn.js
import Ember from 'ember';

const {
  run,
  set,
  get,
} = Ember;

export default Ember.Component.extend({
  hideBtn: false,
  delayTime: 2000,

  actions: {
    hide() {
      const delayTime = get(this, 'delayTime');
      run.later(this, function() {
        set(this, 'hideBtn', true);
      }, delayTime);
    }
  }
});
```

By default `delayTime` is `2000` which is the same as it was, but this time this property is configurable, and we can just pass `0` to make the test much faster. As a nice side effect, we achieved a slightly better design in the component by extracting this delay time to a named property.

## testem

[Testem](https://github.com/testem/testem) is a test runner used under the hood when running `ember test` and `ember test --server`. However, there's quite a big difference between those two.

The former runs the tests in CI mode which just runs entire test suite and shows how many tests were run, how many passed, how many were skipped and how many failed. As the name suggests, it's supposed to be used for CI. For everyday development, you should use the latter, which will run a particular subset of tests when the file changes which is very convenient for rapid TDD.

![Testem](http://download.karolgalanciak.com/test-driven-ember/testem.png)

Here's an example config for Testem taken from `testem.json` config file in Ember app:


```{.json .numberLines}
<!-- testem.json -->

{
  "framework": "qunit",
  "test_page": "tests/index.html?hidepassed",
  "disable_watching": true,
  "launch_in_ci": [
    "PhantomJS"
  ],
  "launch_in_dev": [
    "PhantomJS",
    "Chrome"
  ]
}
```

The list of options is quite self-explanatory:

* framework - pass the name of test framework you are using. It could be `qunit`, `jasmine`, `mocha` and `buster`.

* test_page - a path to a customized test page to run tests.

* disable_watching - whether the file watching should be disabled or not. `ember-cli` already handles it, so no need to have it enabled.

* lanuch_in_ci - a list of launchers (such as PhantomJS, Chrome, Firefox) to be used when running tests in CI mode.

* launch_in_dev - a list of launchers to be used when running tests in development mode.

There are plenty of other config options that could be used if necessary;  you can learn more about them [here](https://github.com/testem/testem/blob/master/docs/config_file.md).

## ember-cli-htmlbars-inline-precompile

An awesome addon which makes it possible to precompile HTMLBars template strings making components testing much easier. That way we can write fewer acceptance tests covering different scenarios of the same feature in favor of components' integration tests, which results ultimately in faster tests.

Its API is pretty limited - you just pass a component's code as if you were rendering it in a real-world handlebar templates:

``` {.javascript .numberLines}
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

const {
  set,
} = Ember;

moduleForComponent('my-awesome-component', 'Integration | Component | my awesome
  component', {
  integration: true
});

test('button is hidden after clicking on it', function(assert) {
  assert.expect(1);

  const {
    $,
  } = this;

  const onUpdateAction = () => {
    assert.ok(true, 'onUpdate has been executed');
  };
  const user = Ember.Object.create();

  set(this, 'onUpdateAction', onUpdateAction);
  set(this, 'user', user);

  this.render(hbs`{{my-awesome-component user=user onUpdate=(action onUpdateAction)}}`);

  $('[data-test=update-btn]').click();
});
```

As you can see it is quite easy to pass bith the properties to the component and the actions! We just need to define them in the current context under the same name that we pass when rendering the component.


## pretender / ember-cli-pretender

[Pretender](https://github.com/pretenderjs/pretender) is a mock server library which makes it pretty straight-forward to define how mocked endpoints should behave, what kind of payload they should return and verify that the requests were performed to the given endpoints.

The API is limited but powerful - you just need to create a new instance of `Pretender` and mock the endpoints in the callback argument. You can define how the endpoints should behave using `get`, `post`, `put`, `patch`, `delete` and `head` methods.

Each of those methods takes three arguments: a path pattern, a callback handling the logic for given endpoint and an optional timing parameter. By default, all requests are asynchronous, but you can force a synchronous behavior, a response after the specified amount of time or making the endpoint not responding automatically at all which requires a manual resolving.

Each endpoint must return an array of 3 elements: HTTP status code, headers, and body.

Here's an example how you could use it:

``` {.javascript .numberLines}

const booking_1 = {
  {
    type: 'bookings',
    id: '1',
    attributes: {
      'start-at': '2017-01-01T12:00:00Z',
      'end-at': '2017-01-10T08:00:00Z',
    }
  }
};

const booking_2 = {
  {
    type: 'bookings',
    id: '2',
    attributes: {
      'start-at': '2017-02-01T12:00:00Z',
      'end-at': '2017-02-10T08:00:00Z',
    }
  }
};

const bookings = {
  data: [booking_1, bookings_2]
};

const server = new Pretender(function() {
  this.get('/api/bookings',(request) => {
    return [200, {'Content-Type': 'application/json'},
      JSON.stringify(bookings)];
  });

  this.get('/api/bookings/:id', (request) => {
    const idsBookingsMapping = {
      '1': booking_1,
      '2': booking_2,
    };
    const id = request.params.id;

    return [200, {"Content-Type": "application/json"}, JSON.stringify({
      data: idsBookingsMapping[id]
    })];
  }, 5000); // respond after 5 seconds
});
```

And what is this `request` argument passed to a handler callback? It's a `FakeRequest` object which offers a pretty convenient API giving you access to `params`, `queryParams`, `requestBody` or `requestParams` properties making it easy to do proper assertions and stub endpoints with some extra features like filtering which will be much closer to the behavior of a real backend server.

`Pretender` has also some other interesting features like `handledRequest(verb, path, request)` hook which makes it easy to do some assertions about specific endpoints being called or `prepareHeaders(headers)` and `prepareBody(body)` hooks for some extra transformations of headers and body for each request. For a full reference to all features check the [docs](https://github.com/pretenderjs/pretender).

What about `ember-cli-pretender`? It's just an extra layer for the integration of `pretender` with `ember-cli` apps; it doesn't introduce any new features.

`Pretender` is a handy tool, but adding all these handlers and preparing payloads for every endpoint can get quite cumbersome, especially when dealing with a more complex format such as JSONAPI. It would be good to have something that would make it much easier and DRY and add some factories on top to have a mocked backend DB. Fortunately, there's an exact solution for that, which is a wrapper for `pretender` plus tons of other excellent features that make dealing with HTTP requests pretty simple. Time to meet [ember-cli-mirage](http://www.ember-cli-mirage.com).

## ember-cli-mirage

### Overview

`ember-cli-mirage` is a powerful tool which provides both mock backend server and factories/fixtures, which makes not only a testing much easier but also the development of the application is much faster - we no longer need real backend server, as we can rely just on a mock backend server. And the remarkable thing is that `ember-cli-mirage` handler JSONAPI format out-of-box! Even if we need any extra customization, we can quickly adjust the specific endpoints to do something more. Let's take a look at some examples.

### Getting started

After installing the addon via `ember install ember-cli-mirage` we will see that `mirage` directory was added to the main directory of the app which consists of:

-  `config.js` file for defining route handlers,

- `scenarios` directory with `default.js` file which is supposed to be used for seeding mock database

- `serializers` directory with `application.js` serializer which by default handles JSONAPI format.

### ember-cli-mirage 101

Let's define some example routes to see ember-cli-mirage in action. As this layer is a wrapper for `pretender`, we may expect that it will work similarly. And that's indeed the case! We can define route handlers for given path pattern for `get`, `post`, `put`, `patch` and `del` methods. Here's a simple example how to define a handler returning all users:


``` {.javascript .numberLines}
// mirage/config.js
this.get('/api/users', () => {
  data: [
    {
      id: '1',
      type: 'users',
      attributes: {
        email: 'ember-cli-mirage@is-awesome.com'
      }
    }
  ]
});
```

It's still a bit simpler than defining handlers in `pretender`; nevertheless, it doesn't offer much of an improvement so far. Let's add some real models and play with `ember-cli-mirage` ORM and mock database and see how powerful it is!

### ember-cli-mirage models and route handlers

If we want to interact with a mock in-memory database, we need to define models first. For now, let's focus on the minimum thing that will work and start with generating `user` model. We can use a built-in generator for that:

```
ember g mirage-model user
```

It should generate `user.js` file under `mirage/models` directory with the following body:

``` {.javascript .numberLines}
// mirage/models/user.js
import { Model } from 'ember-cli-mirage';

export default Model;
```

And for now, this is enough to define virtual `users` "table" in the mock database.

Before `0.3.2` version of it was necessary to generate those separate models for `ember-cl-mirage`, but fortunately, we are now able to reuse just Ember Data model for this purpose by setting `discoverEmberDataModels` to true for the ENV:

``` {.javascript .numberLines}
ENV['ember-cli-mirage'] = {
  discoverEmberDataModels: true
};
```
Later in the book, we will use the exact config to avoid generating models manually.

Let's get back to the routes and define route handlers for all the CRUD actions.

Here's the simplest form of a route handler for getting all users:

``` {.javascript .numberLines}
// mirage/config.js
this.get('/api/users', (schema) => {
  return schema.users.all();
});
```

The first argument passed to the handler callback is `schema` which exposes models and database giving us all the tools we need to interact with a mock backend, available under `schema.db` attribute.

One of these model collections is `schema.users` which exposes various methods for manipulating and accessing the specified collection. `all()` method is one of those that return all records for given model, but there are also few more:

* `find(id_or_ids)` - finds record(s) with given id(s). Note that you can also pass the array of ids. You can use it either as `schema.users.find(10)` or `schema.users.find([10, 20, 30])`

* `where(conditions)` - return records matching provided conditions specified as key-value pairs, e.g. `schema.users.where({ isAdmin: true })`

* `first()` - returns first item from collection: `schema.users.first()`

* `new(attributes)` - creates an unpersisted (i.e. without `id`) record with specified attributes: `schema.users.new({ isAdmin: true, full_name: 'Rich Piana' })`

* `create()` - similar to `new()`, but creates a persisted record having `id`, e.g. `schema.users.create({ isAdmin: true, fullName: 'Rich Piana' })`

The important thing is that these methods don't return just some sets of attributes, but real object with a very useful API:

* `attrs()` - returns attributes of given model record:

``` {.javascript .numberLines}
const user = schema.users.find(1);
user.attrs()
  // => { id: 1, fullName: 'Rich Piana' }
```

* `save()` - persists records with applied changes to the attributes' values:

``` {.javascript .numberLines}
const user = schema.users.new({ name: 'Rich' })
user.id
  // => null, record is not persisted

user.save()
user.id
  // => 1, record got persisted

user.name = 'Lazar'
  // the attribute has been assigned, but the changes are
  // not persisted yet
user.save()
  // the changes to the attributes have been persisted
```

* `update(attribute, value)` - updates specified attributes for given records and
// persists changes to the database:

``` {.javascript .numberLines}
const user = schema.users.find(1);

user.update('name', 'Rich'})
  // `name` attribute has been updated and the update has been persisted to the database
```

* `destroy()` - removes given record from the database:

``` {.javascript .numberLines}
const user = schema.users.find(1);

user.destroy();
  // record has been removed from the database
```

* `isNew()` - returns `true` if record has not been persisted to the database:

``` {.javascript .numberLines}
const user = schema.users.new({ fullName: 'Lazar Angelov' });

user.isNew(); // true

user.save();
  // user has been persisted
user.isNew(); // false
```

* `isSaved()` - returns true if the record is persisted in the database:

``` {.javascript .numberLines}
const user = schema.users.new({ fullName: 'Lazar Angelov' });

user.isSaved(); // false

user.save();
  // user has been persisted
user.isSaved(); // true
```

What about the database itself, available under `schema.db` attribute?

In most cases you won't probably need to access it directly as accessing the model collection is going to be enough; nevertheless, it might be worth knowing the available API for manipulating it in case it is necessary.

* `collection` - it's not an attribute, but a particular model collection name, e.g. `users`, returning the array with the records of given type. The important thing to keep in mind is that it doesn't return real models, only the database representation of them:

``` {.javascript .numberLines}
schema.db.users[0];
  // { id: '1', fullName: 'Rich Piana' }, just the attributes
```

* `insert(attributes_or_array_with_attributes)` - inserts record or records or with given attributes to the database. It returs the newly inserted record or records with added `id`:

``` {.javascript .numberLines}
schema.db.users.insert({ fullName: 'Rich Piana' });
  // { fullName: "Rich Piana", id: '2' }

schema.db.users.insert([
  { fullName: 'Rich Piana' },
  { fullName: 'Lazar Angelov' }
);
  // [{ fullName: 'Rich Piana', id: '3' }, { fullName: 'Lazar Angelov', id: '4' }]
```

* `find(id_or_ids)` - returns record or record with given id / ids:

``` {.javascript .numberLines}
schema.db.users.find('3');
  // { fullName: 'Rich Piana', id: '3' }

schema.db.users.find(['3', '4']);
  // [{ fullName: 'Rich Piana', id: '3' },
  // { fullName: 'Lazar Angelov', id: '4' }]
```

* `where(conditions)` - returns records matching specified conditions provided as key-value pairs:

``` {.javascript .numberLines}
schema.db.users.where({ fullName: 'Rich Piana });
  // [{ fullName: 'Rich Piana, id: '3' }];
```

* `update(attributes)` - updates all records with given attributes:

``` {.javascript .numberLines}
schema.db.users.update({ isAdmin: true }); // all users are updated with `isAdmin`
  // value set to `true`
```

* `update(record, attributes)` - updates a record identified by either `id` or records matching specified conditions provided as key-value pairs and updates their attributes:

``` {.javascript .numberLines}
schema.db.users.update('3', { isAdmin: true });
  // a user with `id` '3'
  // updated with `isAdmin` value set to `true`
schema.db.users.update({ fullname: 'Lazar Angelov' }, { isAdmin: true });
  // all users with `fullname` 'Lazar Angelov' are updated with `isAdmin` value set to `true`
```

* `remove()` - removes all records from the database:

``` {.javascript .numberLines}
schema.db.users.remove(); // schema.db.users => []
```

* `remove(record)` - removes a record identified by either `id` or records matching specified conditions provided as key-value pairs:

``` {.javascript .numberLines}
schema.db.users.remove('3'); // removes record with id '3'
schema.db.users.remove({ fullname: 'Rich Piana' });
  // removes records with `fullname` 'Rich Piana'
```

* `firstOrCreate(conditions, attributesForCreate)` - finds a record matching specified conditions provided as key-value pairs or creates a new one using specified attributes for create:

``` {.javascript .numberLines}
schema.db.users.firstOrCreate({ fullName: 'Rich Piana' })
  // finds a record with `fullName` 'Rich Piana' or creates a new one
schema.db.users.firstOrCreate({ fullName: 'Rich Piana' }, { isAdmin: true})
  // finds a record with `fullName` 'Rich Piana' or creates
  // a new one assigning also `isAdmin` attribute with `true` value
```

Now that we know quite a lot about `schema` and we can define route handler for getting all records, we need to answer one important question: how does `ember-cli-mirage` handle serialization of the response? The format of the result returned by `schema.users.all()` is far from, e.g. JSONAPI standard which is the default choice in Ember Data. Under the hood `ember-cli-mirage` uses a serializer for given model (which can be defined in `mirage/serializers` directory. By default it's `JSONAPISerializer` as well, but you can also pick `RESTSerializer` and `ActiveModelSerializer`), so we don't need really need to think about the format that Ember Data models expect, the serializer layer will do it for us.

Let's try to define a handler for getting a model with given id:

``` {.javascript .numberLines}
// mirage/config.js
this.get('/api/users/:id', ({ users }, request) => {
  return users.find(request.params.id);
});
```

Just like we define a route handler for given path pattern in `pretender`, we do the same in `ember-cli-mirage`. Also, we had access to `request` param, and so we do in this case! `request` is a second argument in the callback available in every route handler we define. Thanks to ES 6 destructuring feature, we can add some syntactic sugar for getting a specified collection from `schema`. Then, we are simply using `find()` method on collection passing an `id` from the `params`.

And how to implement an action for creating new records? There is `create` method available on collection and that's exactly what we need here:

``` {.javascript .numberLines}
// mirage/config.js
this.post('/api/users', ({ users }, request) => {
  const attributes = JSON.parse(request.requestBody);

  users.create(attributes);
});
```

It's pretty straightforward - we just take `requestBody` from `request`, parse it and create a new record. However, this is not an elegant solution, and there is a potential problem - `ember-cli-mirage` expects a normalized format of the data to be used in `create` method! If your Ember Data models are using JSONAPI format, the payload will be far from the expected format. Fortunately, there is `normalizedRequestAttrs()` helper method implemented for exactly this purpose:


``` {.javascript .numberLines}
// mirage/config.js
this.post('/api/users', function({ users }, request) {
  consts attributes = this.normalizedRequestAttrs();

  return users.create(attrs);
});
```

This method takes care of the normalization process, which is based on the model's serializer, so we don't need to give it much thought.

Note that we need a proper context inside the callback function (`this.normalizedRequestAttrs()`), so we cannot use arrow functions in such case.

Updating models is quite similar, we just need to find given model by `id` and call `update` method passing normalized attributes:

``` {.javascript .numberLines}
this.put('/api/users/:id', function({ users }, request) {
  const id = request.params.id;
  consts attributes = this.normalizedRequestAttrs();

  return users.find(id).update(attributes);
});
```

And for deleting models we just need to call `destroy()` on a model:

``` {.javascript .numberLines}
this.del('/api/users/:id', ({ users }, request) => {
  consts id = request.params.id;

  users.find(id).destroy();
});
```

That way we defined all the CRUD actions for `users` resource. But defining all these handlers is quite repetitive, and most handlers will look the same for other resources. Is it possible to DRY it up a bit? The answer is yes! And it's quite easy.

### ember-cli-mirage: shorthands and `resource` helper

Defining a `shorthand` in `ember-cli-mirage`  simply means adding a route action without a callback, which is optional. If not provided, the default handler will be used, which looks exactly the same as the callbacks we previously defined. That way entire CRUD for some resource could be defined the following:

``` {.javascript .numberLines}
// mirage/config.js
this.get('/api/users')
this.get('/api/users/:id')
this.post('/api/users')
this.patch('/api/users/:id')
this.delete('/api/users/:id')
```

If we don't want to prefix every path pattern with `api`, we can provide a `namespace` to make it even shorter:

``` {.javascript .numberLines}
// mirage/config.js
this.namespace = '/api';

this.get('/users')
this.get('/users/:id')
this.post('/users')
this.patch('/users/:id')
this.delete('/users/:id')
```

But that's not everything; we can DRY it up even more! Rails-like `resource` helper is available for exactly this purpose which allows defining CRUD actions for given resource:


``` {.javascript .numberLines}
// mirage/config.js
this.namespace = '/api';

this.resource('users');
```

We can also whitelist or blacklist actions using `only` and `except` options:

``` {.javascript .numberLines}
// mirage/config.js
this.namespace = '/api';

this.resource('users', { only: ['index', 'show', 'create'] });
```

``` {.javascript .numberLines}
// mirage/config.js
this.namespace = '/api';

this.resource('users', { except: ['update', 'delete'] });
```

This is the exact mapping between actions and route handlers:

```
| action       | route handler          |
|--------------|------------------------|
|  index       | this.get('/users');    |
|---------------------------------------|
|  show        | this.get('/users/:id');|
|---------------------------------------|
|  create      | this.post('/users');   |
|---------------------------------------|
|  update      | this.patch('/users');  |
|              | this.put('/users');    |
|---------------------------------------|
|  delete      | this.del('/users/:id');|
```

### ember-cli-mirage: models and associations

Associations are a big part of modeling the domain layer. As you may expect, `ember-cli-mirage` has a great API for defining those as well. For this purpose there are two helpers: `belongsTo` and `hasMany`. Let's see them in action:

``` {.javascript .numberLines}
// mirage/models/user.js
import { Model, belongsTo } from 'ember-cli-mirage';

export default Model.extend({
  organization: belongsTo(),
  articles: hasMany(),
});
```

We've just defined a to-one relationship between Users and Organizations and to-many between Users and Articles. If you follow the conventions of the naming, you won't need to provide the literal model name for a given relationship as it will be inferred from the attribute name. However, if the model name differs from attribute name, you will need to provide the proper name as the first argument:

``` {.javascript .numberLines}
// mirage/models/user.js
import { Model, belongsTo } from 'ember-cli-mirage';

export default Model.extend({
  organization: belongsTo('company'),
  articles: hasMany(),
});
```

By declaring those relationships, we gain some dynamically defined methods for manipulating them. We get readers/writers for id/ids and methods for building the associated models.

This is how we could manipulate `organization` relationship:

``` {.javascript .numberLines}
const user = schema.users.find(1);

user.organizationId; // 2
user.organization; // returns organization with id equal to 2
user.organizationId; // 1;
user.organization;
  // returns organization with id equal to 1
user.newOrganization({ name: '5% Nutrition' });
  // builds in-memory organization instance associated to the user
user.createOrganization({ name: '5% Nutrition' });
  // creates persisted organization instance associated to the user
```

And here are the set of methods for manipulating articles:

``` {.javascript .numberLines}
const user = schema.users.find(1);

user.articleIds; // [10, 12, 100]
user.articleIds = [2, 3];
  // replaces current articles with the new set
user.articles;
  // returns array of associated articles
user.articles = [article1, article2];
  // replaces current articles with the new set
user.newArticle({ name: 'Pumping biceps to the max' });
  // builds in-memory article instance associated to the user
user.createArticle(({ name: 'Pumping biceps to the max' }));
  // creates persisted article instance associated to the user
```

Keep in mind that there is no need to define those relationships if the Ember Data models discovery feature is enabled.


### ember-cli-mirage: factories

#### Attributes

Route handlers and mock database aren't the only things that `ember-cli-mirage` is responsible for. Another layer that makes our life as developers much easier are **factories**.

Factories are blueprints for model records with  certain set of attributes and relationships which are used for seeding the database. You can either generate factory files by built-in generator:

```
ember g mirage-factory user
```

or create them manually inside `mirage/factories` directory.

Let's define a basic factory for creating users:


``` {.javascript .numberLines}
// mirage/factories/user.js
import { Factory } from 'ember-cli-mirage';

export default Factory.extend({
  fullName: 'Rich Piana',
  companyName: '5% Nutrition',
});
```

To define a new factory we need to extend `Factory` and provide the set of attributes. We are not limited to only static attributes like in the example above, but we can also provide dynamic ones taking a sequence number as an argument:


``` {.javascript .numberLines}
// mirage/factories/user.js
import { Factory } from 'ember-cli-mirage';

export default Factory.extend({
  fullName: 'Rich Piana',
  companyName: '5% Nutrition',
  birthDate() {
    return new Date();
  },
  email(i) {
    return `${this.fullName}_${i}@example.com`;
  },
});
```

Note that inside the definition of a dynamic attribute we have access to the current context (`this`) so we can reference other attributes.

We often need to use some random data, but with more meaningful values, especially if we want to reuse such data outside of tests. Fortunately, we can take advantage of `faker` which is included in `ember-cli-mirage` for exactly this purpose:

``` {.javascript .numberLines}
// mirage/factories/user.js
import { Factory, faker } from 'ember-cli-mirage';

export default Factory.extend({
  firstName() {
    return faker.name.firstName();
  },
  lastName() {
    return faker.name.lastName();
  },
  companyName: '5% Nutrition',
  birthDate() {
    return new Date();
  },
  email(i) {
    return `email_${i}@example.com`;
  },
});
```

You can learn more about `faker` form the [docs](https://github.com/marak/Faker.js/).

#### Building And Creating Records From Factories

To instantiate persisted or non-persisted records we can use `create()`/`createList()` for creating one record or multiple records or `build()`/`buildList()` for building one or multiple records. All these methods are available on the `server` object, which is a global injected to every acceptance test, but you can also make it available in unit or integration tests using `startMirage()` initializer:

``` {.javascript .numberLines}
// tests/integration/awesome-integration-test-with-mirage.js
import { startMirage } from 'my-app/initializers/ember-cli-mirage';

moduleForComponent('awesome-integration-test-with-mirage', 'Integration | Component |
  awesome integration test with mirage', {
  integration: true,
  beforeEach() {
    this.server = startMirage();
  },
  afterEach() {
    this.server.shutdown();
  }
});
```

Let's reuse previous factory for `users`:

``` {.javascript .numberLines}
// mirage/factories/user.js
import { Factory, faker } from 'ember-cli-mirage';

export default Factory.extend({
  firstName() {
    return faker.name.firstName();
  },
  lastName() {
    return faker.name.lastName();
  },
  companyName: '5% Nutrition',
  birthDate() {
    return new Date();
  },
  email(i) {
    return `email_${i}@example.com`;
  },
});
```

By calling `server.create('user')` we would create a persisted `user` record. We could also provide the attributes' overrides if we want to set some custom value instead of relying on attributes defined in the factory:

```
server.create('user', { firstName: 'Rich' });
```

`createList()` method is very similar, we just need to provide the `count` argument for indicating the amount of records we want to create:

```
server.createList('user');
server.createList('user', { firstName: 'Rich' });
```

Both `build` and `buildList` methods work the same as their `create` equivalents, they just create unpersisted records instead.

#### Setting relationships: `association` helper & `afterCreate` callback

For setting to-one relationships we can use either **association** helper or **afterCreate** callback. **association** sounds much more suitable, and it's easier to use, so let's see it in action. We could reuse the previous example with `users` belonging to some `organization`:

``` {.javascript .numberLines}
// mirage/models/user.js
import { Model, belongsTo } from 'ember-cli-mirage';

export default Model.extend({
  organization: belongsTo(),
});
```

And here's our factory:

``` {.javascript .numberLines}
// mirage/factories/user.js
import { Factory, association } from 'ember-cli-mirage';

export default Factory.extend({
  firstName() {
    return faker.name.firstName();
  },
  lastName() {
    return faker.name.lastName();
  },
  organization: association(),
});
```

Super simple! What if the model name would not follow convention and we called it, e.g., `company`?

``` {.javascript .numberLines}
// mirage/models/user.js
import { Model, belongsTo } from 'ember-cli-mirage';

export default Model.extend({
  organization: belongsTo('company'),
});
```

It would be still the same - `association` helper is "smart" enough to infer the proper model name from the associations defined in the model.

If you don't like this approach you could also use more generic tool - `afterCreate` callback which takes two arguments: a record which is being created and the `server` instance:

``` {.javascript .numberLines}
// mirage/factories/user.js
import { Factory } from 'ember-cli-mirage';

export default Factory.extend({
  firstName() {
    return faker.name.firstName();
  },
  lastName() {
    return faker.name.lastName();
  },

  afterCreate(user, server) {
    server.create('organization', { user });
  }
});
```

For setting up to-many relationships we can use `afterCreate` callback as well:

``` {.javascript .numberLines}
// mirage/models/user.js
import { Model, belongsTo } from 'ember-cli-mirage';

export default Model.extend({
  organization: belongsTo('company'),
  articles: hasMany(),
});
```

``` {.javascript .numberLines}
// mirage/factories/user.js
import { Factory } from 'ember-cli-mirage';

export default Factory.extend({
  firstName() {
    return faker.name.firstName();
  },
  lastName() {
    return faker.name.lastName();
  },

  afterCreate(user, server) {
    server.create('organization', { user });
    server.createList('article', 5, { user });
  }
});
```

#### Traits

It quite often happens that there are multiple contexts of some model, e.g., a user can be an admin user or not admin-user, or an article can be either published or not published (i.e., a draft). Instead of duplicating such setup logic in the multiple tests, we can use **traits** which are supposed to solve exactly this problem. Let's assume that we need to create admin and non-admin users, users that belong to some organization or do not and also the user having some articles. Here is how to do that using traits:

``` {.javascript .numberLines}
// mirage/factories/user.js
import { Factory, trait, association } from 'ember-cli-mirage';

export default Factory.extend({
  firstName() {
    return faker.name.firstName();
  },
  lastName() {
    return faker.name.lastName();
  },

  adminUser: trait({
  	isAdmin: true,
  }),

  withOrganization: trait({
    organization: association(),
  }),

  withComments: trait({
    afterCreate(user, server) {
      server.createList('article', 5, { user });
    }),
  },
});
```

Notice that we can use both `afterCreate` callback and `association` helper inside traits.

To create records with given traits, we just need to pass them as arguments to `create()`/`createList()` and `build()`/`buildList()` methods:

``` {.javascript .numberLines}
server.create('user', 'adminUser');
server.createList('user', 5, 'adminUser', 'withOrganization');
server.build('user', 'withOrganization', `withComments`);
server.buildList('user', 10, 'withOrganization', `withComments`,
  { firstName: 'Rich' });
```

A great thing (shown in the last example) is that we can also pass the attributes' overrides as the last argument which will take precedence over the attributes from the traits.

### ember-cli-mirage: serializers

Serializers layer is responsible for normalizing incoming data (POST and PUT) and serializing data to a right format. There are three types of serializers available in `ember-cli-mirage` out of the box:

* JSONAPISerializer (a default one)

* ActiveModelSerializer

* RestSerializer

It's not the layer that you do a lot of customization, nevertheless, knowing the available API may be extremely valuable when you need to do something extra. You can either customize the global serializer (the one from `mirage/serializers/application.js`) or provide a model-specific serializer. Here's the list of the methods that you will most likely want to customize:

* `serialize(object, request)` - override this method if you need to return different data in the route handlers than the default one. Particularly useful when you want to add, e.g., some meta data to the response:

``` {.javascript .numberLines}
// mirage/serializers/user.js
import BaseSerializer from './application';

export defauls: BaseSerializer.extend({
  serialize(object, request) {
    const originalResponse = BaseSerializer.prototype.serialize.apply(this,
      arguments);

    originalResponse.meta = {
      timestamp: new Date().toString(),
    }
    return originalResponse;
  },
});
```

* `normalize(json)` - customize the payload coming from POST and PUT shorthands. Keep in mind that the format must be JSONAPI-compliant.

* `attrs` - you can use this method to whitelist attributes that should be returned in a serialized response:

``` {.javascript .numberLines}
// mirage/serializers/user.js
import BaseSerializer from './application';

export default BaseSerializer.extend({
  attrs: ['id', 'firstName', 'lastName']
});
```

* `include` - if you need to return sideloaded associations, that's the method you should use. You can provide an array of associations or a function:

``` {.javascript .numberLines}
// mirage/models/user.js
import { Model, hasMany } from 'ember-cli-mirage';

export default Model.extend({
  articles: hasMany(),
});
```

``` {.javascript .numberLines}
// mirage/serializers/user.js
import BaseSerializer from './application';

export default BaseSerializer.extend({
  include: ['articles'],
});
```

or

``` {.javascript .numberLines}
// mirage/serializers/user.js
import BaseSerializer from './application';

export default BaseSerializer.extend({
  include: function(request) {
    const queryParams = request.queryParams
    if (queryParams && queryParms.include && queryParams.indexOf('articles')) {
      return ['articles']
    } else {
      return [];
    }
  },
});
```

As the second use case is a pretty standard feature, it works out of the box for JSONAPI serializer: just specify the relationships that should be included using `include` query param, and you won't need to customize any serializer.

Check the [official docs](http://www.ember-cli-mirage.com/docs/v0.2.x/serializers/) if you want to learn more.

### ember-cli-mirage: seeding database

When it comes to testing it's pretty straightforward - we have `server` object available in acceptance tests or we can [manually instantiate it](http://www.ember-cli-mirage.com/docs/v0.2.x/manually-starting-mirage/) when needed. How about using factories for seeding database for development?

In that case, we need to take advantage of `mirage/scenarios/default.js` file and define the entire setup there inside one function accepting `server` argument:

``` {.javascript .numberLines}
// mirage/scenarios/default.js
export default function(server) {
  server.createList('user', 10, 'admin');
  server.createList('user', 10, 'nonAdmin', 'withArticle');
}
```

No need to depend on the data coming from a backend app when doing the development. Just create the right setup for the data and focus on the important parts.

## ember-test-selectors

A fundamental issue when writing acceptance or integration tests is deciding how you should identify elements when accessing them from the test. Should you use some special classes? Or maybe use some particular `data` attributes?

These solutions will surely work, but there are some problems with them. They add some extra stuff to DOM which is not needed besides tests, using special classes might be misleading, and you can't easily pass `data` attributes to components (e.g. `data-test='user-form'`) just like classes as it requires adding some additional attribute bindings in the component. Keeping the conventions consistent between the projects also gets more challenging.

Fortunately, there is a great solution to this problem: [ember-test-selectors addon](https://github.com/simplabs/ember-test-selectors)

Thanks to this addon, we can use `data-test-*` attributes in DOM elements, and they will be removed from the production builds! Another awesome feature is that you can pass them to the components and these attributes will be automatically bound. Rendering the following component:


``` {.javascript .numberLines}
{{article-comments comments=comments data-test-article-comments=article.id}}
```

will result in the following DOM:

``` {.html .numberLines}
<div id="ember100" data-test-article-comments="1000">
</div>
```

What is more, `ember-test-selectors` comes with a `testSelector` helper which can be used in both acceptance and component integration tests. If we wanted to find the `div` wrapping the component in the previous example, we could write the following acceptance test:

``` {.javascript .numberLines}
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import { test } from 'qunit';
import testSelector from 'ember-test-selectors';

moduleForAcceptance('Acceptance: Finding components');

test('it finds components', function(assert) {
  const element = find(testSelector('article-comments', 1000));

  assert.ok(element);
});
```

``` {.javascript .numberLines}
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import { test } from 'qunit';
import testSelector from 'ember-test-selectors';

moduleForAcceptance('Acceptance: Finding components');

test('it finds components', function(assert) {
  const element = find(testSelector('article-comments', 1000));

  assert.ok(element);
});
```

and in a component integration tests:

``` {.javascript .numberLines}
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import testSelector from 'ember-test-selectors';

moduleForComponent('my-awesome-component', 'Integration | Component |
  my awesome component', {
  integration: true
});

test('it finds components', function(assert) {
  const element = this.$(testSelector('article-comments', 1000));

  assert.ok(element);
});
```

## ember-cli-page-object

In large test suites, it's quite easy to find a lot of repetitions with filling the same forms for testing different scenarios, querying the same elements and making similar assertions. Not only is it not that DRY, but it adds some unnecessary noise to the tests - instead of focusing on the testing scenario you see a bunch of query selectors which are pretty meaningless. Encapsulating querying logic, filling forms, visiting pages and assertions in a separate object that is easily reusable sounds like a good idea. And guess what! There is already a solution for this problem: [ember-cli-page-object](http://ember-cli-page-object.js.org).

Imagine you are testing a user signup scenario. In such case we would probably want to visit some **signup** page, provide an email, a password, a password confirmation, click a button and then we should see some notification that a user has successfully signed up. An acceptance test for this use case could look like this:

``` {.javascript .numberLines}
// tests/acceptance/user-signup-test.js
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import { test } from 'qunit';
import testSelector from 'ember-test-selectors';

moduleForAcceptance('Acceptance: User SignUp');

test('user can sign up with valid data', function(assert) {
  assert.expect(1);

  visit('/signup');
  fillIn('[data-test-user-email]', 'email@example.com');
  fillIn('[data-test-user-password]', 'supersecretpassword123');
  fillIn('[data-test-user-password-confirmation]', 'supersecretpassword123');
  click('[data-test-sign-up]');

  andThen(() => {
  	 const $notification = find(testSelector('success-notification'));
  	 assert.equal(
  	 	$notification.text().trim(),
  	 	'You have successufully signed up!',
  	 	'success notification should be displayed'
  	 );
  });
});
```

It doesn't look bad so far. What if we wanted to test another scenario, e.g., that some error notification is displayed when a user provides invalid data? We would have a very similar test with a lot of duplication like how to access given input. It would be much better to have it encapsulated in one place. Let's create our first page object.

We can use a generator provided by the addon for creating new page objects:

```
ember generate page-object singup
```

We should see a new file in `tests/pages` directory. Let's provide an interface for testing signup scenario:

``` {.javascript .numberLines}
// tests/pages/signup.js
import PageObject, {
  clickable,
  fillable,
  text,
  visitable
} from 'my-awesome-app/tests/page-object';

export default PageObject.create({
  visit: visitable('/signup'),

  email: fillable('[data-test-user-email]'),
  password: fillable('[data-test-user-password]'),
  passwordConfirmation: fillable('[data-test-user-password-confirmation]'),
  signUp: clickable('[data-test-sign-up]'),
  successNotification: text('[data-test-success-notification]'),
});
```

There is quite a lot of things going on, so let's break them down. To create a page object, we call, well, `create` method on `PageObject` and specify the steps for a given scenario. We are using some interesting helpers here, so let's break them down:

* `visitable` - a helper for visiting a page under given path.

* `fillable` - fills an input identified by a provided selector.

* `clickable` - clicks element identified by a given selector.

* `text` - finds an element with given selector and extracts the text from it. By default it will normalize the returned text so that we don't need to call `trim()` on it, but if that's not the desired behaviour, we can provide `normalize` option and set it to `false`:  `text('[data-test-success-notification]', { normalize: false })`

Most of these helpers accept extra `options` argument where you can provide such options as `scope` (a parent element in which the given element is nested) and some more. You can learn more about them from the [official docs](http://ember-cli-page-object.js.org/).

And this is how we can refactor our previous test with a page object:

``` {.javascript .numberLines}
// tests/acceptance/user-signup-test.js
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import { test } from 'qunit';
import page from 'my-awesome-app/tests/pages/singup';

moduleForAcceptance('Acceptance: User SignUp');

test('user can sign up with valid data', function(assert) {
  assert.expect(1);

  page
  	.visit()
  	.email('email@example.com')
  	.password('supersecretpassword123')
  	.passwordConfirmation('supersecretpassword123')
  	.signUp();

  andThen(() => {
  	 assert.equal(
       page.successNotification,
  	 	'You have successufully signed up!',
  	 	'success notification should be displayed'
  	 );
  });
});
```

Looks much better! What if we wanted to add a scenario where the sign up fails because the password confirmation doesn't match the password? We just need to add a step for extracting text for some `errorNotification` and we can reuse the same flow:

``` {.javascript .numberLines}
// tests/pages/signup.js
import PageObject, {
  clickable,
  fillable,
  text,
  visitable
} from 'my-awesome-app/tests/page-object';

export default PageObject.create({
  visit: visitable('/signup'),

  email: fillable('[data-test-user-email]'),
  password: fillable('[data-test-user-password]'),
  passwordConfirmation: fillable('[data-test-user-password-confirmation]'),
  signUp: clickable('[data-test-sign-up]'),
  successNotification: text('[data-test-success-notification]'),
  errorNotification: text('[data-test-error-notification]'),
});
```

And here's another test scenario:

``` {.javascript .numberLines}
// tests/acceptance/user-signup-test.js
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import { test } from 'qunit';
import page from 'my-awesome-app/tests/pages/singup';

moduleForAcceptance('Acceptance: User SignUp');

test('user can sign up with valid data', function(assert) {
  assert.expect(1);

  page
  	.visit()
  	.email('email@example.com')
  	.password('supersecretpassword123')
  	.passwordConfirmation('supersecretpassword')
  	.signUp();

  andThen(() => {
  	 assert.equal(
       page.errorNotification,
  	 	'Password and password confirmation do not match',
  	 	'error notification should be displayed'
  	 );
  });
});
```

And that's it! Very elegant and DRY.

You can even use page objects in components' integration tests with some extra setup and write much more complex scenarios using plenty of available helpers/ I would highly recommend checking the [docs](http://ember-cli-page-object.js.org), just to get the idea what kind of helpers are available.

\pagebreak
