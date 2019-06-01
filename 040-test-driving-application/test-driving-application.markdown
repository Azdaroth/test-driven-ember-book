# Test-Driving Our Application

## Our Example Application - Book.me

Now that we already know the essential tools in **Ember** ecosystem and are fully aware of the value of writing tests and ideally sticking to TDD approach if possible, we can start developing our application.

The problem with many example applications is that there are either too simple to show more complex use cases that are common in real-world applications or they grow huge to the extent that many of the features don't bring much value regarding learning new concepts and only a small part of the application is valuable.

Nevertheless, it is still possible to provide an exciting feature(s) that will be complicated enough with a lot of interesting use cases but won't be too big for the book example.

For the last few years, I've been mostly involved in developing software for vacation rental industry, which makes it quite natural to provide the example within that domain. This industry comes with a lot of complex problems to solve and obviously, I won't attempt to provide any practical examples how to solve those issues as they might not necessarily contain that much concentrated educational value, but rather focus on some CRUD with cool additions.

As the vacation rental industry revolves mostly around reservations for, well, rentals generally speaking (villas, hotels, apartments, etc.), the primary concern of our example application, let's call it "Book.me", will be rentals and bookings management. Imagine you are the owner of multiple properties (rentals). To manage those properly a robust software is surely needed as we expect a lot of reservations and inquiries coming from everywhere. In a real-world scenario creating of the majority of the bookings would be automated by integration with applications like Booking.com, Airbnb or HomeAway, but this is certainly beyond the scope of this book, so let's focus on this particular one use case of creating the reservations manually.

Besides rentals management (simple CRUD), we will need to implement a nice calendar view where we will be able to select some dates and create a booking for given rental. Except for dates, we also need to specify a traveler for the booking, most likely identified by an email and/or a full name. To keep it simple, we will just ask for an email.

In the real-world scenario, we could expect some extra fees that would be added to the reservation like a cleaning fee, airport transfer, breakfast, etc., but adding this extra domain complexity would have little educational value compared to just creating the booking itself, so we can skip that part.

## Starting The Development - Generating New App

Now that we know what we are going to develop, let's move to the most interesting part: the application itself.

Surprise, surprise, we will start with generating the new app:

```
ember new book-me
```

To have a more aesthetically pleasing experience when developing our application, let's add some HTML/CSS framework - [`bootstrap-bookingsync-sass`](https://github.com/BookingSync/bootstrap-bookingsync-sass), which is based on Bootstrap, is used extensively inside [BookingSync](http://bookingsync.com) universe and looks very nice. We can simply install it as an addon:

```
ember install ember-cli-bootstrap-bookingsync-sass
```

You will be asked for overwriting `app/styles/app.scss` and `app/templates/application.hbs`, just accept the changes, we will modify them a bit later anyway.

The last step is editing `config/environment.js` file and adjusting `contentSecurityPolicy` for handling Google Fonts used by the addon:

```{.javascript .numberLines}
// config/environment.js
ENV.contentSecurityPolicy = {
  'default-src': "'none'",
  'script-src': "'self' 'unsafe-inline'",
  'style-src': "'self' 'unsafe-inline' https://fonts.googleapis.com",
  'font-src': "'self' fonts.gstatic.com",
  'connect-src': "'self'",
  'img-src': "'self' data:",
  'media-src': "'self'"
}
```

And that's enough for having some a pleasing design in the app. Now we can just start the server:

```
ember s
```

And you should see something like this:

![Initial layout](http://download.karolgalanciak.com/test-driven-ember/book_me_01.png)

\pagebreak

## Adding The First Feature - Sign Up And Sign In

Signing up and signing in are not the most exciting features out there as they get pretty repetitive in every app and don't deal much with the core domain of the application. Nevertheless, it's certainly useful to have one and do it from the very beginning - we need to scope models by account (we don't want our calendar to be public, right?), so it is a good idea to start exactly with this feature. Another benefit is that we can get quickly warmed up by something moderately easy.

There is no excuse for this feature to not practice TDD, so let's start with a test.

As we will need some extra selectors that are meaningful in the acceptance tests, we need to add [ember-test-selectors](https://github.com/simplabs/ember-test-selectors) to our application:

```
ember install ember-test-selectors
```

We will also need [ember-cli-mirage](http://www.ember-cli-mirage.com), so let' install it now:

```
ember install ember-cli-mirage
```

Now we can generate a new acceptance test:

```
ember g acceptance-test sign-in-sign-up
```

Let's open `book-me/tests/acceptance/sign-in-sign-up-test.js` and write our first test now!

Our first feature will be signing up and ensuring that we are logged in afterward. No need for any extra things like confirmations etc., we want to keep it simple here.

```{.javascript .numberLines}
// tests/acceptance/sign-in-sign-up-test.js
/* global server */
import { test } from 'qunit';
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import testSelector from 'ember-test-selectors';

moduleForAcceptance('Acceptance | sign in sign up');
test('user can successfully sign up', function(assert) {
  assert.expect(1);

  server.post('/users', function(schema)  {
    const attributes = this.normalizedRequestAttrs();
    const expectedAttributes = {
      email: 'example@email.com',
      password: 'password123',
      passwordConfirmation: 'password123',
    };

    assert.deepEqual(attributes, expectedAttributes, "attributes don't match
      the expected ones");

    return schema.users.create(attributes);
  });

  click(testSelector('signup-link'));

  andThen(() => {
    fillIn(testSelector('signup-email-field'), 'example@email.com');
    fillIn(testSelector('signup-password-field'), 'password123');
    fillIn(testSelector('signup-password-confirmation-field'), 'password123');

    click(testSelector('signup-submit-btn'));
  });
});
```

What we want to do here is filling email, password, password confirmation fields and click some signup button. After clicking that button, we expect to hit `users` endpoint and verify that the proper payload has been sent. We also fall back to a default behavior expected by such endpoint, which is creating a user with the given attributes.

Let's make this test green. We will start with a little customization in `templates/application.hbs`. Locate the navbar which currently should look like this:

```{.html .numberLines}
<!-- book-me/app/templates/application.hbs -->
<div class="collapse navbar-collapse navbar-top-collapse">
  <div class="navbar-right">
    <button class="btn btn-secondary navbar-btn" type="button">Button</button>
    <button class="btn btn-primary navbar-btn" type="button">Call to action</button>
  </div>
</div>
```

Remove all the buttons and replace them with the following link:

```{.html .numberLines}
<!-- book-me/app/templates/application.hbs -->
{{link-to "Sign up" "signup" class="btn btn-primary navbar-btn" data-test-signup-link}}
```

As an extra bonus we may change few more things in the layout. In the following section, remove `Welcome to Ember` header:

```{.html .numberLines}
<!-- book-me/app/templates/application.hbs -->
<section class="main-content">
  <div class="sheet">
    <h1>Welcome to Ember</h1>

    {{outlet}}
  </div>
</section>
```

and replace this part:

```{.html .numberLines}
<!-- book-me/app/templates/application.hbs -->
<div class="navbar-brand-container">
  <span class="navbar-brand">
    <h1><i class="fa fa-star"></i> Section Name</h1>
  </span>
</div>
```

with the following one:

```{.html .numberLines}
<!-- book-me/app/templates/application.hbs -->
<div class="navbar-brand-container">
  <span class="navbar-brand">
    <h1><i class="fa fa-star"></i> Book Me!</h1>
  </span>
</div>
```

Let's get back to making our test happy: `signup` route doesn't exist yet, so let's add it in the router:

```{.javascript .numberLines}
// book-me/app/router.js
import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('signup');
});

export default Router;
```

And let's generate the route:

```
ember g route signup
```

For handling the registration action, we are going to provide `registerUser` function. To make this action available in the template let's install [ember-route-action-helper](https://github.com/DockYard/ember-route-action-helper):

```
ember install ember-route-action-helper
```

Besides adding the action for registration, we also need to create a new `User` record in `beforeModel` hook.

Generating a new model sounds like a reasonable thing to do now:

```
ember g model User
```

We can now add two attributes that we will need for registration: `email` and `password` (we can forget for now about `passwordConfirmation`):

```{.javascript .numberLines}
// book-me/app/models/user.js
import DS from 'ember-data';

const {
  Model,
  attr,
} = DS;

export default Model.extend({
  email: attr('string'),
  password: attr('string'),
});
```

Before `0.3.2` version of `ember-cli-mirage` it was necessary to generate a separate set of models just for `ember-cl-mirage`, but fortunately, we are now able to reuse just Ember Data model for this purpose. We just need to enable models' discovery feature by adding the following line to the ENV file:

```{.javascript .numberLines}
// book-me/config/environment.js
ENV['ember-cli-mirage'] = {
  discoverEmberDataModels: true
};
```

Let's implement the logic for `signup` route and template:

```{.html .numberLines}
<!-- book-me/app/templates/signup.hbs -->
<form {{action (route-action "registerUser" user) on="submit"}}>
  <div class="form-group">
    <label for="signup-email">Email address</label>
    {{input
      data-test-signup-email-field
      id="signup-email"
      value=(mut user.email)
      class="form-control"
    }}
  </div>
  <div class="form-group">
    <label for="signup-password">Password</label>
    {{input
      data-test-signup-password-field
      id="signup-password"
      value=(mut user.password)
      class="form-control"
      type="password"
    }}
  </div>
  <div class="form-group">
    <label for="signup-password">Password Confirmation</label>
    {{input
      data-test-signup-password-confirmation-field
      id="signup-passwordConfirmation"
      value=(mut user.passwordConfirmation)
      class="form-control"
      type="password"
    }}
  </div>
  <button type="submit" class="btn btn-primary"
    data-test-signup-submit-btn>Submit</button>
</form>
```

```{.javascript .numberLines}
// book-me/app/routes/signup.js
import Ember from 'ember';

const {
  set,
} = Ember;

export default Ember.Route.extend({
  model() {
    return this.store.createRecord('user');
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'user', model);
  },

  actions: {
    registerUser(user) {
      user.save();
    },
  },
});
```

Nothing fancy going here - we just set up some necessary form fields and create a simple route with `registerUser ` action, which is executed when submitting the form.

Note that we haven't added any unit tests for the route. Why is that?

The main reason is that these methods don't need to be tested. `model` and `setupController` hooks may be considered as implementation details, and they are indirectly tested via the acceptance test. The decision whether the actions should be unit-tested or not is more complex though. In this case, the logic is so simple that it doesn't require any other tests, the passing acceptance test makes me confident enough about the code that it will work. The rule of thumb would be to not add any tests unless you see the benefits of them.

Our Mirage backend doesn't know so far how to handle POST requests for `users` endpoint, we can solve that problem with the following addition:

```{.javascript .numberLines}
// book-me/mirage/config.js
export default function() {
  this.post('/users');
};
```

In most cases the API URLs will be namespaced by `api` or similar a segment, to make it more real-world, we could do the same. Firstly, in the Mirage config file:

```{.javascript .numberLines}
// book-me/mirage/config.js
export default function() {
  this.namespace = 'api';

  this.post('/users');
};
```

And secondly, in the application adapter which needs to be generated in the first place:

```
ember g adapter application
```

```{.javascript .numberLines}
// book-me/app/adapters/application.js
import DS from 'ember-data';

export default DS.JSONAPIAdapter.extend({
  namespace: 'api',
});
```

Now our test is passing!

In the TDD cycle, besides writing tests and the actual implementation for satisfying the requirements specified in tests, there is one more phase: refactoring. At this point, I'm pretty happy with the overall design and the code, so this time we may skip this part.

How about the failure path? What happens if the passwords don't match or we don't fill any input at all and submit the form? It sounds like we need to add some validations.

Just like before, let's start with the test. At this level we don't need to test every possible failure scenario, just testing that some validation works will be good enough for acceptance tests. The details of the validation might be tested on unit-test level or integration-level later.

Here's our test:

```{.javascript .numberLines}
// tests/acceptance/sign-in-sign-up-test.js
test('user cannot signup if there is an error', function(assert) {
  assert.expect(1);

  server.post('/users', () => {
    assert.notOk(true, 'request should not be performed');
  });

  visit('/');

  click(testSelector('signup-link'));

  andThen(() => {
    fillIn(testSelector('signup-email-field'), 'example@email.com');
    fillIn(testSelector('signup-password-field'), 'password123');

    click(testSelector('signup-submit-btn'));
  });

  andThen(() => {
    assert.ok(find(testSelector('signup-errors')).length,
      'errors should be displayed');
  });
});
```

Quite similar to the previous test, but here we want to make sure that the error is displayed and that no request is performed to `/users` endpoint.

This failure case brings a new challenge: implementing validations. Where should be put it: in the model? In the controller? Or maybe we should generate a new component?

Arguably, the common approach would be adding some validations in a model, especially if you have some experience in Ruby on Rails. However, adding validations to models may create some serious issues if you have multiple contexts of the validations. And the idea of having "invalid object" sounds a bit uncomfortable to me, the params might not be valid in given context, but the model object itself shouldn't be the subject of validation. That's why I've been a fan of form objects for a long time.

In Ember apps, there are few ways to implement form objects. One way would be simply adding some computed properties in a  controller or a component which would act as a form object, validate the values and if everything went fine, it would just assign the values to the model. Another way would be using some model proxy - like [ember-changeset](https://github.com/DockYard/ember-changeset) or [ember-buffered-proxy](https://github.com/yapplabs/ember-buffered-proxy), so that we don't operate directly on models, but on something that stands in front of it. I usually choose [ember-changeset](https://github.com/DockYard/ember-changeset) and its close friend [ember-changeset-validations](https://github.com/DockYard/ember-changeset-validations), which provides validation layer for changesets.

Let's install these addons:

```
ember install ember-changeset
ember install ember-changeset-validations
```

But where are we going to use the changeset? It can be either a controller or a new component. In almost all the cases I choose to go with the components and keep controllers only for some particular use cases where the components are not enough, like query params. Components are easier to test, and they decouple concepts from the routes making them more reusable.

Let's generate a new `signup` component:

```
ember g component user-signup
```

Let's start by moving template content from `signup.hbs` to the component's template:

```{.html .numberLines}
<!-- book-me/app/templates/signup.hbs -->
{{user-signup user=user registerUser=(route-action "registerUser")}}
```

```{.html .numberLines}
<!--  book-me/app/templates/components/user-signup.hbs -->
<form {{action "registerUser" on="submit"}}>
  <div class="form-group">
    <label for="signup-email">Email address</label>
    {{input
      data-test-signup-email-field
      id="signup-email"
      value=(mut user.email)
      class="form-control"
    }}
  </div>
  <div class="form-group">
    <label for="signup-password">Password</label>
    {{input
      data-test-signup-password-field
      id="signup-password"
      value=(mut user.password)
      class="form-control"
      type="password"
    }}
  </div>
  <div class="form-group">
    <label for="signup-password">Password Confirmation</label>
    {{input
      data-test-signup-password-confirmation-field
      id="signup-passwordConfirmation"
      value=(mut user.passwordConfirmation)
      class="form-control"
      type="password"
    }}
  </div>
  <button type="submit" class="btn btn-primary"
    data-test-signup-submit-btn>Submit</button>
</form>
```

Notice that the way the `registerUser` action is invoked has changed as we are no longer invoking a route action, but we are invoking component's action now. Let's add the last changes to the component to make the acceptance test for the successful path happy. However, that will require adding some new code to the component, so let's start with a test as usual:

```{.javascript .numberLines}
// book-me/tests/integration/components/user-signup-test.js
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import testSelector from 'ember-test-selectors';

const {
  set,
} = Ember;

moduleForComponent('user-signup', 'Integration | Component | user signup', {
  integration: true
});

test('it invokes passed `registerUser` action when clicking on signup
  button', function(assert) {
  const {
    $,
  } = this;

  assert.expect(1);

  const user = Ember.Object.create();
  const registerUser = (userArgument) => {
    assert.deepEqual(userArgument, user,
      'action should be invoked with proper user argument');
  };

  set(this, 'user', user);
  set(this, 'registerUser', registerUser);

  this.render(hbs`{{user-signup user=user registerUser=registerUser}}`);

  $(testSelector('signup-submit-btn')).click();
});
```

It's just a simple component integration test where we verify that the `registerUser` action was invoked with correct arguments after clicking the signup button.

And here's the implementation:

```{.javascript .numberLines}
// book-me/app/components/user-signup.js
import Ember from 'ember';

const {
  get,
} = Ember

export default Ember.Component.extend({
  actions: {
    registerUser() {
      const user = get(this, 'user');
      get(this, 'registerUser')(user);
    },
  },
});
```

After all those changes we are back to green - all tests but the one for the failure path are passing, which means we did some refactoring of the code (without changing the behavior).

Now, let's add an integration test for the failure ensuring that the error messages are displayed and that the action is never called:

```{.javascript .numberLines}
// book-me/app/components/user-signup-test.js
test('it does not invoke passed `registerUser` action when there is a
  validation error and displays the error messages', function(assert) {
  const {
    $,
  } = this;

  assert.expect(1);

  const user = Ember.Object.create();
  const registerUser = () => {
    assert.notOk(true, 'action should not be called');
  };

  set(this, 'user', user);
  set(this, 'registerUser', registerUser);

  this.render(hbs`{{user-signup user=user registerUser=registerUser}}`);

  $(testSelector('signup-submit-btn')).click();

  assert.ok($(testSelector('signup-errors').length), 'errors should be displayed');
});
```

Let's get back to the idea of using changesets, which we will need in a moment for adding validations. However, we will start with refactoring the current behavior: we will just use changesets for syncing properties to model instead of directly using the model. First, we need to change the template:

```{.html .numberLines}
<!-- book-me/app/templates/components/user-signup.hbs -->
<form {{action "registerUser" on="submit"}}>
  <div class="form-group">
    <label for="signup-email">Email address</label>
    {{input
      data-test-signup-email-field
      id="signup-email"
      value=(mut changeset.email)
      class="form-control"
    }}
  </div>
  <div class="form-group">
    <label for="signup-password">Password</label>
    {{input
      data-test-signup-password-field
      id="signup-password"
      value=(mut changeset.password)
      class="form-control"
      type="password"
    }}
  </div>
  <div class="form-group">
    <label for="signup-password">Password Confirmation</label>
    {{input
      data-test-signup-password-confirmation-field
      id="signup-passwordConfirmation"
      value=(mut changeset.passwordConfirmation)
      class="form-control"
      type="password"
    }}
  </div>
  <button type="submit" class="btn btn-primary"
    data-test-signup-submit-btn>Submit</button>
</form>
```

And the component itself:

```{.javascript .numberLines}
// book-me/app/components/user-signup.js
import Ember from 'ember';
import Changeset from 'ember-changeset';

const {
  get,
  set,
} = Ember

export default Ember.Component.extend({
  init() {
    this._super(...arguments);

    const user = get(this, 'user');
    const changeset = new Changeset(user);

    set(this, 'changeset', changeset);
  },

  actions: {
    registerUser() {
      const changeset = get(this, 'changeset');
      get(this, 'registerUser')(changeset);
    },
  },
});
```

There are not that many changes - we merely introduced a changeset, which acts as a proxy for a model and we use it interchangeably in `registerUser` action - the cool thing is that saving the changes in the changesets requires calling the `save` method, just like for models.

However, we need to adjust one testing scenario for the integration test, which is not aware that we use `changeset`:

```{.javascript .numberLines}
// book-me/tests/integration/componenets/user-signup-test.js
test('it invokes passed `registerUser` action when clicking on
  signup button', function(assert) {
  const {
    $,
  } = this;

  assert.expect(1);

  const user = Ember.Object.create();
  const registerUser = (userArgument) => {
    // a change to make it changeset-aware: userArgument => userArgument._content
    assert.deepEqual(userArgument._content, user,
      'action should be invoked with proper user argument');
  };

  set(this, 'user', user);
  set(this, 'registerUser', registerUser);

  this.render(hbs`{{user-signup user=user registerUser=registerUser}}`);

  $(testSelector('signup-submit-btn')).click();
});
```

Now let's add some validations:

```
ember generate validator user-signup
```

As usual, we are going to start with the tests. The problem with unit-testing validators is that we couple tests to the interface of validators, which sounds a bit like an implementation detail and ideally it should be hidden behind changeset's interface, but doing the integration tests of validators seems to be an overkill, so let's accept the issue of coupling to implementation details and move on.

Changeset validators are higher-order functions which return the validator function. Here is one example:

```{.javascript .numberLines}
export default function validateCustom(options) {
  return (key, newValue, oldValue, changes, content) => {
    // return true if valid or error message if invalid
  }
}
```

By keeping in mind that the validator function returns `true` for valid results and error message for invalid results and that the validators are simply key-value pairs with attributes names as keys and validator functions as values, we may add some basic tests for `email` format, `password` length and `confirmation` validation for passwords:

```{.javascript .numberLines}
// book-me/tests/unit/validators/user-signup-test.js
import { module, test } from 'qunit';
import validateUserSignup from 'book-me/validators/user-signup';

module('Unit | Validator | user-signup');

test('it validates email format', function(assert) {
  assert.equal(validateUserSignup.email('email', 'invalid'),
    'Email must be a valid email address');
  assert.ok(validateUserSignup.email('email', 'example@gmail.com'));
});

test('it validates password length', function(assert) {
  assert.equal(validateUserSignup.password('password', 'invalid'),
    'Password is too short (minimum is 8 characters)');
  assert.ok(validateUserSignup.password('password', 'password123'));
});

test('it validates password confirmation', function(assert) {
  assert.equal(validateUserSignup.passwordConfirmation('passwordConfirmation',
    'invalid', '', { password: 'password123' }),
    "Password confirmation doesn't match password");
  assert.ok(validateUserSignup.passwordConfirmation('passwordConfirmation',
    'password123', '', { password: 'password123' }));
});
```

Indeed, we are tightly coupled to the implementation details, but it's good enough, we don't need to strive for the perfect tests suite. Writing those specs require knowing the signature of the validator functions, what kind of arguments do they accept, etc., so it is a good idea to check the [docs](https://github.com/DockYard/ember-changeset-validations/) and get familiar with all these concepts.

Here's the implementation that satisfies the tests:

```{.javascript .numberLines}
// book-me/app/validators/user-signup.js
import {
  validateLength,
  validateConfirmation,
  validateFormat
} from 'ember-changeset-validations/validators';

export default {
  email: validateFormat({ type: 'email' }),
  password: validateLength({ min: 8 }),
  passwordConfirmation: validateConfirmation({ on: 'password' }),
};
```

Now let's do the actual validation in the components and display the error messages if he changeset happens to be invalid:

```{.javascript .numberLines}
// book-me/app/components/user-signup.js
import Ember from 'ember';
import Changeset from 'ember-changeset';
import lookupValidator from 'ember-changeset-validations';
import UserSignupValidators from 'book-me/validators/user-signup';

const {
  get,
  set,
} = Ember

export default Ember.Component.extend({
  init() {
    this._super(...arguments);

    const user = get(this, 'user');
    const changeset = new Changeset(user, lookupValidator(UserSignupValidators),
      UserSignupValidators);

    set(this, 'changeset', changeset);
  },

  actions: {
    registerUser() {
      const changeset = get(this, 'changeset');

      changeset.validate().then(() => {
        if (get(changeset, 'isValid')) {
          get(this, 'registerUser')(changeset);
        }
      });
    },
  },
});
```

```{.html .numberLines}
<!-- book-me/app/templates/components/user-signup.hbs -->
{{#if changeset.isInvalid}}
  <section data-test-signup-errors>
    {{#each changeset.errors as |error|}}
      <div class="alert alert-danger" role="alert">
        {{error.validation}}
      </div>
    {{/each}}
  </section>
{{/if}}

<form {{action "registerUser" on="submit"}}>
  <div class="form-group">
    <label for="signup-email">Email address</label>
    {{input
      data-test-signup-email-field
      id="signup-email"
      value=(mut changeset.email)
      class="form-control"
    }}
  </div>
  <div class="form-group">
    <label for="signup-password">Password</label>
    {{input
      data-test-signup-password-field
      id="signup-password"
      value=(mut changeset.password)
      class="form-control"
    }}
  </div>
  <div class="form-group">
    <label for="signup-password">Password Confirmation</label>
    {{input
      data-test-signup-password-confirmation-field
      id="signup-passwordConfirmation"
      value=(mut changeset.passwordConfirmation)
      class="form-control"
    }}
  </div>
  <button type="submit" class="btn btn-primary"
    data-test-signup-submit-btn>Submit</button>
</form>
```

To give you an idea how it should look like, here's a screenshot:

![Form with errors](http://download.karolgalanciak.com/test-driven-ember/book_me_02.png)

We could expect that all tests will be green now, but it turns out we have one failure! The following scenario `'it invokes passed `registerUser` action when clicking on signup button'` in the `user-signup-test.js` fails because the form is invalid. To make it green, we need to fill the inputs with proper data:

```{.javascript .numberLines}
// book-me/tests/integration/componenets/user-signup-test.js
test('it invokes passed `registerUser` action when clicking on
  signup button', function(assert) {
  const {
    $,
  } = this;

  assert.expect(1);

  const user = Ember.Object.create();
  const registerUser = (userArgument) => {
    assert.deepEqual(userArgument._content, user,
      'action should be invoked with proper user argument');
  };

  set(this, 'user', user);
  set(this, 'registerUser', registerUser);

  this.render(hbs`{{user-signup user=user registerUser=registerUser}}`);

  $(testSelector('signup-email-field')).val('example@email.com').change();
  $(testSelector('signup-password-field')).val('password123').change();
  $(testSelector('signup-password-confirmation-field')).val('password123').change();

  $(testSelector('signup-submit-btn')).click();
});
```

And that's it! All tests are passing now!

It looks like we have now a working version of sign-up, but it's far from the truth - we've only confirmed so far that our form and validations work. Implementing the proper sign-up will require dealing with tokens and sessions.

When dealing with the authentication process, [ember-simple-auth](https://github.com/simplabs/ember-simple-auth) should cover most of our needs. And if not, it is easily extendible so we can either add our authentication strategy or tweak the existing ones.

Let's install the addon:

```
ember install ember-simple-auth
```

Explaining the details how `ember-simple-auth` works and how different authentication flows differ from each other and which one is the most suitable choice is beyond the scope of this book, I highly recommend to read the [docs](https://github.com/simplabs/ember-simple-auth) to learn more.

For the sake of simplicity, we will use `OAuth2PasswordGrantAuthenticator` which implements `Resource Owner Password Credentials Grant Type` without a refresh token and `OAuth2BearerAuthorizer` which uses Bearer tokens. The authenticators are the objects responsible for authenticating the session and authorizers use the data acquired by authenticators to handle authorization data that is required when performing the requests.

Let's add the necessary layers to our application. The first thing will be adding authenticators under `authenticators` directory:

```{.javascript .numberLines}
// book-me/app/authenticators/oauth2.js
import OAuth2PasswordGrant from 'ember-simple-auth/authenticators/oauth2-password-grant';

export default OAuth2PasswordGrant.extend({
  serverTokenEndpoint: '/api/oauth/token',
  serverTokenRevocationEndpoint: '/api/oauth/destroy',
  refreshAccessTokens: false,
});
```

We are extending here `OAuth2PasswordGrant` from `ember-simple-auth` and we are doing some extra customization to specify the endpoint for acquiring tokens and revoking them. We also don't care this time about refresh tokens, so we set `refreshAccessTokens` to `false`.

The next thing will be adding `authorizer` under `authorizers` directory:

```{.javascript .numberLines}
// book-me/app/authorizers/oauth2.js
import OAuth2Bearer from 'ember-simple-auth/authorizers/oauth2-bearer';

export default OAuth2Bearer.extend();
```

Now let's extend our `ApplicationAdapter` with `DataAdapterMixin` which will be used for properly handling the authorization process:

```{.javascript .numberLines}
// book-me/app/adapters/application.js
import DS from 'ember-data';
import DataAdapterMixin from 'ember-simple-auth/mixins/data-adapter-mixin';

export default DS.JSONAPIAdapter.extend(DataAdapterMixin, {
  namespace: 'api',
  authorizer: 'authorizer:oauth2',
});
```

At this point, we need to update the unit test for the `ApplicationAdapter` which will be failing now because of the `service:session` dependency. Let's fix it now:

```{.javascript .numberLines}
// book-me/tests/unit/adapters/application.js
import { moduleFor, test } from 'ember-qunit';

moduleFor('adapter:application', 'Unit | Adapter | application', {
  // added the dependency
  needs: ['service:session']
});
```

Let's focus now on simulating the backend part when it comes to tokens and authentication process in `ember-cli-mirage` config. We need two endpoints: one for handling the login and one for the logout processes. For logout it is pretty simple: we will assume that the response is always successful, so we will just return a response with `204` HTTP code and no body. For login it's a bit more complex: we need somehow to implement the authentication process. The simplest way to do it (which would also be close to what happens on backend server) would be to find the user by provided email and compare the provided password with user's password. In that case, we will return the data in the expected format. Otherwise, we will return 401 status to indicate that the request is not authenticated with some error message. Here's how we can approach this problem:

```{.javascript .numberLines}
// book-me/mirage/config.js
import Mirage from 'ember-cli-mirage';

const {
  Response,
} = Mirage;

export default function() {
  this.namespace = 'api';

  this.post('/users');

  this.post('/oauth/token', (schema, request) => {
    const potentialPasswordMatch = request.requestBody.match(/password=([^&]*)/);
    const potentialEmailMatch = request.requestBody.match(/username=([^&]*)/);
    // example: [
    //   "password=password123",
    //   "password123",
    //   index: 50,
    //   input: "grant_type=password&username=example%40gmail.com&password=password123"
    // ]
    const password = potentialPasswordMatch && potentialPasswordMatch[1];
    const email = potentialEmailMatch && decodeURIComponent(potentialEmailMatch[1]);

    const user = schema.users.findBy({ email });

    if (!user || user.password !== password) {
      return new Response(401, {}, { message: 'invalid credentials' });
    } else {
      return {
        access_token: '123456789',
        token_type: 'bearer',
        user_id: user.id,
      };
    }
  });

  this.post('/oauth/destroy', () => {
    return new Response(204);
  });
}
```

At this point we've already made a proper setup for authentication and authorization process, so we can add another scenario. What we want to achieve is to make sure that the `token` endpoint is indeed reached and that we transition to some authentication-protected route, let's call it an `admin` route, after a successful signup.

As `ember-cli-mirage` uses `pretender` internally, we could take advantage of a great feature provided by `pretender` - recording of handled requests. Thanks to this feature, we can check all the requests that have been performed with the URLs of the endpoints, request bodies, etc. Let's modify our `user can successfully sign up` scenario:

```{.javascript .numberLines}
// book-me/tests/acceptance/sign-in-sign-up-test.js
/* global server */
import { test } from 'qunit';
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import testSelector from 'ember-test-selectors';

moduleForAcceptance('Acceptance | sign in sign up', {
  beforeEach() {
    this.email = 'example@email.com';
    this.password = 'password123';
  }
});
test('user can successfully sign up', function(assert) {
  assert.expect(3);

  const { email, password } = this;

  server.post('/users', function(schema)  {
    const attributes = this.normalizedRequestAttrs();
    const expectedAttributes = {
      email: email,
      password: password,
    };

    assert.deepEqual(attributes, expectedAttributes,
      "attributes don't match the expected ones");

    return schema.users.create(attributes);
  });

  visit('/');

  click(testSelector('signup-link'));

  andThen(() => {
    fillIn(testSelector('signup-email-field'), email);
    fillIn(testSelector('signup-password-field'), password);
    fillIn(testSelector('signup-password-confirmation-field'), password);

    click(testSelector('signup-submit-btn'));
  });

  // new scenario: make sure that the request to `tokens` endpoint is performed
  andThen(() => {
    const tokenUrl = '/api/oauth/token';
    const tokenRequest = server.pretender.handledRequests.find((request) => {
      return request.url === tokenUrl;
    });

    assert.ok(tokenRequest, 'tokenRequest should be performed');
    assert.equal(currentURL(), '/admin');
  });
});
```

Let's make our test suite happy again. We will start with some adjustments in `signup` route. The simplest way to solve our problem will be using `session` service from `ember-simple-auth` and authenticating the user after it gets created:

```{.javascript .numberLines}
// book-me/app/routes/signup.js
import Ember from 'ember';

const {
  set,
  get,
  getProperties,
  inject: {
    service,
  }
} = Ember;

export default Ember.Route.extend({
  session: service(),

  model() {
    return this.store.createRecord('user');
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'user', model);
  },

  actions: {
    registerUser(user) {
      user.save().then(() => {
        const { email, password } = getProperties(user, 'email', 'password');

        get(this, 'session').authenticate('authenticator:oauth2', email, password);
      });
    },
  },
});
```

We also need to update the unit test for the route and inject `service:session` dependency:

```{.javascript .numberLines}
// book-me/tests/unit/routes/sign-up-test.js
import { moduleFor, test } from 'ember-qunit';

moduleFor('route:signup', 'Unit | Route | signup', {
  needs: ['service:session']
});
```

We are almost there; now we are only missing the implementation for the final step: the transition to `admin` route. To handle this step, we can just transition to that route after the successful authentication:

```{.javascript .numberLines}
// book-me/app/routes/signup.js
export default Ember.Route.extend({

  // the rest of the logic
  actions: {
    registerUser(user) {
      user.save().then(() => {
        const { email, password } = getProperties(user, 'email', 'password');

        get(this, 'session').authenticate('authenticator:oauth2', email,
          password).then(() => {
            this.transitionTo('admin');
        });
      });
    },
  },
});
```

We also need to set up the routing and the template for the new route:

```{.javascript .numberLines}
// book-me/app/router.js
import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('signup');
  this.route('admin'); // new route
});

export default Router;
```

Here is a new route:

```
import Ember from 'ember';

export default Ember.Route.extend();
```

Let's skip the authentication-protection for this route to not add too much code at once, especially if this part is not covered with any tests.

And the final step, the template:

```{.html .numberLines}
<!-- book-me/app/templates/admin.hbs -->
<h2>Admin</h2>
```

And all the tests are passing again! However, there is one scenario we are missing: what if the error comes not from the client-side validation, but from the server? So far we've only covered the error case when the validation fails in Ember app. Let's add another test for the scenario we've just discovered:

```{.javascript .numberLines}
// tests/acceptance/sign-in-sign-up-test.js
test('user cannot signup if there is an error on server', function(assert) {
  assert.expect(1);

  const { email, password } = this;

  server.post('/users', () => {
    const errors = {
      errors: [
        {
          detail: 'is already taken',
          source: {
            pointer: 'data/attributes/email'
          }
        }
      ]
    };
    return new Response(422, {}, errors);
  });

  visit('/');

  click(testSelector('signup-link'));

  andThen(() => {
    fillIn(testSelector('signup-email-field'), email);
    fillIn(testSelector('signup-password-field'), password);
    fillIn(testSelector('signup-password-confirmation-field'), password);

    click(testSelector('signup-submit-btn'));
  });

  andThen(() => {
    assert.ok(find(testSelector('signup-errors')).length, 'errors should be displayed');
  });
});
```

To make the new test pass, we just need to handle the error scenario in `registerUser` action in `signup` route:

```{.javascript .numberLines}
// book-me/app/routes/signup.js
  actions: {
    registerUser(user) {
      user.save().then(() => {
        const { email, password } = getProperties(user, 'email', 'password');

        get(this, 'session').authenticate('authenticator:oauth2', email,
          password).then(() => {
            this.transitionTo('admin');
          }).catch(() => { // handle error scenario
      		  get(user._content, 'errors').forEach(({ attribute, message }) => {
      			  user.pushErrors(attribute, message);
      		  });
        });
      });
    },
  },
```

As this is a scenario for handling server-side errors, our `user` changeset won't be automatically populated with model errors; we need to do it manually. Fortunately, populating the errors is handled by Ember Data and we can just loop over all the errors and add them to the changeset using `pushErrors` method.

Now, we can proceed to the next feature: making `admin` route protected by the authentication. Again, let's start with the test, the acceptance one:

```
ember g acceptance-test access-admin
```

And here's our test:

```{.javascript .numberLines}
// book-me/tests/acceptance/access-admin-test.js
/* global server */
import { test } from 'qunit';
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import { authenticateSession, } from 'book-me/tests/helpers/ember-simple-auth';

moduleForAcceptance('Acceptance | access admin');

test('it is not possible to visit `admin` without authentication', function(assert) {
  assert.expect(1);

  visit('/admin');

  andThen(() => {
    assert.equal(currentPath(), 'login',
      'should not be an admin route for not authenticated users');
  });
});

test('it is possible to visit `admin` when user is authenticated', function(assert) {
  assert.expect(1);

  const user = server.create('user');
  authenticateSession(this.application, { user_id: user.id });

  visit('/admin');

  andThen(() => {
    assert.equal(currentPath(), 'admin', 'should be an admin route');
  });
});
```

We are taking advantage of `authenticateSession` provided by `ember-simple-auth` which greatly simplifies authentication process for tests' setup. We want to verify two scenarios: one is that without authentication we can't access the `admin` route and the other one is that after being authenticated we can access that route.

To make the `admin` route, protected we need to include `AuthenticatedRouteMixin` from `ember-simple-auth`:

```{.javascript .numberLines}
// book-me/app/routes/admin.js
import Ember from 'ember';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

export default Ember.Route.extend(AuthenticatedRouteMixin, {
});
```

By default `ember-simple-auth` performs a transition to `login` route if the user is not authenticated, so it would be a good idea to add this route in the first place:

```{.javascript .numberLines}
// book-me/app/router.js
import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('signup');
  this.route('login'); // new route
  this.route('admin');
});

export default Router;
```

And now we are back to green! All tests are passing.

If we already added the `login` route, it would be a good idea to implement the login process itself.

Again, let's start with the acceptance test:

```
ember g acceptance-test user-login
```

We want to cover here three scenarios: First, that after providing the valid email and password combo the user will be logged in and redirected to `admin` route. The other two would be failures for both client and server side issues. Here are the tests covering these scenarios:

```{.javascript .numberLines}
// book-me/tests/acceptance/user-login-test.js
/* global server */
import { test } from 'qunit';
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import testSelector from 'ember-test-selectors';

moduleForAcceptance('Acceptance | user login', {
  beforeEach() {
    const email = 'example@email.com';
    const password = 'password123';

    this.email = email;
    this.password = password;
    this.user = server.create('user', { email, password, });
  }
});

test('user can successfully log in and is redirected to /admin route', function(assert) {
  assert.expect(1);

  const { email, password } = this;

  visit('/');

  click(testSelector('login-link'));

  andThen(() => {
    fillIn(testSelector('login-email-field'), email);
    fillIn(testSelector('login-password-field'), password);

    click(testSelector('login-submit-btn'));
  });

  andThen(() => {
    assert.equal(currentPath(), 'admin', 'should be an admin route');
  });
});

test('user cannot log in with invalid credentials and sees the error messages from
  client', function(assert) {
  assert.expect(2);

  visit('/');

  click(testSelector('login-link'));

  andThen(() => {
    fillIn(testSelector('login-email-field'), '');
    fillIn(testSelector('login-password-field'), '');

    click(testSelector('login-submit-btn'));
  });

  andThen(() => {
    assert.equal(currentPath(), 'login', 'should still be a login route');
    assert.ok(find(testSelector('login-errors')).length, 'errors should be displayed');
  });
});

test('user cannot log in with invalid credentials and sees the error messages
  from server', function(assert) {
  assert.expect(2);

  visit('/');

  click(testSelector('login-link'));

  andThen(() => {
    fillIn(testSelector('login-email-field'), this.email);
    fillIn(testSelector('login-password-field'), 'invalidPassword');

    click(testSelector('login-submit-btn'));
  });

  andThen(() => {
    assert.equal(currentPath(), 'login', 'should still be a login route');
    assert.ok(find(testSelector('login-errors')).length, 'errors should be displayed');
  });
});
```

Let's make these tests green now. We need to start with generating a `login` route:

```
ember g route login
```

Let's do something similar as we did for signup and generate `user-login` component. It may sound a bit like a Big Design Upfront. However, we already did something very similar for the signup process and we can easily predict that having a separate component will be useful in this use case as well. Let's generate it then:

```
ember g component user-login
```

Before adding anything new to the `login` or `user-login` templates, let's add the actual link to the login page in the layout template (`application.hbs`):

```{.html .numberLines}
<!-- book-me/app/templates/application.hbs -->
<nav class="navbar navbar-default navbar-fixed-top" role="navigation">
  <div class="container-fluid">
    <div class="navbar-header">
      <button type="button" class="navbar-toggle navbar-toggle-context"
              data-toggle="collapse" data-target=".navbar-top-collapse">
        <span class="sr-only">Toggle Navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <div class="navbar-brand-container">
        <span class="navbar-brand">
          <h1><i class="fa fa-star"></i> Book Me!</h1>
        </span>
      </div>
    </div>
    <div class="collapse navbar-collapse navbar-top-collapse">
      <div class="navbar-right">
        {{link-to "Sign up" "signup" data-test-signup-link
          class="btn btn-primary navbar-btn"}}
        {{link-to "Login" "login" data-test-login-link
          class="btn btn-primary navbar-btn"}}
      </div>
    </div>
  </div>
</nav>
<section class="main-content">
  <div class="sheet">
    {{outlet}}
  </div>
</section>
```

And let's render the component in `login` template:

```{.html .numberLines}
<!-- book-me/app/templates/login.js -->
{{user-login}}
```

Just like for the **signup** use case, we want the **login** component to encapsulate data aggregation for the process, handle validation and if the data is valid, call some action that would handle the actual login. That action should probably come from the route. But for now, let's focus exclusively on the component. Just like before, we are going to start with the tests.

```{.javascript .numberLines}
// app/tests/integration/components/user-login-test.js
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import testSelector from 'ember-test-selectors';

const {
  set,
} = Ember;

moduleForComponent('user-login', 'Integration | Component | user login', {
  integration: true
});

test('it invokes passed `loginUser` action when clicking on login button',
  function(assert) {
  const {
    $,
  } = this;

  assert.expect(1);

  const loginModel = Ember.Object.create();
  const loginUser = (loginArgument) => {
    assert.deepEqual(loginArgument._content,
      loginModel, 'action should be invoked with proper user argument');
  };

  set(this, 'loginUser', loginUser);

  this.render(hbs`{{user-login loginUser=loginUser}}`);

  $(testSelector('login-email-field')).val('example@email.com').change();
  $(testSelector('login-password-field')).val('password').change();

  $(testSelector('login-submit-btn')).click();
});

test('it does not invoke passed `loginUser` action when there is a
  validation error and displays the error messages', function(assert) {
  const {
    $,
  } = this;

  assert.expect(1);

  const loginUser = () => {
    assert.notOk(true, 'action should not be called');
  };

  set(this, 'loginUser', loginUser);

  this.render(hbs`{{user-login loginUser=loginUser}}`);

  $(testSelector('login-submit-btn')).click();

  assert.ok($(testSelector('login-errors').length), 'errors should be displayed');
});
```

These tests are quite similar to the ones for the **signup** - we want to test both success and failure scenarios. For the success one, we want to make sure that the action passed to the component is called with the proper arguments and for the failure case, we want to ensure that the action is not called and the error messages from validation are displayed.

Time to make these tests happy. Here is the simple component to make the success scenario pass:

```{.javascript .numberLines}
// book-me/app/components/user-login.js
import Ember from 'ember';
import Changeset from 'ember-changeset';

const {
  get,
  set,
} = Ember

export default Ember.Component.extend({
  init() {
    this._super(...arguments);

    const loginModel = Ember.Object.create();
    const changeset = new Changeset(loginModel);

    set(this, 'changeset', changeset);
  },

  actions: {
    loginUser() {
      const changeset = get(this, 'changeset');

      get(this, 'loginUser')(changeset);
    },
  },
});
```

And here's the template:

```{.html .numberLines}
<!-- book-me/app/templates/components/user-login.hbs -->
<h2>Log in</h2>

<form {{action "loginUser" on="submit"}}>
  <div class="form-group">
    <label for="login-email">Email address</label>
    {{input
      data-test-login-email-field
      id="login-email"
      value=(mut changeset.email)
      class="form-control"
    }}
  </div>
  <div class="form-group">
    <label for="login-password">Password</label>
    {{input
      data-test-login-password-field
      id="login-password"
      value=(mut changeset.password)
      class="form-control"
      type="password"
    }}
  </div>
  <button type="submit" class="btn btn-primary"
    data-test-login-submit-btn>Log in</button>
</form>
```

Not many surprises here: we just set up the proper `changeset` and provide input fields for `email` and `password` and obviously the submit button. We are using a virtual `loginModel` - we don't want to use any Ember Data model here as it doesn't make much sense - we just need some something that can merely aggregate the data, so we are simply creating an Ember Object to be used as such attributes' aggregate.

With this code, we managed to get the integration tests pass. Let's deal with the validation messages now. First, we are going to decide on the actual validations we need and write tests for them.

We don't need to make it overly complicated, so let's just validate the format of the `email` address and make sure that the password has at least eight characters, which is also the requirement for signup process.

Here are the tests:

```{.javascript .numberLines}
// book-me/tests/unit/validators/user-login-test.js
import { module, test } from 'qunit';
import validateUserLogin from 'book-me/validators/user-login';

module('Unit | Validator | user-login');

test('it validates email format', function(assert) {
  assert.equal(validateUserLogin.email('email', 'invalid'),
    'Email must be a valid email address');
  assert.ok(validateUserLogin.email('email', 'example@gmail.com'));
});

test('it validates password length', function(assert) {
  assert.equal(validateUserLogin.password('password', 'invalid'),
    'Password is too short (minimum is 8 characters)');
  assert.ok(validateUserLogin.password('password', 'password123'));
});
```

And the implementation that will make these tests pass:

```{.javascript .numberLines}
// book-me/app/validators/user-login.js
import {
  validateLength,
  validateFormat
} from 'ember-changeset-validations/validators';

export default {
  email: validateFormat({ type: 'email' }),
  password: validateLength({ min: 8 }),
};
```

Let's get back to the login component. It's almost the same as the signup component, so we may handle it with the same flow:

```{.javascript .numberLines}
// book-me/app/components/user-login.js
import Ember from 'ember';
import Changeset from 'ember-changeset';
import lookupValidator from 'ember-changeset-validations';
import UserLoginValidators from 'book-me/validators/user-login';

const {
  get,
  set,
} = Ember

export default Ember.Component.extend({
  init() {
    this._super(...arguments);

    const loginModel = Ember.Object.create();
    const changeset = new Changeset(loginModel, lookupValidator(UserLoginValidators),
      UserLoginValidators);

    set(this, 'changeset', changeset);
  },

  actions: {
    loginUser() {
      const changeset = get(this, 'changeset');

      changeset.validate().then(() => {
        if (get(changeset, 'isValid')) {
          get(this, 'loginUser')(changeset);
        }
      });
    },
  },
});
```

And, as the last step, let's display the error messages if the changeset is invalid:

```{.html .numberLines}
<!-- book-me/app/templates/components/user-login.js -->
<h2>Log in</h2>

{{#if changeset.isInvalid}}
  <section data-test-login-errors>
    {{#each changeset.errors as |error|}}
      <div class="alert alert-danger" role="alert">
        {{error.validation}}
      </div>
    {{/each}}
  </section>
{{/if}}

<form {{action "loginUser" on="submit"}}>
  <div class="form-group">
    <label for="login-email">Email address</label>
    {{input
      data-test-login-email-field
      id="login-email"
      value=(mut changeset.email)
      class="form-control"
    }}
  </div>
  <div class="form-group">
    <label for="login-password">Password</label>
    {{input
      data-test-login-password-field
      id="login-password"
      value=(mut changeset.password)
      class="form-control"
      type="password"
    }}
  </div>
  <button type="submit" class="btn btn-primary"
    data-test-login-submit-btn>Log in</button>
</form>
```

We've managed to make all the integration tests pass; however, we still have the acceptance ones failing. Apparently, we haven't defined `loginUser` function yet that will be responsible for the actual logging in, so let's add it now. Just like for the signup process, we need a route action:

```{.javascript .numberLines}
// book-me/app/routes/login.js
import Ember from 'ember';

const {
  get,
  getProperties,
  inject: {
    service,
  }
} = Ember;

export default Ember.Route.extend({
  session: service(),

  actions: {
    loginUser(loginModel) {
      const { email, password } = getProperties(loginModel, 'email', 'password');

      get(this, 'session').authenticate('authenticator:oauth2', email,
        password).then(() => {
          this.transitionTo('admin');
        }).catch((error) => {
          loginModel.addError('login', error.message);
        });
    },
  },
});
```

Now we just need a final adjustment in login route unit test as we injected the `session` service:

```{.javascript .numberLines}
// book-me/tests/unit/routes/login-test.js
import { moduleFor, test } from 'ember-qunit';

moduleFor('route:login', 'Unit | Route | login', {
  needs: ['service:session']
});

test('it exists', function(assert) {
  let route = this.subject();
  assert.ok(route);
});
```

All there tests are passing now! It seems like we've just finished our first feature.

However, there are some duplications here and there. Some of the tests have quite a similar setup, especially the ones for the signup - they require filling some input and submitting the form. That's a perfect use case to DRY up with page objects! Let's install `ember-cli-page-object` addon:

```
ember install ember-cli-page-object
```

and generate a page object for the signup process:

```
ember generate page-object signup
```

Interacting with the signup page consists of visiting the page, filling the fields with the proper values and submitting the form. For such use case, this is how our page object may look like:

```{.javascript .numberLines}
// book-me/tests/pages/signup.js
import {
  create,
  visitable,
  clickable,
  fillable,
} from 'ember-cli-page-object';
import testSelector from 'ember-test-selectors';

export default create({
  visit: visitable('/'),
  goToSignup: clickable(testSelector('signup-link')),
  email: fillable(testSelector('signup-email-field')),
  password: fillable(testSelector('signup-password-field')),
  passwordConfirmation: fillable(testSelector('signup-password-confirmation-field')),
  submit: clickable(testSelector('signup-submit-btn')),
});
```

And here are the acceptance `sign in sign up` tests after the refactoring to page objects:

```{.javascript .numberLines}
// book-me/tests/acceptance/sign-in-sign-up-test.js
/* global server */
import { test } from 'qunit';
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import testSelector from 'ember-test-selectors';
import Mirage from 'ember-cli-mirage';
import signupPage from 'book-me/tests/pages/signup';

const {
  Response,
} = Mirage;

moduleForAcceptance('Acceptance | sign in sign up', {
  beforeEach() {
    this.email = 'example@email.com';
    this.password = 'password123';
  }
});
test('user can successfully sign up', function(assert) {
  assert.expect(3);

  const { email, password } = this;

  server.post('/users', function(schema)  {
    const attributes = this.normalizedRequestAttrs();
    const expectedAttributes = {
      email: email,
      password: password,
    };

    assert.deepEqual(attributes, expectedAttributes,
      "attributes don't match the expected ones");

    return schema.users.create(attributes);
  });

  andThen(() => {
    signupPage
      .visit()
      .goToSignup()
      .email(email)
      .password(password)
      .passwordConfirmation(password)
      .submit();
  });

  andThen(() => {
    const tokenUrl = '/api/oauth/token';
    const tokenRequest = server.pretender.handledRequests.find((request) => {
      return request.url === tokenUrl;
    });

    assert.ok(tokenRequest, 'tokenRequest should be performed');
    assert.equal(currentURL(), '/admin');
  });
});

test('user cannot signup if there is an error', function(assert) {
  assert.expect(1);

  const { email, password } = this;

  server.post('/users', () => {
    assert.notOk(true, 'request should not be performed');
  });

  andThen(() => {
    signupPage
      .visit()
      .goToSignup()
      .email(email)
      .password(password)
      .submit();
  });

  andThen(() => {
    assert.ok(find(testSelector('signup-errors')).length, 'errors should be displayed');
  });
});

test('user cannot signup if there is an error on server when fetching a token',
  function(assert) {
  assert.expect(1);

  const { email, password } = this;

  server.post('/oauth/token', () => {
    return new Response(401, {}, { message: 'invalid credentials' });
  });

  andThen(() => {
    signupPage
      .visit()
      .goToSignup()
      .email(email)
      .password(password)
      .passwordConfirmation(password)
      .submit();
  });

  andThen(() => {
    assert.ok(find(testSelector('signup-errors')).length, 'errors should be displayed');
  });
});

test('user cannot signup if there is an error on server when creating a user',
  function(assert) {
  assert.expect(1);

  const { email, password } = this;

  server.post('/users', () => {
    const errors = {
      errors: [
        {
          detail: 'is already taken',
          source: {
            pointer: 'data/attributes/email'
          }
        }
      ]
    };
    return new Response(422, {}, errors);
  });

  andThen(() => {
    signupPage
      .visit()
      .goToSignup()
      .email(email)
      .password(password)
      .passwordConfirmation(password)
      .submit();
  });

  andThen(() => {
    assert.ok(find(testSelector('signup-errors')).length, 'errors should be displayed');
  });
});
```

Looks much better! The code is more readable, more reusable and the implementation details are hidden behind expressive methods. Let's do the same thing for the tests for `user login` scenario:

```
ember generate page-object login
```

Here are the steps for interacting with `login` page:

```{.javascript .numberLines}
// book-me/tests/pages/login.js
import {
  create,
  visitable,
  clickable,
  fillable,
} from 'ember-cli-page-object';
import testSelector from 'ember-test-selectors';

export default create({
  visit: visitable('/'),
  goTologin: clickable(testSelector('login-link')),
  email: fillable(testSelector('login-email-field')),
  password: fillable(testSelector('login-password-field')),
  submit: clickable(testSelector('login-submit-btn')),
});
```

And the tests after the refactoring:

```{.javascript .numberLines}
// book-me/tests/acceptance/user-login-test.js
/* global server */
import { test } from 'qunit';
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import testSelector from 'ember-test-selectors';
import loginPage from 'book-me/tests/pages/login';

moduleForAcceptance('Acceptance | user login', {
  beforeEach() {
    const email = 'example@email.com';
    const password = 'password123';

    this.email = email;
    this.password = password;
    this.user = server.create('user', { email, password, });
  }
});

test('user can successfully log in and is redirected to /admin route', function(assert) {
  assert.expect(1);

  const { email, password } = this;

  andThen(() => {
    loginPage
      .visit()
      .goTologin()
      .email(email)
      .password(password)
      .submit();
  });

  andThen(() => {
    assert.equal(currentPath(), 'admin', 'should be an admin route');
  });
});

test('user cannot log in with invalid credentials and sees the error messages
  from client', function(assert) {
  assert.expect(2);

  andThen(() => {
    loginPage
      .visit()
      .goTologin()
      .email('')
      .password('')
      .submit();
  });

  andThen(() => {
    assert.equal(currentPath(), 'login', 'should still be a login route');
    assert.ok(find(testSelector('login-errors')).length, 'errors should be displayed');
  });
});

test('user cannot log in with invalid credentials and sees the error messages
  from server', function(assert) {
  assert.expect(2);

  andThen(() => {
    loginPage
      .visit()
      .goTologin()
      .email(this.email)
      .password('invalidPassword')
      .submit();
  });

  andThen(() => {
    assert.equal(currentPath(), 'login', 'should still be a login route');
    assert.ok(find(testSelector('login-errors')).length, 'errors should be displayed');
  });
});
```

Again, much cleaner!

To put the cherry on top, let's make some improvements when it comes to sign in / sign up process - we can do both of these things, but so far we are not able to log out! The other problem is that `Sign up` and `Login` buttons are displayed even when a user is authenticated. We need to change that. Obviously, we will start with a spec - for that purpose, we will extend `User Login` and `user can successfully log in and is redirected to /admin route` scenarios a bit:

```{.javascript .numberLines}
// book-me/tests/acceptance/user-login-test.js
test('user can successfully log in and is redirected to /admin route and is
  able to logout afterward', function(assert) {
  assert.expect(4);

  const { email, password } = this;

  andThen(() => {
    loginPage
      .visit()
      .goTologin()
      .email(email)
      .password(password)
      .submit();
  });

  andThen(() => {
    assert.equal(currentPath(), 'admin', 'should be an admin route');
    assert.notOk(find(testSelector('signup-link')).length,
      'signup button should not be displayed');
    assert.notOk(find(testSelector('login-link')).length,
      'login button should not be displayed');
  });

  click(testSelector('logout-link'));

  andThen(() => {
    assert.equal(currentPath(), 'index', 'should be an application route');
  });
});
```

To make the new scenario pass, we just need to add an action for handling logging out and make the proper adjustments in the templates. We can easily reuse the example that is documented in `ember-simple-auth` docs. Let's start with the injection of `session` service to `application` route and defining `logOut` action:

```{.javascript .numberLines}
// book-me/app/routes/application.js
import Ember from 'ember';

const {
  inject: { service },
  get,
  set,
} = Ember;

export default Ember.Route.extend({
  session: service(),

  setupController(controller) {
    this._super();

    set(controller, 'session', get(this, 'session'));
  },

  actions: {
    logOut() {
      get(this, 'session').invalidate().then(() => {
        this.transitionTo('application');
      });
    },
  },
});
```

And update `application` template:

```{.html .numberLines}
<!-- book-me/app/templates/application.hbs -->
<div class="collapse navbar-collapse navbar-top-collapse">
  <div class="navbar-right">
    {{#if session.isAuthenticated}}
      <a {{action (route-action 'logOut')}}
        data-test-logout-link class="btn btn-primary navbar-btn">Logout</a>
    {{else}}
      {{link-to "Sign up" "signup" data-test-signup-link
        class="btn btn-primary navbar-btn"}}
      {{link-to "Login" "login" data-test-login-link
        class="btn btn-primary navbar-btn"}}
    {{/if}}
  </div>
</div>
```

That would mean we've managed to finish our first feature - sign in/sign up process following the entire TDD cycle - red/green/ refactor.

Now we can start implementing the core domain of our application - rentals management and a calendar for creating bookings.

\pagebreak

## Adding The Core Feature - Rentals' CRUD And The Calendar

Now we are getting to the most exciting part of the application. Let's break it down into some basic points to fully understand what we want to achieve here:

* Rentals (properties) can be booked for a particular period (bookings). To keep it realistic, let's assume that the minimum stay is one night.

* Rentals must have some **daily rate** defined so that it is possible to calculate the price for the booking for a given period.

* Obviously, bookings for a given rental cannot overlap with each other.

* Bookings must be associated with some client. To keep it simple, we won't introduce any new model, like `Client`, we will just have `clientEmail` attribute instead of a client relationship, which should be just enough in our case.

* Also, bookings must have **price** attribute stored on themselves - we can't safely rely on rental's **daily rate** as it might change and obviously, the price of already existing booking should stay the same.

So what we want to do here is to implement full CRUD for rentals and CRUD for bookings with a bit more complex way of creating bookings - we could just add two date fields backed by datepickers, but that would not be the best UX. A proper calendar sounds like a much better choice.

However, building a calendar sounds like an awful amount of work. How are we going to handle it?

Fortunately, there is already an addon for that! [ember-power-calendar](http://www.ember-power-calendar.com) is robust and flexible and easily saves us hours of work!

That's one of the most amazing things about developing applications in Ember - not only is it an awesome framework that makes you very productive, but also the community has already created so many addons that solve quite complex problems in a generic way.

However, before adding a calendar, we need to implement a full CRUD for rentals.

### Rentals' CRUD

Fortunately, with Ember, it is a pretty straight-forward task. Just like before, let's start with an acceptance test:

```
ember g acceptance-test rentals-crud
```

The first thing we will test will be "C" and "R" parts of CRUD which is creating and reading accordingly. What we initially expect to see here is empty admin page when there are no rentals created yet. The next step will be visiting some `create` page, filling forms, creating a rental and making sure the new rental that has just been created is displayed there. A good thing to do would also be to ensure the POST request is performed to `/rentals` endpoint - otherwise, we may get a false-positive and see the in-memory rental on the admin page, not the one that has been created and persisted on the server.

Before writing test let's take advantage of the awesome `resource` helper from `ember-cli-mirage` which defines all routes for CRUD actions:

```{.javascript .numberLines}
// book-me/mirage/config.js
export default function() {
	// existing code

	this.resource('rentals');
};
```

And here's out initial test:

```{.javascript .numberLines}
// book-me/tests/acceptance/rentals-crud-test.js
/* global server */
import { test } from 'qunit';
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import testSelector from 'ember-test-selectors';
import { authenticateSession, } from 'book-me/tests/helpers/ember-simple-auth';
import PageObject, {
  clickable,
  fillable,
  visitable
} from 'book-me/tests/page-object';

moduleForAcceptance('Acceptance | rentals crud');

test('it is possible to read, create, edit and delete rentals', function(assert) {
  assert.expect(3);

  const page = PageObject.create({
    visitAdmin: visitable('/admin'),
    goToNewRental: clickable(testSelector('add-rental')),
    rentalName: fillable(testSelector('rental-name')),
    rentalDailyRate: fillable(testSelector('rental-daily-rate')),
    createRental: clickable(testSelector('create-rental'))
  });

  const user = server.create('user');
  authenticateSession(this.application, { user_id: user.id });

  page.visitAdmin();

  andThen(() => {
    assert.notOk(find(testSelector('rental-row')).length, 'no rentals should be visible');
  });

  const name = 'Rental 1';
  const dailyRate = 100;

  server.post('/rentals', function (schema) {
    const attributes = this.normalizedRequestAttrs();
    const expectedAttributes = { name, dailyRate };

    assert.deepEqual(attributes, expectedAttributes,
      "attributes don't match the expected ones");

    return schema.rentals.create(attributes);
  });

  page
    .goToNewRental()
    .rentalName(name)
    .rentalDailyRate(dailyRate)
    .createRental();

  andThen(() => {
    assert.ok(find(testSelector('rental-row')).length, 'a new rental should be visible');
  });
});
```

Not many surprises here - we are taking advantage of **test selectors** and **page objects** to make the test more expressive and simpler for both writing and reading. Not only do we interact with UI but we are also verifying if the expected request has been performed, which might not be the case if there is some validation error.

You might be wondering if we haven't written too many tests at once - shouldn't we maybe write one test, make it pass and only then write another one? That is a good question, but the answer is: it depends. In case of such simple scenario like here, there is not much risk in doing that, and I can't recall any single false-positives in similar cases in acceptance tests, so I'm confident enough to bend some TDD rules. However, writing a minimum amount of tests and then writing a minimum implementation to make those tests pass is the right default way of TDD and unless you really know what you are doing, I wouldn't recommend going against it.

To make this scenario pass let's generate the model first:

```
ember g model Rental name dailyRate
```

and provide the types of the attributes:

```{.javascript .numberLines}
// book-me/app/models/rental.js
import DS from 'ember-data';

const {
  Model,
  attr,
} = DS;

export default Model.extend({
  name: attr('string'),
  dailyRate: attr('number')
});
```

The next step will be adding some table to `admin.hbs` template where we are going to display all the rentals and also the button for adding a new rental:

```{.html .numberLines}
<!-- book-me/app/templates/admin.hbs -->
<h2>Admin</h2>

{{#link-to 'rentals.new' data-test-add-rental class='btn btn-primary'}}
  Add rental
{{/link-to}}

<table class='table table-border'>
  <thead>
    <tr>
      <th>Name</th>
      <th>Daily Rate</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    {{#each rentals as |rental|}}
      <tr data-test-rental-row>
        <td>{{rental.name}}</td>
        <td>{{rental.dailyRate}}</td>
        <td></td>
      </tr>
    {{/each}}
  </tbody>
</table>
```

As we need `rentals` to be available under `rentals` property, not generic `model` property, let's do the proper adjustments in `admin` route:

```{.javascript .numberLines}
// book-me/app/routes/admin.js
import Ember from 'ember';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

const {
  set,
} = Ember

export default Ember.Route.extend(AuthenticatedRouteMixin, {
  model() {
    return this.store.findAll('rental');
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'rentals', model);
  },
});
```

Another step will be generating `rentals/new` route where the actual creation of the rental is going to happen:

```
ember g route rentals/new
```


What we need to put in this route is the logic responsible for creating a new rental and some **route action** that is going to persist the rental and then transition back to `admin` route on success. Here is the route:


```{.javascript .numberLines}
// book-me/app/routes/rentals/new.js
import Ember from 'ember';

const {
  set,
} = Ember

export default Ember.Route.extend({
  model() {
    return this.store.createRecord('rental')
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'rental', model);
  },

  actions: {
    createRental(rental) {
      rental.save().then(() => {
        this.transitionTo('admin');
      });
    },
  },
});
```

And the last missing piece - the template:


```{.html .numberLines}
<!-- book-me/app/templates/rentals/new.hbs -->
<h2>Create a new rental</h2>

<form {{action (route-action "createRental" rental) on="submit"}}>
  <div class="form-group">
    <label for="rental-name">Name</label>
    {{input
      data-test-rental-name
      id="rental-name"
      value=(mut rental.name)
      class="form-control"
    }}
  </div>
  <div class="form-group">
    <label for="rental-dailyRate">Daily Rate</label>
    {{input
      data-test-rental-daily-rate
      id="rental-daily-rate"
      value=(mut rental.dailyRate)
      class="form-control"
      type="integer"
    }}
  </div>
  <button type="submit" class="btn btn-primary" data-test-create-rental>Create rental</button>
</form>
```

Back to green tests again!

Let's cover the "U" part of the CRUD now, which is updating the rentals. This should be quite straightforward - we just need to add some `edit` route, where the updating will happen. Again, we are going to start with a test by extending the last scenario:

```{.javascript .numberLines}
// book-me/tests/acceptance/rentals-crud-test.js
/* global server */
import { test } from 'qunit';
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import testSelector from 'ember-test-selectors';
import { authenticateSession, } from 'book-me/tests/helpers/ember-simple-auth';
import PageObject, {
  clickable,
  fillable,
  visitable
} from 'book-me/tests/page-object';

moduleForAcceptance('Acceptance | rentals crud');

test('it is possible to read, create, edit and delete rentals', function(assert) {
  assert.expect(5);

  const page = PageObject.create({
    visitAdmin: visitable('/admin'),
    goToNewRental: clickable(testSelector('add-rental')),
    rentalName: fillable(testSelector('rental-name')),
    rentalDailyRate: fillable(testSelector('rental-daily-rate')),
    createRental: clickable(testSelector('create-rental')),
    goToEditRental: clickable(testSelector('edit-rental')),
    updateRental: clickable(testSelector('update-rental')),
  });

  const user = server.create('user');
  authenticateSession(this.application, { user_id: user.id });

  page.visitAdmin();

  andThen(() => {
    assert.notOk(find(testSelector('rental-row')).length,
      'no rentals should be visible');
  });

  const name = 'Rental 1';
  const dailyRate = 100;

  server.post('/rentals', function(schema) {
    const attributes = this.normalizedRequestAttrs();
    const expectedAttributes = { name, dailyRate };

    assert.deepEqual(attributes, expectedAttributes,
      "attributes don't match the expected ones");

    return schema.rentals.create(attributes);
  });

  page
    .goToNewRental()
    .rentalName(name)
    .rentalDailyRate(dailyRate)
    .createRental();

  andThen(() => {
    assert.ok(find(testSelector('rental-row')).length, 'a new rental should be visible');
  });

  const updatedDailyRate = 200;

  server.patch('/rentals/:id', function({ rentals }, request) {
    const id = request.params.id;
    const attributes = this.normalizedRequestAttrs();
    const expectedAttributes = { id, name, dailyRate: updatedDailyRate };

    assert.deepEqual(attributes, expectedAttributes,
      "attributes don't match the expected ones");

    return rentals.find(id).update(attributes);
  });

  page
    .goToEditRental()
    .rentalDailyRate(updatedDailyRate)
    .updateRental();

  andThen(() => {
    assert.equal(currentPath(), 'admin', 'user should be redirected to admin page');
  });
});
```

Let's make the tests green again. We will start with generating new routes:

```
ember g route rental
ember g route rental/edit
```

And do the proper adjustments in the router:


```{.javascript .numberLines}
// book-me/app/router.js
import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('signup')
  this.route('login');
  this.route('admin');

  this.route('rentals', function() {
    this.route('new');

    this.route('rental', { path: '/rentals/:rental_id' }, function() {
      this.route('edit');
    });
  });
});

export default Router;
```

Let's add the edit link in `admin` template:

```{.html .numberLines}
<!-- book-me/app/templates/admin.hbs -->
<h2>Admin</h2>

{{#link-to 'rentals.new' data-test-add-rental class='btn btn-primary'}}
  Add rental
{{/link-to}}

<table class='table table-border'>
  <thead>
    <tr>
      <th>Name</th>
      <th>Daily Rate</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    {{#each rentals as |rental|}}
      <tr data-test-rental-row>
        <td>{{rental.name}}</td>
        <td>{{rental.dailyRate}}</td>
        <td>
          {{#link-to 'rental.edit' rental data-test-edit-rental class='btn btn-primary'}}
            Edit
          {{/link-to}}
        </td>
      </tr>
    {{/each}}
  </tbody>
</table>
```

Now need to handle two routes: `rental` and `edit`. The former will be responsible for finding a proper rental by id, and the latter will contain the logic related to editing rentals. Here's the code for both the `rental` route and the template:

```{.javascript .numberLines}
// book-me/app/routes/rental.js
import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.findRecord('rental', params.rental_id);
  },
});
```

```{.html .numberLines}
<!-- book-me/app/templates/rental.hbs -->
{{outlet}}
```

And here is for `edit` route:

```{.javascript .numberLines}
// book-me/app/routes/rental/edit.js
import Ember from 'ember';

const {
  set,
} = Ember

export default Ember.Route.extend({
  model(params) {
    return this.modelFor('rental');
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'rental', model);
  },

  actions: {
    updateRental(rental) {
      rental.save().then(() => {
        this.transitionTo('admin');
      });
    },
  },
});
```

```{.html .numberLines}
<!-- book-me/app/templates/rental/edit.hbs -->
<h2>Edit rental</h2>

<form {{action (route-action "updateRental" rental) on="submit"}}>
  <div class="form-group">
    <label for="rental-name">Name</label>
    {{input
      data-test-rental-name
      id="rental-name"
      value=(mut rental.name)
      class="form-control"
    }}
  </div>
  <div class="form-group">
    <label for="rental-dailyRate">Daily Rate</label>
    {{input
      data-test-rental-daily-rate
      id="rental-daily-rate"
      value=(mut rental.dailyRate)
      class="form-control"
      type="integer"
    }}
  </div>
  <button type="submit" class="btn btn-primary"
    data-test-update-rental>Edit Rental</button>
</form>
```

Now we are back to green again! All tests are passing.

Before moving to deleting rentals to finally finish the CRUD for rentals, we need to handle few more things.

One is that we have some duplications for handling creating and updating rentals as the logic and templates for both cases is pretty much the same. Also, it would be a good idea to add some validation, which makes it even harder argument for DRYing some code up here.

Another thing is that the new routes are not protected by the authentication requirement.

Let's handle those issues step by step.

The first step will be introducing changesets for both `create` and `update` actions. To avoid duplications, let's try first to unify `new.hbs` and `edit.hbs` templates under a new component - `rental-persistence-form`:

```
ember g component rental-persistence-form
```

The only difference between the `new` and `edit` templates are headers (which are not the parts of the form itself) and submit button. To keep things simple we can make a button configurable part from the outside - for that purpose we will take advantage of `yield` helper inside a component. To handle the actions on submit, we will generalize both `createRental` and `updateRental` actions to `persistRental` action.

The role of this action will be quite simple - it will just call the action that was passed to the component. Let's start with the component integration test:

```{.javascript .numberLines}
// book-me/tests/integration/components/rental-persistence-form-test.js
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

const {
  set,
} = Ember;

moduleForComponent('rental-persistence-form', 'Integration | Component |
  rental persistence form', {
  integration: true
});

test('it calls persistRental action when submitting form', function(assert) {
  assert.expect(1);

  const {
    $,
  } = this;
  const rental = Ember.Object.create({
    id: 1,
  });

  set(this, 'rental', rental);
  set(this, 'persistRental', (rentalArgument) => {
    assert.deepEqual(rentalArgument, rental,
      'persistRental action should be called with rental argument');
  });

  this.render(hbs`
    {{#rental-persistence-form rental=rental persistRental=persistRental}}
      "<button type='submit'>Submit</button>"
    {{/rental-persistence-form}}
  `);

  $('button').click();
});
```

The test is pretty simple - we just want to make sure that after submitting the form (which in this case is triggered by clicking the button that is configurable from the outside), the proper action will be called with the right arguments.

We can now make this new test pass. Here's the component's template:

```{.html .numberLines}
<!-- book-me/app/templates/components/rental-persistence-form.hbs -->
<form {{action "persistRental" on="submit"}}>
  <div class="form-group">
    <label for="rental-name">Name</label>
    {{input
      data-test-rental-name
      id="rental-name"
      value=(mut rental.name)
      class="form-control"
    }}
  </div>
  <div class="form-group">
    <label for="rental-dailyRate">Daily Rate</label>
    {{input
      data-test-rental-daily-rate
      id="rental-daily-rate"
      value=(mut rental.dailyRate)
      class="form-control"
      type="integer"
    }}
  </div>

  {{yield}}

</form>
```

And here's the component's body where we just handle `persistRental` action:

```{.javascript .numberLines}
// book-me/app/components/rental-persistence-form.js
import Ember from 'ember';

const {
  get,
} = Ember

export default Ember.Component.extend({
  actions: {
    persistRental() {
      const rental = get(this, 'rental');

      get(this, 'persistRental')(rental);
    },
  },
});
```

And the test is passing! Now we can easily refactor `edit.hbs` and `new.hbs`. Here is the former template after refactoring and using `rental-persistence-form` component:

```{.html .numberLines}
<!-- book-me/app/templates/rental/edit.hbs -->
<h2>Edit rental</h2>

{{#rental-persistence-form persistRental=(route-action "updateRental") rental=rental}}
  <button type="submit" class="btn btn-primary"
    data-test-update-rental>Edit Rental</button>
{{/rental-persistence-form}}
```

and here is the latter:

```{.html .numberLines}
<!-- book-me/app/templates/rental/edit.hbs -->
<h2>Create a new rental</h2>

{{#rental-persistence-form persistRental=(route-action "createRental") rental=rental}}
  <button type="submit" class="btn btn-primary"
    data-test-create-rental>Create rental</button>
{{/rental-persistence-form}}
```

Awesome, looks like we didn't break any tests.

Now that we've managed to unify both actions under one template, let's introduce changeset in the component:

```{.javascript .numberLines}
// book-me/app/components/rental-persistence-form.js
import Ember from 'ember';
import Changeset from 'ember-changeset';

const {
  get,
  set,
} = Ember

export default Ember.Component.extend({
  init() {
    this._super(...arguments);

    const rental = get(this, 'rental');
    const changeset = new Changeset(rental);

    set(this, 'changeset', changeset);
  },

  actions: {
    persistRental() {
      const changeset = get(this, 'changeset');

      get(this, 'persistRental')(changeset);
    },
  },
});
```

```{.html .numberLines}
<!-- book-me/app/templates/components/rental-persistence-form.hbs -->
<form {{action "persistRental" on="submit"}}>
  <div class="form-group">
    <label for="rental-name">Name</label>
    {{input
      data-test-rental-name
      id="rental-name"
      value=(mut changeset.name)
      class="form-control"
    }}
  </div>
  <div class="form-group">
    <label for="rental-dailyRate">Daily Rate</label>
    {{input
      data-test-rental-daily-rate
      id="rental-daily-rate"
      value=(mut changeset.dailyRate)
      class="form-control"
      type="integer"
    }}
  </div>

  {{yield}}

</form>
```

Introducing changeset was simple, but there is one problem though: our unit test for the component failed. But that's not a surprise - we are no longer passing there a "raw" rental but a changeset instead, so let's make the proper adjustments in the test:

```{.javascript .numberLines}
// book-me/tests/integration/components/rental-persistence-form-test.js
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

const {
  set,
} = Ember;

moduleForComponent('rental-persistence-form', 'Integration | Component |
  rental persistence form', {
  integration: true
});

test('it calls persistRental action when submitting form', function(assert) {
  assert.expect(1);

  const {
    $,
  } = this;
  const rental = Ember.Object.create({
    id: 1,
  });

  set(this, 'rental', rental);
  set(this, 'persistRental', (changeset) => {
    assert.deepEqual(changeset._content, rental,
      'persistRental action should be called with rental changset');
  });

  this.render(hbs`
    {{#rental-persistence-form rental=rental persistRental=persistRental}}
      "<button type='submit'>Submit</button>"
    {{/rental-persistence-form}}
  `);

  $('button').click();
});
```

And we are back to green again.

Another step will be introducing validations which will be the same for both `create` and `update` actions. We are going to take advantage of `ember-changeset-validations`, just like for the signup process:

```
ember generate validator rental
```

We want to make sure that `name` is a required attribute and that `dailyRate` is an integer and is greater than 0. Here are out tests for such requirements:

```{.javascript .numberLines}
// book-me/tests/unit/validators/rental-test.js
import { module, test } from 'qunit';
import validateRental from 'book-me/validators/rental';

module('Unit | Validator | rental');

test('it validates presence of name', function(assert) {
  assert.equal(validateRental.name('name', ''), "Name can't be blank");
  assert.ok(validateRental.name('name', 'Rental 1'));
});

test('it validates if dailyRate is an integer greater than 0', function(assert) {
  assert.equal(validateRental.dailyRate('dailyRate', null),
    'Daily rate must be a number');
  assert.equal(validateRental.dailyRate('dailyRate', 123.12),
    'Daily rate must be an integer');
  assert.ok(validateRental.dailyRate('dailyRate', 100));
});
```

The implementation is quite simple:

```{.javascript .numberLines}
// book-me/app/validators/rental.js
import {
  validatePresence,
  validateNumber
} from 'ember-changeset-validations/validators';

export default {
  name: validatePresence(true),
  dailyRate: validateNumber({ integer: true, gt: 0 }),
};
```

Now we need to integrate these validators with the changeset and the rest of the component. As you may have guessed already, we will start with the test checking that the errors are displayed when the form is submitted with invalid data and that the original `persistRental` action is not called. Here it is:

```{.javascript .numberLines}
// book-me/tests/integration/components/rental-persistence-form-test.js
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import testSelector from 'ember-test-selectors';

const {
  set,
} = Ember;

moduleForComponent('rental-persistence-form', 'Integration | Component |
  rental persistence form', {
  integration: true
});

test('it calls persistRental action when submitting form', function(assert) {
  assert.expect(1);

  const {
    $,
  } = this;
  const rental = Ember.Object.create({
    id: 1,
  });

  set(this, 'rental', rental);
  set(this, 'persistRental', (changeset) => {
    assert.deepEqual(changeset._content, rental,
      'persistRental action should be called with rental changset');
  });

  this.render(hbs`
    {{#rental-persistence-form rental=rental persistRental=persistRental}}
      "<button type='submit'>Submit</button>"
    {{/rental-persistence-form}}
  `);

  $('button').click();
});

// new test
test('it displays validation error when the data is invalid', function(assert) {
  assert.expect(2);

  const {
    $,
  } = this;
  const rental = Ember.Object.create();

  set(this, 'rental', rental);
  set(this, 'persistRental', () => {
    throw new Error('action should not be called');
  });

  this.render(hbs`
    {{#rental-persistence-form rental=rental persistRental=persistRental}}
      "<button type='submit' data-test-submit-btn>Submit</button>"
    {{/rental-persistence-form}}
  `);

  assert.notOk($(testSelector('rental-errors')).length,
    'errors should not initially be visible')

  $(testSelector('submit-btn')).click();

  assert.ok($(testSelector('rental-errors')).length,
    'errors should be visible when submitting form with invalid data');
});
```

To make it pass need to do the proper adjustments in the component:

```{.javascript .numberLines}
// book-me/app/components/rental-persistence-form.js
import Ember from 'ember';
import Changeset from 'ember-changeset';
import lookupValidator from 'ember-changeset-validations';
import RentalValidators from 'book-me/validators/rental';

const {
  get,
  set,
} = Ember

export default Ember.Component.extend({
  init() {
    this._super(...arguments);

    const rental = get(this, 'rental');
    const changeset = new Changeset(rental, lookupValidator(RentalValidators),
      RentalValidators);

    set(this, 'changeset', changeset);
  },

  actions: {
    persistRental() {
      const changeset = get(this, 'changeset');

      changeset.validate().then(() => {
        if (get(changeset, 'isValid')) {
          get(this, 'persistRental')(changeset);
        }
      });
    },
  },
});
```

and in the template:

```{.html .numberLines}
<!-- book-me/app/templates/components/rental-persistence-form.hbs -->
{{#if changeset.isInvalid}}
  <section data-test-rental-errors>
    {{#each changeset.errors as |error|}}
      <div class="alert alert-danger" role="alert">
        {{error.validation}}
      </div>
    {{/each}}
  </section>
{{/if}}

<form {{action "persistRental" on="submit"}}>
  <div class="form-group">
    <label for="rental-name">Name</label>
    {{input
      data-test-rental-name
      id="rental-name"
      value=(mut changeset.name)
      class="form-control"
    }}
  </div>
  <div class="form-group">
    <label for="rental-dailyRate">Daily Rate</label>
    {{input
      data-test-rental-daily-rate
      id="rental-daily-rate"
      value=(mut changeset.dailyRate)
      class="form-control"
      type="integer"
    }}
  </div>

  {{yield}}

</form>
```

So now we should be back to green, right?

Well, not exactly. Our new test is passing, but the previous test is not! But that makes sense - we don't currently fill any input with any data there, so the fact that it's failing is just a sign of a good test suite. Let's do the adjustments there and make this test pass:

```{.javascript .numberLines}
// book-me/tests/integration/components/rental-persistence-form-test.js
test('it calls persistRental action when submitting form when the data
  is valid', function(assert) {
  assert.expect(1);

  const {
    $,
  } = this;
  const rental = Ember.Object.create({
    id: 1,
  });

  set(this, 'rental', rental);
  set(this, 'persistRental', (changeset) => {
    assert.deepEqual(changeset._content, rental,
      'persistRental action should be called with rental changset');
  });

  this.render(hbs`
    {{#rental-persistence-form rental=rental persistRental=persistRental}}
      "<button type='submit' data-test-submit-btn>Submit</button>"
    {{/rental-persistence-form}}
  `);

  $(testSelector('rental-name')).val('Rental 1').change();
  $(testSelector('rental-daily-rate')).val(100).change();

  $(testSelector('submit-btn')).click();
});
```

And we are back to green!

What about server-side errors? Ideally, the UI validations would cover all the possible cases, but sometimes it is not feasible to do it perfectly (e.g., uniqueness validation) or some use case might be just overlooked, so it's always a good idea to handle error messages coming from the server.

The natural way to handle it is to start with the tests. But the questions is - on what level? In this case it would be ideally acceptance test as multiple layers are going to be involved and checking if the errors are displayed in the UI is the safest way to  verify it, but on the other hand those tests are much slower than unit tests, which would be the alternative here to acceptance tests as we could just handle it by testing route actions. The extra benefit of the unit tests here is that we could test for details in isolation.

To make it simpler let's write both unit and acceptance tests to get an idea how it may look like and later decide which way is better. We will start with acceptance tests.

Before writing new tests as the part of `Rentals CRUD` scenario, let's move the authentication logic to `beforeEach` hook and extract **page object** so that we make the tests more DRY and page object reusable in all scenarios.

Let's generate `rentals` page:

```
ember generate page-object rentals
```

And move the logic there from `rentals-crud-test.js` test:

```{.javascript .numberLines}
// book-me/tests/pages/rentals.js
import {
  create,
  clickable,
  fillable,
  visitable,
} from 'ember-cli-page-object';
import testSelector from 'ember-test-selectors';

export default create({
  visitAdmin: visitable('/admin'),
  goToNewRental: clickable(testSelector('add-rental')),
  rentalName: fillable(testSelector('rental-name')),
  rentalDailyRate: fillable(testSelector('rental-daily-rate')),
  createRental: clickable(testSelector('create-rental')),
  goToEditRental: clickable(testSelector('edit-rental')),
  updateRental: clickable(testSelector('update-rental')),
});
```

And here is our test file after refactoring:

```{.javascript .numberLines}
// book-me/tests/acceptance/rentals-crud-test.js
/* global server */
import { test } from 'qunit';
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import testSelector from 'ember-test-selectors';
import { authenticateSession, } from 'book-me/tests/helpers/ember-simple-auth';
import page from 'book-me/tests/pages/rentals';

moduleForAcceptance('Acceptance | rentals crud', {
  beforeEach() {
    const user = server.create('user');
    authenticateSession(this.application, { user_id: user.id });
  },
});

test('it is possible to read, create, edit and delete rentals', function(assert) {
  assert.expect(5);

  page.visitAdmin();

  andThen(() => {
    assert.notOk(find(testSelector('rental-row')).length,
      'no rentals should be visible');
  });

  const name = 'Rental 1';
  const dailyRate = 100;

  server.post('/rentals', function(schema) {
    const attributes = this.normalizedRequestAttrs();
    const expectedAttributes = { name, dailyRate };

    assert.deepEqual(attributes, expectedAttributes,
      "attributes don't match the expected ones");

    return schema.rentals.create(attributes);
  });

  page
    .goToNewRental()
    .rentalName(name)
    .rentalDailyRate(dailyRate)
    .createRental();

  andThen(() => {
    assert.ok(find(testSelector('rental-row')).length,
      'a new rental should be visible');
  });

  const updatedDailyRate = 200;

  server.patch('/rentals/:id', function({ rentals }, request) {
    const id = request.params.id;
    const attributes = this.normalizedRequestAttrs();
    const expectedAttributes = { id, name, dailyRate: updatedDailyRate };

    assert.deepEqual(attributes, expectedAttributes, "attributes don't match the expected ones");

    return rentals.find(id).update(attributes);
  });

  page
    .goToEditRental()
    .rentalDailyRate(updatedDailyRate)
    .updateRental();

  andThen(() => {
    assert.equal(currentPath(), 'admin', 'user should be redirected to admin page');
  });
});
```

All tests are still passing, so we managed to not break anything. Let's write two new tests: one for handling server-side error messages when creating a new rental and one for updating a rental. The idea is simple - we want to make sure the error messages are displayed, even when passing the client-side validations. Here are our two tests:

```{.javascript .numberLines}
// book-me/tests/acceptance/rentals-crud-test.js
// new import
import Mirage from 'ember-cli-mirage';

const {
  Response,
} = Mirage;

// 2 new tests:
test('it displays server-side validation errors when creating new rental',
  function(assert) {
  assert.expect(2);

  server.post('/rentals', () => {
    const errors = {
      errors: [
        {
          detail: 'is already taken',
          source: {
            pointer: 'data/attributes/name'
          }
        }
      ]
    };
    return new Response(422, {}, errors);
  });

  page
    .visitAdmin()
    .goToNewRental()
    .rentalName('name')
    .rentalDailyRate(100)
    .createRental();

  andThen(() => {
    assert.equal(currentPath(), 'rentals.new', 'user should stay on new rental page');
    assert.ok(find(testSelector('rental-errors')).length,
      'errors should be visible when submitting form with invalid data');
  });
});

test('it displays server-side validation errors when updating rental',
  function(assert) {
  assert.expect(2);

  server.create('rental', { name: 'name', dailyRate: 20 });

  server.patch('/rentals/:id', () => {
    const errors = {
      errors: [
        {
          detail: 'is already taken',
          source: {
            pointer: 'data/attributes/name'
          }
        }
      ]
    };
    return new Response(422, {}, errors);
  });

  page
    .visitAdmin()
    .goToEditRental()
    .rentalName('updated name')
    .rentalDailyRate(100)
    .updateRental();

  andThen(() => {
    assert.equal(currentPath(), 'rental.edit',
      'user should stay on edit rental page');
    assert.ok(find(testSelector('rental-errors')).length,
      'errors should be visible when submitting form with invalid data');
  });
});
```

Although first part of our tests is fine - we verified that we won't be redirected to `admin` route, the second part, checking if validation errors are displayed, is failing which is a very good thing as seeing this part fail is the way to verify that we are not confusing client-side errors with server-side errors.

To make these tests pass we just need to copy validation errors from model's errors to changeset in `edit` and `new` routes. We need to keep in mind that the formatted validation message that we display in a component comes from error's `validation`  property, so it's essential to populate this attribute:

```{.javascript .numberLines}
// book-me/app/routes/rentals/new.js
import Ember from 'ember';

const {
  get,
  set,
} = Ember

export default Ember.Route.extend({
  model() {
    return this.store.createRecord('rental')
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'rental', model);
  },

  actions: {
    createRental(changeset) {
      changeset.save().then(() => {
        this.transitionTo('admin');
      }).catch(() => {
        const errors = get(changeset._content, 'errors')

        errors.forEach(error => {
          const key = error.attribute;
          const message = error.message;

          changeset.addError(key, { validation: `${key} ${message}` });
        });
      });
    },
  },
});
```

```{.javascript .numberLines}
// book-me/app/routes/rental/edit.js
import Ember from 'ember';

const {
  get,
  set,
} = Ember

export default Ember.Route.extend({
  model() {
    return this.modelFor('rental');
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'rental', model);
  },

  actions: {
    updateRental(changeset) {
      changeset.save().then(() => {
        this.transitionTo('admin');
      }).catch(() => {
        const errors = get(changeset._content, 'errors')

        errors.forEach(error => {
          const key = error.attribute;
          const message = error.message;

          changeset.addError(key, { validation: `${key} ${message}` });
        });
      });
    },
  },
});
```

And we are back to green tests again! Let's cover the same use case with unit tests for route actions. As both `edit` and `new` routes are almost the same, the tests won't differ that much. The idea is simple: we just need to check if the changeset errors are indeed populated with model errors when the `save` fails (i.e., when the promise is rejected).

Here's how we can approach it:

```{.javascript .numberLines}
// book-me/tests/unit/routes/rentals/new-test.js
import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';
import Changeset from 'ember-changeset';

const {
  get,
  RSVP,
  run,
} = Ember

moduleFor('route:rentals/new', 'Unit | Route | rentals/new', {
});

test('changeset gets populated with model errors in `createRental` action
  when there is an error on backend', function(assert) {
  assert.expect(2)

  const route = this.subject();
  const createRental = route.actions.createRental;

  const errors = [
    {
      attribute: 'name',
      message: 'is invalid',
    }
  ];
  const rentalStub = Ember.Object.extend({
    save() {
      return RSVP.reject();
    },
  }).create({ errors });
  const changeset = new Changeset(rentalStub);

  run(createRental.bind(route, changeset));

  assert.ok(get(changeset, 'isInvalid'), 'changeset should be invalid');

  const expectedErrors = [
    {
      key: 'name',
      validation: 'name is invalid',
    }
  ];
  assert.deepEqual(get(changeset, 'errors'), expectedErrors,
    'changeset should be populated with errors');
});
```

```{.javascript .numberLines}
// book-me/tests/unit/routes/rental/edit-test.js
import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';
import Changeset from 'ember-changeset';

const {
  get,
  RSVP,
  run,
} = Ember

moduleFor('route:rental/edit', 'Unit | Route | rental/edit', {
});

test('changeset gets populated with model errors in `updateRental`
  action when there is an error on backend', function(assert) {
  assert.expect(2)

  const route = this.subject();
  const updateRental = route.actions.updateRental;

  const errors = [
    {
      attribute: 'name',
      message: 'is invalid',
    }
  ];
  const rentalStub = Ember.Object.extend({
    save() {
      return RSVP.reject();
    },
  }).create({ errors });
  const changeset = new Changeset(rentalStub);

  run(updateRental.bind(route, changeset));

  assert.ok(get(changeset, 'isInvalid'), 'changeset should be invalid');

  const expectedErrors = [
    {
      key: 'name',
      validation: 'name is invalid',
    }
  ];
  assert.deepEqual(get(changeset, 'errors'), expectedErrors,
    'changeset should be populated with errors');
});
```

There are some interesting patterns used in those two examples. To grab a specific action from a route, we can access its `actions` property and then fetch the action we need. Another step is creating a rental stub with a `save` method that merely returns rejected promise, which is exactly what we need to handle the error flow. We also populate rental stub with some `errors` messages. Then, we run the actual action in `Ember.run`, which is quite important here as we are dealing with promises and that way we will make sure that the assertions are not being run before the promise is fulfilled. To make sure `this` will be the expected context in the action when running tests, we need to take advantage of `bind` and pass the actual `route` as the first argument; otherwise, everything that calls `this` in the route action will fail. The last thing is the assertions - we obviously want to make sure the changeset is invalid and that it contains the proper validation messages.

Before moving to deleting rentals, we have one more thing to handle - making sure `edit` and `new` routes require authentication.

Adding acceptance tests to cover those cases might be too heavy. Ideally, we would cover this case with unit tests.

The best way to handle this case will be to check if `AuthenticatedRouteMixin` is included. After a quick look at the [mixin](https://github.com/simplabs/ember-simple-auth/blob/1.4.0/addon/mixins/authenticated-route-mixin.js#L80), we can see that `beforeModel` hook uses `session` service and its `isAuthenticated` property to check if we are authenticated or not. To make sure the routes are protected, we can just make sure that this property is called when executing `beforeModel` hook. Here are the tests:

```{.javascript .numberLines}
// book-me/tests/unit/routes/rentals/new-test.js
import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';
import Changeset from 'ember-changeset';

const {
  get,
  RSVP,
  run,
  computed,
} = Ember

moduleFor('route:rentals/new', 'Unit | Route | rentals/new', {
});

test('it requires authentication', function(assert) {
  assert.expect(1);

  const sessionStub = Ember.Service.extend({
    isAuthenticated: computed(() => {
      assert.ok(true, 'isAuthenticated has to be used for checking authentication');

      return true;
    }),
  });

  this.register('service:session', sessionStub);
  this.inject.service('session');

  const route = this.subject();

  route.beforeModel();
});
```

```{.javascript .numberLines}
// book-me/tests/unit/routes/rental/edit-test.js
import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';
import Changeset from 'ember-changeset';

const {
  get,
  RSVP,
  run,
  computed,
} = Ember

moduleFor('route:rental/edit', 'Unit | Route | rental/edit', {
});

test('it requires authentication', function(assert) {
  assert.expect(1);

  const sessionStub = Ember.Service.extend({
    isAuthenticated: computed(() => {
      assert.ok(true, 'isAuthenticated has to be used for checking authentication');

      return true;
    }),
  });

  this.register('service:session', sessionStub);
  this.inject.service('session');

  const route = this.subject();

  route.beforeModel();
});
```

The interesting thing here is that we are providing a session stub instead of using a real service with `isAuthenticated` computed property where we are making assertion just to make sure this property is called. Next, we register the stub as `service:session` and inject the service. In the end, we are just calling `beforeModel()` method. Thanks to `assert.expect(1)`, such test is enough here - if `isAuthenticated` property doesn't get called, it will fail.

And here is the implementation to make those tests pass:

```{.javascript .numberLines}
// book-me/app/routes/new.js
import Ember from 'ember';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

const {
  get,
  set,
} = Ember

export default Ember.Route.extend(AuthenticatedRouteMixin, {
	// the rest of the code
});
```

```{.javascript .numberLines}
// book-me/app/routes/new.js
import Ember from 'ember';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

const {
  get,
  set,
} = Ember

export default Ember.Route.extend(AuthenticatedRouteMixin, {
	// the rest of the code
});
```

```{.javascript .numberLines}
// book-me/app/routes/edit.js
import Ember from 'ember';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

const {
  get,
  set,
} = Ember

export default Ember.Route.extend(AuthenticatedRouteMixin, {
  	// the rest of the code
});
```

But not the all tests are green! Apparently, we've just broken the tests for route actions, and we are getting `Attempting to inject an unknown injection: 'service:session'` error. To fix this, we just need to take advantage of `needs` property and provide the missing dependencies:

```{.javascript .numberLines}
// book-me/tests/unit/routes/rental/edit-test.js
moduleFor('route:rental/edit', 'Unit | Route | rental/edit', {
  needs: ['service:session'],
});
```

```{.javascript .numberLines}
// book-me/tests/unit/routes/rentals/new-test.js
moduleFor('route:rentals/new', 'Unit | Route | rentals/new', {
  needs: ['service:session'],
});
```

Now we are back to green; all tests are passing.

Now, it's time for the final part of Rentals' CRUD - adding a possibility to delete rentals.

When adding a delete button, it's worth keeping in mind some usability aspects and providing good UX - it's quite easy to accidentally click on the button and remove something that was not supposed to be removed.

One easy solution is to possibly display a confirmation alert and make user users confirm the action before deleting anything. That would certainly get the job done, but it's not that pretty from the UX perspective. Fortunately, we can do much better than this, and it is quite simple to implement - we could just make the user hold a button for a particular period, e.g., 3 seconds and only after 3 seconds will the rental be deleted. Holding it for a shorter period would not have any effect.

Apparently, we are quite lucky since there is already some addon that provides such solution - [ember-hold-button](https://www.npmjs.com/package/ember-hold-button).

We can now write an acceptance tests. What we want to test is that after holding the button, rental will no longer be in the UI and that `DELETE` request will be performed to `rentals/:id` endpoint. Here's the test:

```{.javascript .numberLines}
// book-me/tests/acceptance/rentals-crud-test.js
/* global server */
import { test } from 'qunit';
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import testSelector from 'ember-test-selectors';
import { authenticateSession, } from 'book-me/tests/helpers/ember-simple-auth';
import page from 'book-me/tests/pages/rentals';
import Mirage from 'ember-cli-mirage';

const {
  Response,
} = Mirage;

moduleForAcceptance('Acceptance | rentals crud', {
  beforeEach() {
    const user = server.create('user');
    authenticateSession(this.application, { user_id: user.id });
  },
});

test('it is possible to read, create, edit and delete rentals', function(assert) {
  assert.expect(7);

  page.visitAdmin();

  andThen(() => {
    assert.notOk(find(testSelector('rental-row')).length,
      'no rentals should be visible');
  });

  const name = 'Rental 1';
  const dailyRate = 100;

  server.post('/rentals', function(schema) {
    const attributes = this.normalizedRequestAttrs();
    const expectedAttributes = { name, dailyRate };

    assert.deepEqual(attributes, expectedAttributes,
      "attributes don't match the expected ones");

    return schema.rentals.create(attributes);
  });

  page
    .goToNewRental()
    .rentalName(name)
    .rentalDailyRate(dailyRate)
    .createRental();

  andThen(() => {
    assert.ok(find(testSelector('rental-row')).length,
      'a new rental should be visible');
  });

  const updatedDailyRate = 200;

  server.patch('/rentals/:id', function({ rentals }, request) {
    const id = request.params.id;
    const attributes = this.normalizedRequestAttrs();
    const expectedAttributes = { id, name, dailyRate: updatedDailyRate };

    assert.deepEqual(attributes, expectedAttributes,
      "attributes don't match the expected ones");

    return rentals.find(id).update(attributes);
  });

  page
    .goToEditRental()
    .rentalDailyRate(updatedDailyRate)
    .updateRental();

  andThen(() => {
    assert.equal(currentPath(), 'admin', 'user should be redirected to admin page');
  });

  // new stuff for testing deleting the rentals

  server.del('/rentals/:id', function({ rentals }, request) {
    const id = request.params.id;

    assert.ok(true, 'rental should be destroyed')

    rentals.find(id).destroy();
  });

  page.deleteRental(); // not implemented yet

  andThen(() => {
    assert.notOk(find(testSelector('rental-row')).length,
      'no rentals should be visible');
  });
});
```

The next step will be implementing `deleteRental` on Rentals page object. But how should we handle the interaction with the button? Obviously, it's not just a simple click.

To solve that problem we should break the problem down into the single events. On a non-mobile device, pressing a button means triggering **mouseDown** event and releasing means triggering **mouseUp** event. On mobile that would be **touchStart** and **touchEnd** events accordingly.

Based on how [**hold-button**](https://www.npmjs.com/package/ember-hold-button) component works, we may suspect that there is some internal timer which starts counting time after triggering **mouseDown** (**touchStart**) event or a scheduler which executes the action if it was held for required amount of time and cancels it if it was released before that period, which would mean cancelling timer on **mouseUp** event.

After checking the [internals](https://github.com/AddJam/ember-hold-button/blob/master/addon/components/hold-button.js) of the addon, it turns out this is exactly the case! We don't have to care about **mouseUp** part; we just need to make sure that `mouseDown` event is triggered on the button. Fortunately, it is quite easy to achieve with `ember-cli-page-object` - we just need to take advantage of `triggerable` helper. Here's how our page object is going to look like now:

```{.javascript .numberLines}
// book-me/tests/pages/rentals.js
import {
  create,
  clickable,
  fillable,
  visitable,
  triggerable,
} from 'ember-cli-page-object';
import testSelector from 'ember-test-selectors';

export default create({
  visitAdmin: visitable('/admin'),
  goToNewRental: clickable(testSelector('add-rental')),
  rentalName: fillable(testSelector('rental-name')),
  rentalDailyRate: fillable(testSelector('rental-daily-rate')),
  createRental: clickable(testSelector('create-rental')),
  goToEditRental: clickable(testSelector('edit-rental')),
  updateRental: clickable(testSelector('update-rental')),
  deleteRental: triggerable('mousedown', testSelector('delete-rental')),
});
```

Now that we see the new scenario failing let's move to the actual implementation. We will start with installing the addon:

```
ember install ember-hold-button
```

We need to add the button to `admin.hbs` template and implement a route action, let's call it `delete-rental`, that will be responsible for deleting rentals. Here's the template:

``` {.html .numberLines}
<!-- book-me/app/templates/admin.hbs -->
<h2>Admin</h2>

{{#link-to 'rentals.new' data-test-add-rental class='btn btn-primary'}}
  Add rental
{{/link-to}}

<table class='table table-border'>
  <thead>
    <tr>
      <th>Name</th>
      <th>Daily Rate</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    {{#each rentals as |rental|}}
      <tr data-test-rental-row>
        <td>{{rental.name}}</td>
        <td>{{rental.dailyRate}}</td>
        <td>
          {{#link-to 'rental.edit' rental data-test-edit-rental class='btn btn-primary'}}
            Edit
          {{/link-to}}

          {{#hold-button action=(route-action 'deleteRental' rental) delay=3000
            class='btn' data-test-delete-rental=rental.id}}
            Delete
          {{/hold-button}}
        </td>
      </tr>
    {{/each}}
  </tbody>
</table>
```

Holding the button for 3 seconds will trigger `deleteRental` action. Here is its implementation in `admin` route:

```{.javascript .numberLines}
// book-me/app/routes/admin.js
import Ember from 'ember';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

const {
  set,
} = Ember

export default Ember.Route.extend(AuthenticatedRouteMixin, {
  model() {
    return this.store.findAll('rental');
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'rentals', model);
  },

  actions: {
    deleteRental(rental) {
      rental.destroyRecord();
    },
  },
});
```

And again, all tests are passing! We've managed to implement the full CRUD TDD-style. However, there are a couple of things that be improved.

The first one is that we may want to delete rental in multiple places later, not only in `admin`. In such case, we may want to have the entire process of deleting rental encapsulated in a component that would be exclusively responsible for deleting rentals. Also, that would be a good use case to learn how to test such logic in a component integration test ;).

Another thing is that holding a button for 3 seconds in test suite makes it last 3 seconds longer, which is quite long. Ideally, we would have some kind of helper that in the non-test environment would return the "real" delay time and in the test environment, it would return `0` to make it possibly fast.

We will certainly need to get back to that issue but for now, let's focus now on a component that we will call `delete-rental-button`:

```
ember g component delete-rental-button
```

As you may have already guessed, we will start with the integration test. The idea is simple: we need to make sure that after holding a button for a certain time the rental will get deleted. The test itself is not that obvious, however:

```{.javascript .numberLines}
// book-me/tests/integration/components/delete-rental-button-test.js
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import testSelector from 'ember-test-selectors';
import wait from 'ember-test-helpers/wait';

const {
  set,
  RSVP,
} = Ember;

moduleForComponent('delete-rental-button', 'Integration | Component |
  delete rental button', {
  integration: true
});

test('it deletes rental by holding a button', function(assert) {
  assert.expect(1);

  const {
    $,
  } = this;

  const rentalStub = Ember.Object.extend({
    destroyRecord() {
      assert.ok(true, 'item should be destroyed');

      return RSVP.resolve(this);
    },
  }).create({ id: 1 });

  set(this, 'rental', rentalStub);

  this.render(hbs`{{delete-rental-button rental=rental}}`);

  const $deleteBtn = $(testSelector('delete-rental'));
  const done = assert.async();

  $deleteBtn.mousedown();

  wait().then(() => {
    done();
  });
});
```

Even though there is only one assertion, there are few interesting things going on in the test. The beginning is quite simple - we create a rental stub and define `destroyRecord` method where we do the actual assertion that this method was called and we render the component and find `deleteBtn`, that is simple. But then we are using `async() / done()` functions, triggering `mouseDown` event on the button and using `wait()` helper. What are the purposes of those functions?

* `async()/done()` – To make sure QUnit will wait for an asynchronous operation to be finished, we need to use `async()` function. That way QUnit will wait until `done()` is called.

* `wait()` – it forces run loop to process all the pending events. That way we ensure that the asynchronous operation has been executed (like calling `deleteRental` action after 3 seconds. When all the events have been processed, we can call `done()`.

It might sound a bit complex, but after writing several of such tests, such flow becomes quite simple and obvious.

Here's the implementation of the component:

```{.javascript .numberLines}
// book-me/app/components/delete-rental-button.js
import Ember from 'ember';

const {
  get,
} = Ember;

export default Ember.Component.extend({
  delay: 3000,

  actions: {
    deleteRental() {
      const rental = get(this, 'rental');

      rental.destroyRecord();
    },
  },
});
```

and its body:

```{.html .numberLines}
<!--book-me/app/templates/components/delete-rental-button.hbs -->
{{#hold-button action="deleteRental" delay=delay class='btn'
  data-test-delete-rental=rental.id}}
  Delete
{{/hold-button}}
```

And that way we managed to get the component's test to pass. Now, let's get back to the idea of making the tests faster:

We will implement a utility function called `resolveDelay`. We are going to start with a test checking that whatever value we pass, we will get `0` as a result. Since the behavior is going to be environment-dependent, there is not much we can do for testing it for other environments, so it might be worth testing in UI via the real interaction in such case.

Here's the test:

```{.javascript .numberLines}
// book-me/tests/unit/utilities/resolve-delay-test.js
import resolveDelay from 'book-me/utilities/resolve-delay';
import { module, test } from 'qunit';

module('Unit | Utility | resolve delay');

test('it returns 0 for every value in test env', function(assert) {
  assert.equal(resolveDelay(42), 0);
  assert.equal(resolveDelay(0), 0);
  assert.equal(resolveDelay(3000), 0);
});
```

And here's the implementation:

```{.javascript .numberLines}
// book-me/app/utilities/resolve-delay.js
import config from 'book-me/config/environment';

export default function resolveDelay(delay) {
  if (config.environment === 'test') {
    return 0;
  } else {
    return delay;
  }
}
```
We can apply it now in our `delete-rental-button` component:

```{.javascript .numberLines}
// book-me/app/components/delete-rental-button.js
import Ember from 'ember';
import resolveDelay from 'book-me/utilities/resolve-delay';

const {
  get,
} = Ember;

export default Ember.Component.extend({
  delay: resolveDelay(3000),

  actions: {
    deleteRental() {
      const rental = get(this, 'rental');

      rental.destroyRecord();
    },
  },
});
```

All tests are still passing so nothing got broken. We can now modify `admin.hbs` template and take advantage of `delete-rental-button` component:

```{.html .numberLines}
<!--book-me/app/templates/admin.hbs -->
<h2>Admin</h2>

{{#link-to 'rentals.new' data-test-add-rental class='btn btn-primary'}}
  Add rental
{{/link-to}}

<table class='table table-border'>
  <thead>
    <tr>
      <th>Name</th>
      <th>Daily Rate</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    {{#each rentals as |rental|}}
      <tr data-test-rental-row>
        <td>{{rental.name}}</td>
        <td>{{rental.dailyRate}}</td>
        <td>
          {{#link-to 'rental.edit' rental data-test-edit-rental class='btn btn-primary'}}
            Edit
          {{/link-to}}

          {{delete-rental-button rental=rental}}
        </td>
      </tr>
    {{/each}}
  </tbody>
</table>
```

And our test suite has just become much faster ;). We can also remove the route action since it's not used anymore:

```{.javascript .numberLines}
// book-me/app/routes/admin.js
import Ember from 'ember';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

const {
  set,
} = Ember

export default Ember.Route.extend(AuthenticatedRouteMixin, {
  model() {
    return this.store.findAll('rental');
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'rentals', model);
  },
});
```

As the last improvement, let's display some notification when the rental gets deleted, which would bring more pleasant UX. There is a great addon that will be very helpful here called [**ember-notify**](https://github.com/aexmachina/ember-notify), let's install it:

```
ember install ember-notify
```

The setup is quite straightforward, we just need to display `ember-notify` component in `application.hbs` template:

```{.html .numberLines}
<!-- book-me/app/templates/application.hbs -->
<nav class="navbar navbar-default navbar-fixed-top" role="navigation">
  <div class="container-fluid">
    <div class="navbar-header">
      <button type="button" class="navbar-toggle navbar-toggle-context"
              data-toggle="collapse" data-target=".navbar-top-collapse">
        <span class="sr-only">Toggle Navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <div class="navbar-brand-container">
        <span class="navbar-brand">
          <h1><i class="fa fa-star"></i> Book Me!</h1>
        </span>
      </div>
    </div>
    <div class="collapse navbar-collapse navbar-top-collapse">
      <div class="navbar-right">
        {{#if session.isAuthenticated}}
          <a {{action (route-action 'logOut')}} data-test-logout-link
            class="btn btn-primary navbar-btn">Logout</a>
        {{else}}
          {{link-to "Sign up" "signup" data-test-signup-link
            class="btn btn-primary navbar-btn"}}
          {{link-to "Login" "login" data-test-login-link
            class="btn btn-primary navbar-btn"}}
        {{/if}}
      </div>
    </div>
  </div>
</nav>
<section class="main-content">
  <div class="sheet">
    {{outlet}}
  </div>
</section>

{{ember-notify messageStyle='bootstrap'}}
```

Writing acceptance tests checking if the notification is displayed would be too much - displaying a notification after a rental gets deleted is not a business-critical feature. It's much better to just check in the UI if the notifications are displayed nicely and then, only write integration or unit tests.

Since we want to display some notification after a rental gets deleted, let's extend the integration test for `delete-rental-button` component:

```{.javascript .numberLines}
// book-me/tests/integration/component/delete-rental-button-test.js
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import testSelector from 'ember-test-selectors';
import wait from 'ember-test-helpers/wait';

const {
  set,
  RSVP,
} = Ember;

moduleForComponent('delete-rental-button', 'Integration | Component |
  delete rental button', {
  integration: true
});

test('it deletes rental by holding a button', function(assert) {
  assert.expect(2);

  const {
    $,
  } = this;

  const notifyStub = Ember.Service.extend({
    info() {
      assert.ok(true, 'notification should be displayed');
    },
  });

  this.register('service:notify', notifyStub);
  this.inject.service('notify');

  const rentalStub = Ember.Object.extend({
    destroyRecord() {
      assert.ok(true, 'item should be destroyed');

      return RSVP.resolve(this);
    },
  }).create({ id: 1 });

  set(this, 'rental', rentalStub);

  this.render(hbs`{{delete-rental-button rental=rental}}`);

  const $deleteBtn = $(testSelector('delete-rental'));
  const done = assert.async();

  $deleteBtn.mousedown();

  wait().then(() => {
    done();
  });
});
```

We are creating a stub of the `notify` service where we do perform another assertion in `info` method to make sure it gets called; we are registering this service and injecting it. The implementation to make this test pass is going to be quite straightforward:

```{.javascript .numberLines}
// book-me/app/components/delete-rental-button.js
import Ember from 'ember';
import resolveDelay from 'book-me/utilities/resolve-delay';

const {
  get,
  inject,
} = Ember;

export default Ember.Component.extend({
  delay: resolveDelay(3000),
  notify: inject.service(),

  actions: {
    deleteRental() {
      const rental = get(this, 'rental');

      rental.destroyRecord().then(() => {
        const notify = get(this, 'notify');

        notify.info('Rental is deleted');
      });
    },
  },
});
```

And all tests are again green!

That would be all for rentals' CRUD. There are obviously few more things that could make a nice improvement - we could, for example, disable submit buttons until the changeset is valid, we could implement rollback / reset buttons or delete a rental from memory in `rentals/new` route when exiting the route without persisting the rental, but at this point I'm pretty sure you will be able to TDD those features without any problems :).

If you are curious about the visual side of the features we delivered, here are some screenshots:

![Create rental](http://download.karolgalanciak.com/test-driven-ember/book_me_03.png)

![Admin](http://download.karolgalanciak.com/test-driven-ember/book_me_04.png)

As you can see the `Delete` button doesn't look perfect, but TDD-ing CSS is outside of the scope of this book ;).

Let's move to the final and the most interesting feature we are going to implement: the calendar.

\pagebreak

### The Calendar

As already discussed earlier, we are going to take advantage of `ember-power-calendar`. Let's install this powerful addon now:

```
ember install ember-power-calendar
```

The addon comes also with some stylesheets. To make the calendars look better we can include them as well:

``` scss
/* book-me/app/styles/app.scss */
@import "ember-power-select";
@import "ember-modal-dialog/ember-modal-structure";
@import "bootstrap-bookingsync";
@import "ember-power-calendar";
```

However, before moving on to playing with a calendar, let's populate in-memory "database" for development to make the interaction with app better instead of creating all the rentals manually.

We will start with generating an ember-cli-mirage `rental factory`:

```
ember g mirage-factory rental
```

If we are already on generating factories, we may generate one for user model to be able to use the sign in right away when opening the app, without signing up in the first place to create a user:

```
ember g mirage-factory user
```

For rentals, we need to have some unique and random `name`s and some integer `daily rate`s. We will take advantage of sequence number which is an optional argument for attributes and use `faker` to generate random numbers for rates:


```{.javascript .numberLines}
// book-me/mirage/factories/rental.js
import { Factory, faker } from 'ember-cli-mirage';

export default Factory.extend({
  name(i) {
    return `Rental ${i}`;
  },

  dailyRate() {
    return faker.random.number();
  }
});
```

We are going to have a pretty similar setup for `user`s with unique `email`s and hardcoded `password`s, just to make it easier to sign in:

```{.javascript .numberLines}
// book-me/mirage/factories/user.js
import { Factory } from 'ember-cli-mirage';

export default Factory.extend({
  email(i) {
    return `example_${i}@gmail.com`;
  },

  password() {
    return `password123`;
  }
});
```

Since we want to have the rentals and users available right away during the development, let's seed the `database` with 10 `rental`s and one `user`:


```{.javascript .numberLines}
// book-me/mirage/scenarios/default.js
export default function(server) {
  server.createList('rental', 10);

  server.create('user', { email: 'email@example.com', password: 'password123' });
}
```

Now that we've made a helpful setup, we can focus on the calendar itself and what we want to do with it. There is one particularly interesting section in the docs of the addon about [range selection](http://www.ember-power-calendar.com/docs/range-selection) which is exactly what we need - the booking will have `beginsAt` and `finishesAt` attributes which can be easily populated from the selected range. To make it possible, we will just display a calendar in `rental/show` template where we will be able to select the dates for a new booking.

Another thing to consider is: what is going to happen next? We also need to provide input for `clientEmail` attribute. It would also be nice to display the actual length of stay for the booking and its price that is going to be calculated based on this length of stay and rental's `dailyRate` value.

To achieve all those things and to provide a nice UX, we are going to display a modal after selecting the range on a calendar with the form to fill other fields and display the required info.

An excellent choice for modals in Ember ecosystem is `ember-modal-dialog` which provides flexible API and is easy to use. And it's based on `ember-wormhole` addon, which has a pretty awesome name. Let's install the addon now:

```
ember install ember-modal-dialog
```

To make the UI nice we can also add some stylesheets provided by the addon:


``` scss
/* book-me/app/styles/app.scss */
@import "ember-power-select";
@import "ember-modal-dialog/ember-modal-structure";
@import "bootstrap-bookingsync";
@import "ember-power-calendar";
@import "ember-modal-dialog/ember-modal-structure";
@import "ember-modal-dialog/ember-modal-appearance";
```

Just like with every feature we've implemented so far, we are going to start with an acceptance test. Initially, we will keep it pretty simple: what we want to test is that we can go to admin page, click on the link to go to `rental/show` route, select same dates range on calendar, fill in `clientEmail`, click some button and verify that a new booking gets displayed and that it actually gets created by checking the outgoing request and its payload. Let's generate a new acceptance test:

```
ember g acceptance-test create-booking
```

The next step would be writing a test cover the just mentioned scenario:

```{.javascript .numberLines}
// book-me/tests/acceptance/create-booking-test.js
/* global server */
import { test } from 'qunit';
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import testSelector from 'ember-test-selectors';
import { authenticateSession, } from 'book-me/tests/helpers/ember-simple-auth';
import page from 'book-me/tests/pages/create-booking';
import moment from 'moment';

moduleForAcceptance('Acceptance | create booking', {
  beforeEach() {
    const user = server.create('user');
    authenticateSession(this.application, { user_id: user.id });
  },
});

test('creating a booking for rental', function(assert) {
  assert.expect(3);

  const dailyRate = 100;
  const rental = server.create('rental', { dailyRate });
  const clientEmail = 'client@email.com';
  const today = moment();
  const currentMonth = today.month() + 1; // month are indexed starting from 0
  const startDay = 10;
  const endDay = 20;
  const price = (endDay - startDay) * dailyRate;

  page
    .visitAdmin()
    .goToRentalPage();

  andThen(() => {
    assert.notOk(find(testSelector('booking-row')).length, 'no bookings should be visible');
  });

  server.post('/bookings', function(schema) {
    const attributes = this.normalizedRequestAttrs();
    const expectedAttributes = {
      rentalId: rental.id,
      clientEmail,
      price,
      beginsAt: `2017-0${currentMonth}-${startDay}T14:00:00.000Z`,
      finishesAt: `2017-0${currentMonth}-${endDay}T10:00:00.000Z`,
    };

    assert.deepEqual(attributes, expectedAttributes,
      "attributes don't match the expected ones");

    return schema.rentals.create(attributes);
  });

  page
    .selectStartDate(startDay)
    .selectEndDate(endDay)
    .fillInClientEmail(clientEmail)
    .createNewBooking();

  andThen(() => {
    assert.ok(find(testSelector('booking-row')).length,
      'bookings should be visible');
  });
});
```

There are some interesting things going on in this test. The beginning is pretty straight-forward - authentication of the user and variables' setup. However, there is one surprise when it comes to the months - in JavaScript, months are indexed from **0**! So, e.g., January will not be `1` but `0` instead! That's why we are adding +1, just to have some reasonable number standing for the current month. Then, we are taking advantage of page object (which is not implemented yet) - we are visiting admin page and going to a rental page. In next step, we are verifying that no booking has been created or loaded yet. Another step is quite similar to what we did in other acceptance tests - we are intercepting a request and verifying if the params sent to `bookings` endpoint match the expected ones and simply creating a booking, just like the original implementation of the route handler from `ember-cli-mirage` does. What we are doing next is selecting start and end dates, filling in client's email and creating a booking, which means simply submitting a form. The last step is checking that the new booking is displayed.

Now let's generate the page object that we are using here since it's not implemented yet:

```
ember generate page-object create-booking
```

Here is its implementation:

```{.javascript .numberLines}
// book-me/tests/pages/create-booking.js
import {
  create,
  clickable,
  fillable,
  visitable,
  clickOnText,
} from 'ember-cli-page-object';
import testSelector from 'ember-test-selectors';

export default create({
  visitAdmin: visitable('/admin'),
  goToRentalPage: clickable(testSelector('show-rental')),
  selectStartDate: clickOnText('button',
    { scope: testSelector('new-booking-calendar') }),
  selectEndDate: clickOnText('button',
    { scope: testSelector('new-booking-calendar') }),
  fillInClientEmail: fillable(testSelector('booking-client-email')),
  createNewBooking: clickable(testSelector('create-booking')),
});
```

There is a new one thing that comes particularly in handy here: `clickOnText` - this property allows to specify an element containing text that is later provided as an argument. In case of the calendar, we need `button` containing the number of the day in the month (which is going to be 10 for start date and 20 for end date). This might not be obvious, but if you've ever used `ember-power-calendar`, you're probably familiar with the structure of the calendar. To make sure we are dealing with the right button in the proper scope, we are passing one explicitly as a `scope` option.

The next step would be generating some `rental/show` route, where we will display the rental info and its bookings. And we are also going to provide a calendar here for creating new bookings:

```
ember g route rental/show
```

The router should include a new `show` route:

```{.javascript .numberLines}
// book-me/app/router.js
import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('signup')
  this.route('login');
  this.route('admin');

  this.route('rentals', function() {
    this.route('new');
  });

  this.route('rental', { path: '/rentals/:rental_id' }, function() {
    this.route('edit');
    this.route('show');
  });
});

export default Router;
```


Here's the route's body that we will start with:

```{.javascript .numberLines}
// book-me/ap/routes/rental/show.js
import Ember from 'ember';

const {
  set,
} = Ember

export default Ember.Route.extend({
  model() {
    return this.modelFor('rental');
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'rental', model);
  },
});
```

Nothing surprising here - we are just grabbing a `rental` from, well, `rental` route and aliasing it on the controller.

Here's the template's body:

```{.html .numberLines}
<!-- book-me/app/templates/rental/show.hbs -->
<h2>{{rental.name}}</h2>

<table class='table table-border'>
  <thead>
    <tr>
      <th>Begins At</th>
      <th>Finishes At</th>
      <th>Length of Stay</th>
      <th>Client Email</th>
      <th>Price</th>
    </tr>
  </thead>
  <tbody>
    {{#each rental.bookings as |booking|}}
      <tr data-test-booking-row>
        <td>{{booking.beginsAt}}</td>
        <td>{{booking.finishesAt}}</td>
        <td>{{booking.lengthOfStay}}</td>
        <td>{{booking.clientEmail}}</td>
        <td>{{booking.price}}</td>
      </tr>
    {{/each}}
  </tbody>
</table>
```

We are just displaying rental's name here and some properties like dates, booking's price and client's email. We are also showing the length of stay of the booking in days to make it more clear how many days are booked. This is going to be a custom computed property that will depend on `booking.beginsAt` and `booking.finishesAt` properties.

Obviously, this template won't work so far as we don't even have a `Booking` model, so let's generate one:

```
ember g model Booking
```

Let's also add `bookings` resource to `ember-cli-mirage` config:

```{.javascript .numberLines}
// book-me/mirage/config.js
export default function() {
  // current logic

  this.resource('bookings');
}
```

The next step would be setting up relationships between `Rental` and `Booking` models and defining attributes. Since we will be dealing with dates here (`beginsAt` and `finishesAt` attributes), ideally we would wrap them with `moment`. Unfortunately, there are no out-of-box attribute transforms in Ember Data that would properly handle serialization and deserialization of the datetime attributes if we care about the timezones. But the good news is that we can easily add them by installing `ember-cli-moment-transform` addon:

```
ember install ember-cli-moment-transform
```

Thanks to that addon, we can use `moment-utc` transform in `Booking` model:

```{.javascript .numberLines}
// book-me/app/models/booking.js
import DS from 'ember-data';

const {
  Model,
  attr,
  belongsTo,
} = DS;

export default Model.extend({
  beginsAt: attr('moment-utc'),
  finishesAt: attr('moment-utc'),
  clientEmail: attr('string'),
  price: attr('number'),

  rental: belongsTo('rental'),
});
```

Let's also add `hasMany` bookings relationship to `Rental` model:

```{.javascript .numberLines}
// book-me/app/models/rental.js
import DS from 'ember-data';

const {
  Model,
  attr,
  hasMany,
} = DS;

export default Model.extend({
  name: attr('string'),
  dailyRate: attr('number'),

  bookings: hasMany('booking'),
});
```

If we are already dealing with models, let's implement `lengthOfStay` property for bookings. The idea behind it is simple: we want to calculate some booked days based on `beginsAt` and `finishesAt` attributes. However, we need to keep in mind that those attributes are datetimes, not only dates, so we can easily end up with the case where, e.g., for one day stay we will get potential `lengthOfStay` value of 0 if the total time of the booking is less than 24h. Maybe technically it is less than one day (i.e., 24h), but in this domain, it must be counted as a one day. The simplest way to deal with it would be just subtracting dates without considering the time part. We can do that by setting time to 0 for both datetimes.

As you may have already guessed, we will start with a test:

```{.javascript .numberLines}
// book-me/app/tests/unit/models/booking-test.js
import { moduleForModel, test } from 'ember-qunit';
import Ember from 'ember';
import moment from 'moment';

const {
  get,
} = Ember;

moduleForModel('booking', 'Unit | Model | booking', {
});

test('lengthOfStay returns number of days of stay', function(assert) {
  const model = this.subject({
    beginsAt: moment.utc('2017-10-01 14:00:00'),
    finishesAt: moment.utc('2017-10-10 10:00:00')
  });

  assert.equal(get(model, 'lengthOfStay'), 9);
});
```

This example should be enough as it already illustrates the just mentioned edge case. Here is the implementation that will make this test happy:

```{.javascript .numberLines}
// book-me/app/models/booking.js
import DS from 'ember-data';
import Ember from 'ember';

const {
  Model,
  attr,
  belongsTo,
} = DS;

const {
  get,
  computed,
} = Ember;

export default Model.extend({
  beginsAt: attr('moment-utc'),
  finishesAt: attr('moment-utc'),
  clientEmail: attr('string'),
  price: attr('number'),

  rental: belongsTo('rental'),

  lengthOfStay: computed('beginsAt', 'finishesAt', function() {
    const beginsAt = get(this, 'beginsAt').clone();
    const finishesAt = get(this, 'finishesAt').clone();

    return finishesAt.set({ hour: 0 }).diff(beginsAt.set({ hour: 0 }), 'days');
  }),
});
```

When dealing with `moment` objects and performing any modification to them (e.g., by using `set` method), it is highly recommended to `clone` any value before - operations such as `set` are mutable, so even when dealing with `lengthOfStay` which definitely looks like something that should be read-only operation, it would still modify `beginsAt` and `finishesAt` attributes and cause unexpected side effects and a real mess in your app.

We are actually missing a link to `rental/show` route, so let's fix that and add it in `admin.hbs` template:

```{.html .numberLines}
<!-- book-me/app/templates/admin.hbs -->
<h2>Admin</h2>

{{#link-to 'rentals.new' data-test-add-rental class='btn btn-primary'}}
  Add rental
{{/link-to}}

<table class='table table-border'>
  <thead>
    <tr>
      <th>Name</th>
      <th>Daily Rate</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    {{#each rentals as |rental|}}
      <tr data-test-rental-row>
        <td>{{link-to rental.name "rental.show" rental}}</td>
        <td>{{rental.dailyRate}}</td>
        <td>
          {{#link-to 'rental.edit' rental data-test-edit-rental
            class='btn btn-primary'}}
            Edit
          {{/link-to}}

          {{#link-to 'rental.show' rental data-test-show-rental
            class='btn btn-primary'}}
            Show
          {{/link-to}}

          {{delete-rental-button rental=rental}}
        </td>
      </tr>
    {{/each}}
  </tbody>
</table>
```

Now that we get easily navigate to `rental/show` route, we can think of the subsequent step: a calendar. The cool thing is that we don't need to do much here and we can almost reuse entire example from the [docs](http://www.ember-power-calendar.com/docs/range-selection):

```{.html .numberLines}
<!-- book-me/app/templates/rental/show.hbs -->
<h2>{{rental.name}}</h2>

<table class='table table-border'>
  <thead>
    <tr>
      <th>Begins At</th>
      <th>Finishes At</th>
      <th>Length of Stay</th>
      <th>Client Email</th>
      <th>Price</th>
    </tr>
  </thead>
  <tbody>
    {{#each rental.bookings as |booking|}}
      <tr data-test-booking-row>
        <td>{{booking.beginsAt}}</td>
        <td>{{booking.finishesAt}}</td>
        <td>{{booking.lengthOfStay}}</td>
        <td>{{booking.clientEmail}}</td>
        <td>{{booking.price}}</td>
      </tr>
    {{/each}}
  </tbody>
</table>

{{#power-calendar-range
  data-test-new-booking-calendar
  selected=range
  onSelect=(action 'selectRange' value='moment') as |calendar|}}
    {{calendar.nav}}
    {{calendar.days}}
{{/power-calendar-range}}

{{outlet}}
```

We are simply displaying a very basic calendar and providing `selectRange` action to be called when the selection changes. As we are dealing here with some controller variables, we are going to handle it with controller's action, not route's action. Even though controllers should be eventually replaced by routable components, it still seems more natural to use controllers instead of routes for such cases.

Also, `outlet` part should give you a hint what is going to happen next. The idea was to display a modal when the `beginsAt` and `finishesAt` dates are selected. Instead of dealing with some conditionals to resolve if we should show the modal or not, we are going to take advantage of Ember router - a modal will simply be placed in a new route: `rental/show/createBooking`. Not only is it simpler as it makes the state management easier, but it also provides a nice way to access this modal just by visiting a page with given URL. We will use query params here and keep the selected date range in the URL. We probably won't share the URLs for creating bookings with anyone, so maybe this use case is a bit far-fetched; nevertheless, it's a good practice in Ember to use its powerful router and URLs for such state management.

Let's generate a controller now for `rental/show` route to handle `selectRange` action and general another route: `rental/show/createBooking`. Since we are going to deal with query params, we will need a controller for that route as well. Query params is a perfectly legit use case for using controllers, so we don't have many alternatives here. Let's generate those controllers and routes now:

```
ember g controller rental/show
ember g controller rental/show/createBooking
ember g route rental/show/createBooking
```

What should we put in `rental/show` controller? The first thing would be explicitly defining `range` property that we are passing as `selected` value to the calendar component, just to make it obvious what kind of data we are dealing with. The second thing would be obviously `selectRange` action. How should it work?

To answer this question, we need to think about `range` property. It is a simple JS object with two properties: `start` and `end`, which as you may have already guessed contain selected dates. In that case, we can check if both of those dates are selected. If they are, we can parse the dates with `moment` to make sure we are dealing with UTC time. Once we parse the data and have the formatted as something that would look reasonable as query params, we can transition to `rental.show.createBooking`.

However, before we do that, we need to add one more thing. Remember the acceptance test's part where we were comparing expected attributes to be sent to `bookings` endpoint via POST request and the actual ones? The values of `startsAt` and `finishesAt` properties contained the time part. With `ember-power-calendar` we are only selecting with dates, so what can we do about time?

Just to keep things simple for the sake of example, let's assume that one day the API will cover managing rentals' `defaultArrivalHour` and `defaultDepartureHour` attributes, but for now, we will hardcode them in `Rental` model. Even though those are going to be super simple computed properties returning just some hardcoded values, it is still worth starting with a test:

```{.javascript .numberLines}
// book-me/tests/unit/models/rental-test.js
import { moduleForModel, test } from 'ember-qunit';
import Ember from 'ember';

const {
  get,
} = Ember;

moduleForModel('rental', 'Unit | Model | rental', {
});

test('defaultArrivalHour returns 14', function(assert) {
  const model = this.subject();

  assert.equal(get(model, 'defaultArrivalHour'), 14);
});

test('defaultDepartureHour returns 10', function(assert) {
  const model = this.subject();

  assert.equal(get(model, 'defaultDepartureHour'), 10);
});
```

And here is the implementation that will make the tests happy:

```{.javascript .numberLines}
// book-me/app/models/rental.js
import DS from 'ember-data';
import Ember from 'ember';

const {
  Model,
  attr,
  hasMany,
} = DS;

const {
  computed,
} = Ember;

export default Model.extend({
  name: attr('string'),
  dailyRate: attr('number'),

  bookings: hasMany('booking'),

  defaultArrivalHour: computed(() => {
    return 14;
  }),

  defaultDepartureHour: computed(() => {
    return 10;
  }),
});
```

In `selectRange` action we will just take those values from the rental and set them as time parts on selected dates:


```{.javascript .numberLines}
// book-me/app/contollers/rental/show.js
import Ember from 'ember';
import moment from 'moment';

const {
  get,
  set,
} = Ember;

export default Ember.Controller.extend({
  range: {
    start: null,
    end: null,
  },

  actions: {
    selectRange(range) {
      set(this, 'range', range);

      if (range.start && range.end) {
        const rental = get(this, 'rental');
        const start = toUTCDate(range.start).set({
          hour: get(rental, 'defaultArrivalHour')
        });
        const end = toUTCDate(range.end).set({
          hour: get(rental, 'defaultDepartureHour')
        });
        this.transitionToRoute('rental.show.createBooking', rental, {
          queryParams: {
            start: start.format(),
            end: end.format(),
          }
        });
      }
    },
  },
});

function toUTCDate(date) {
  return moment.utc(date.format('YYYY-MM-DD'));
}
```

To make sure that the time part is getting set on UTC date attribute and not a local date, we are introducing `toUTCDate` helper function - managing dates in JavaScript is pretty inconvenient and even `moment` doesn't necessarily solve all possible problems with dates.

You might be wondering if we shouldn't maybe start with the unit test before writing `selectRange` action and if that's compatible with TDD flow. The answer is not that simple. To me, such things are just implementation details, and the logic is already covered by the acceptance test. For more complex scenarios I would probably write a unit test to make sure every possible edge case is handled. It might still be considered as an implementation detail, but testing different scenarios on a unit level is simply faster and easier.

We can move on now to `createBooking` route and controller. The router should be updated by running the generator, but just to double check if it's right, this is how it should be looking like now:

```{.javascript .numberLines}
// book-me/app/router.js
import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('signup')
  this.route('login');
  this.route('admin');

  this.route('rentals', function() {
    this.route('new');
  });

  this.route('rental', { path: '/rentals/:rental_id' }, function() {
    this.route('edit');
    this.route('show', function() {
      this.route('createBooking');
    });
  });
});

export default Router;
```

Since the controller will be super simple as it is going to be responsible merely for managing `start` and `end` query params, let's start with the controller:

```{.javascript .numberLines}
// book-me/app/controllers/rental/show/create-booking.js
import Ember from 'ember';

export default Ember.Controller.extend({
  queryParams: ['start', 'end'],
  start: null,
  end: null,
});
```

Again, we are not writing any new tests here as this functionality is indirectly covered by acceptance tests and having unit tests for such code wouldn't bring many benefits either - query params don't really have much sense in isolation, so it's very similar to testing, e.g. `model` or `setupController` hooks which are just minor implementation details of something much bigger.

Let's move to the route now. This part is going to be far more complex, which means it will also be quite fun. There a couple of things this route should be responsible for. The obvious one would be setting up a new booking model. This booking should belong to a rental (which we can easily grab from the `rental` route, thanks to the awesome routing in Ember). Since both `beginsAt` and `finishesAt` dates are available in the query params, we can just parse them with `moment` and populate in `booking` model. We also need two more things: `price` and `client email`. For the email we will provide a separate input but what about `price`?

The cool thing is that we already have `lengthOfStay` computed property available in the model and the price depends exclusively on the length of stay and rental's daily rate, which can be easily taken from the model. In this case, in `model` hook we can just set up the model with populated dates, calculate the price, assign it and return the model.

There are also some other things that will be going on here. The route itself is named `createBooking` so one may expect that it will be responsible for persistence. Since the route is clearly the data owner, it will implement some action that would persist the booking.

Remember the idea how the form for persisting bookings should look like? It was supposed to be displayed inside a modal. And this is exactly what we will do in the template. Also, modals usually have some button for closing them. We are going to implement something very similar, an action like `closeModal` which will call `deleteRecord` on `booking` model (to not leave any unpersisted leftovers) and then perform transition back to `rental.show` route. The same transition makes sense for the action persisting the `booking` so we will do the same upon the successful persistence request.

The transition part is not covered by our acceptance test, so we will add it now:

```{.javascript .numberLines}
// book-me/tests/acceptance/create-booking-test.js
/* global server */
import { test } from 'qunit';
import moduleForAcceptance from 'book-me/tests/helpers/module-for-acceptance';
import testSelector from 'ember-test-selectors';
import { authenticateSession, } from 'book-me/tests/helpers/ember-simple-auth';
import page from 'book-me/tests/pages/create-booking';
import moment from 'moment';

moduleForAcceptance('Acceptance | create booking', {
  beforeEach() {
    const user = server.create('user');
    authenticateSession(this.application, { user_id: user.id });
  },
});

test('creating a booking for rental', function(assert) {
  assert.expect(4); // one more expectation

  const dailyRate = 100;
  const rental = server.create('rental', { dailyRate });
  const clientEmail = 'client@email.com';
  const today = moment();
  const currentMonth = today.month() + 1; // month are indexed starting from 0
  const startDay = 10;
  const endDay = 20;
  const price = (endDay - startDay) * dailyRate;

  page
    .visitAdmin()
    .goToRentalPage();

  andThen(() => {
    assert.notOk(find(testSelector('booking-row')).length,
      'no bookings should be visible');
  });

  server.post('/bookings', function(schema) {
    const attributes = this.normalizedRequestAttrs();
    const expectedAttributes = {
      rentalId: rental.id,
      clientEmail,
      price,
      beginsAt: `2017-0${currentMonth}-${startDay}T14:00:00.000Z`,
      finishesAt: `2017-0${currentMonth}-${endDay}T10:00:00.000Z`,
    };

    assert.deepEqual(attributes, expectedAttributes,
      "attributes don't match the expected ones");

    return schema.rentals.create(attributes);
  });

  page
    .selectStartDate(startDay)
    .selectEndDate(endDay)
    .fillInClientEmail(clientEmail)
    .createNewBooking();

  andThen(() => {
    assert.ok(find(testSelector('booking-row')).length,
      'bookings should be visible');
    assert.equal(currentURL(), `/rentals/${rental.id}/show`,
      'should transition back to rental/show route'); // new scenario
  });
});
```

Ok, let's implement the route itself now, write a proper template and... make the acceptance test pass!

```{.javascript .numberLines}
// book-me/app/routes/rental/show/create-booking.js
import Ember from 'ember';
import moment from 'moment';

const {
  get,
  set,
} = Ember;

export default Ember.Route.extend({
  model(params) {
    const rental = this.modelFor('rental');
    const dailyRate = get(rental, 'dailyRate');
    const beginsAt = moment.utc(params.start);
    const finishesAt = moment.utc(params.end);
    const booking = this.store.createRecord('booking', {
      rental,
      beginsAt,
      finishesAt,
    });

    const price = get(booking, 'lengthOfStay') * dailyRate;
    set(booking, 'price',  price);

    return booking;
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'booking', model);
  },

  actions: {
    createBooking(booking) {
      booking.save().then(this._transitionToRentalRoute.bind(this));
    },
  },

  _transitionToRentalRoute() {
    const rental = this.modelFor('rental');

    this.transitionTo('rental.show', rental);
  },
});
```

```{.html .numberLines}
<!-- book-me/app/templates/rental/show/create-booking.hbs -->
{{#modal-dialog targetAttachment='center' translucentOverlay=true}}
  <h3>Create booking</h3>

  <form {{action (route-action 'createBooking' booking) on='submit'}}>
    <div class="form-group">
      <label for="booking-client-email">Client Email</label>
      {{input
        data-test-booking-client-email
        id="client-email"
        value=(mut booking.clientEmail)
        class="form-control"
      }}
    </div>

    <button data-test-create-booking type="submit"
      class="btn btn-primary">Create booking</button>
  </form>
{{/modal-dialog}}
```

By saving this template, we made our final test acceptance test pass :).

The template is quite basic without much new stuff except `modal-dialog` component which provides the actual modal. We want modal to be positioned in the center and to have a translucent overlay, which we can easily configure. As you can see, model's API is simple yet powerful. That is everything we need to handle this modal.

In route we've taken advantage of a pretty cool pattern - instead of providing an anonymous function for handling the success part of persisting a booking like this:

```{.javascript .numberLines}
booking.save().then(() => {
  const rental = this.modelFor('rental');

  this.transitionTo('rental.show', rental);
});
```

we passed `_transitionToRentalRoute` function, which arguably looks more readable. We also need to keep in mind that we are taking advantage of `this` in that function which we expect to be a `route` object. In such case, we need to `bind` the proper context, that's why we are doing it as `this._transitionToRentalRoute.bind(this)` to make it work.

Here are the screenshots to illustrate what we've just achieve:

![Admin](http://download.karolgalanciak.com/test-driven-ember/book_me_05.png)

![Rental show with calendar](http://download.karolgalanciak.com/test-driven-ember/book_me_06.png)

![Form in modal](http://download.karolgalanciak.com/test-driven-ember/book_me_07.png)

![Persisted booking](http://download.karolgalanciak.com/test-driven-ember/book_me_08.png)

Again, there are some issues and the UI is not perfect, but this is not something that we want to devote much time in this book.

Nevertheless, we are not finished yet; there are some still few interesting things we need to add:

1. Closing the modal and transitioning to `rental/show` route.

2. Deselecting range selection in calendar upon the successful persistence of a booking. The same behavior would make sense as well in point 1.

3. Validations. The obvious ones would be validating the numericality and presence of `price` and presence and format of `clientEmail`. However, there is one not that obvious - validation of the dates and making sure that there is no overlapping of any dates.

For 3rd point, just like for previous use cases, we will generate a separate component to encapsulate the logic, so let's do it now:

```
ember g component create-booking-form
```

Here's the code for the component and its template to preserve the current behavior:

```{.javascript .numberLines}
// book-me/app/components/create-booking-form.js
import Ember from 'ember';

const {
  get,
} = Ember;

export default Ember.Component.extend({
  actions: {
    createBooking() {
      const booking = get(this, 'booking');

      get(this, 'onCreateBooking')(booking);
    },
  },
});
```

```{.html .numberLines}
<!-- book-me/app/templates/components/create-booking-form.hbs -->
<form {{action 'createBooking' on='submit'}}>
  <div class="form-group">
    <label for="booking-client-email">Client Email</label>
    {{input
      data-test-booking-client-email
      id="client-email"
      value=(mut booking.clientEmail)
      class="form-control"
    }}
  </div>

  <button data-test-create-booking type="submit"
    class="btn btn-primary">Create booking</button>
</form>
```

And the updated version of the template of `rental/show/createBooking` route which takes advantage of `create-booking-form` component:

```{.html .numberLines}
<!-- book-me/app/templates/rental/show/create-booking.hbs -->
{{#modal-dialog targetAttachment='center' translucentOverlay=true}}
  <h3>Create booking</h3>

  {{create-booking-form
    booking=booking
    onCreateBooking=(route-action 'createBooking')
  }}
{{/modal-dialog}}
```

Let's start with point no. 1: "closing" the modal which will simply invoke a transition back to `rental/show` route and deselect calendar's range.

One way to start this feature would be writing an acceptance test. The other way would be covering this functionality with unit tests. Obviously, the acceptance test would be more accurate, but it would also be slower. Closing a modal is not a business-critical feature, so it might be ok make it a bit simpler and just cover it with unit or integration tests, which maybe don't provide 100% guarantee that the entire feature works (there is always a possibility that something in some layer may go wrong), but gives enough confidence that we might assume that as long as those tests pass, the feature works just fine.

Let's start with a route's action test. We will implement an action called `closeModal`. The idea behind it is simple: we want to `deleteRecord` to not leave any leftovers, reset calendar's `range` and transition back to `rental/show` route. Here's the test:

```{.javascript .numberLines}
// book-me/tests/unit/routes/rental/show/create-booking-test.js
import { moduleFor, test } from 'ember-qunit';

moduleFor('route:rental/show/create-booking', 'Unit | Route |
  rental/show/create booking', {
});

test("closeModal action deletes booking record, resets calendar's range and
  peforms transition to `rental/show` route", function(assert) {
  assert.expect(4);

  const route = this.subject();

  const controllerStub = Ember.Object.extend({
    resetRange() {
      assert.ok(true, 'resetRange should be called');
    },
  }).create();
  const rentalStub = Ember.Object.create();
  const bookingStub = Ember.Object.extend({
    deleteRecord() {
      assert.ok(true, 'deleteRecord should be called');
    },
  }).create();

  route.controllerFor = (name) => {
    if (name === 'rental.show') {
      return controllerStub;
    }
  };
  route.modelFor = (name) => {
    if (name === 'rental') {
      return rentalStub;
    }
  };
  route.transitionTo = (routeName, rentalArgument) => {
    assert.equal(routeName, 'rental.show',
      'should transition to rental.show route');
    assert.deepEqual(rentalArgument, rentalStub,
      'should be called with proper argument');
  };

  route.actions.closeModal.bind(route)(bookingStub);
});
```

This test is far from perfect. A lot of stubs and seems almost like coupling to some very specific implementation. But you need to keep in mind that testing is about having a right level of confidence, so some aspects might depend on preference. If such unit testing is ok for you then great. If not, you still have other options, like writing acceptance test to cover this case, which is not necessarily worse.

The flow of the test is quite simple - verifying if the right methods are called with the expected arguments. We are also stubbing two methods on the route itself which might not be the best idea in most cases since stubbing object under the test is considered an anti-pattern (and for the right reason), but here it doesn't bring many issues and really helps to test this action.

Here is our implementation:

```{.javascript .numberLines}
// book-me/app/routes/rental/show.js
import Ember from 'ember';
import moment from 'moment';

const {
  get,
  set,
} = Ember;

export default Ember.Route.extend({
  model(params) {
    const rental = this.modelFor('rental');
    const dailyRate = get(rental, 'dailyRate');
    const beginsAt = moment.utc(params.start);
    const finishesAt = moment.utc(params.end);
    const booking = this.store.createRecord('booking', {
      rental,
      beginsAt,
      finishesAt,
    });

    const price = get(booking, 'lengthOfStay') * dailyRate;
    set(booking, 'price',  price);

    return booking;
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'booking', model);
  },

  actions: {
  	closeModal(booking) {
      booking.deleteRecord();

      this._transitionToRentalRoute(this);
    },

    createBooking(booking) {
      booking.save().then(this._transitionToRentalRoute.bind(this));
    },
  },

  _transitionToRentalRoute() {
    this.controllerFor('rental.show').resetRange();

    const rental = this.modelFor('rental');

    this.transitionTo('rental.show', rental);
  },
});
```

Since the same thing happens after successfully persisting a booking, let's also write a test to cover `createBooking` action:

```{.javascript .numberLines}
// book-me/tests/unit/routes/rental/show/create-booking-test.js
import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';

const {
  RSVP,
  run,
  computed,
} = Ember;

moduleFor('route:rental/show/create-booking', 'Unit | Route |
  rental/show/create booking', {
  needs: ['service:session'],
});

// previous test

test("createBooking action creates booking, resets calendar's range and
  peforms transition to `rental/show` route", function(assert) {
  assert.expect(4);

  const route = this.subject();

  const controllerStub = Ember.Object.extend({
    resetRange() {
      assert.ok(true, 'resetRange should be called');
    },
  }).create();
  const rentalStub = Ember.Object.create();
  const bookingStub = Ember.Object.extend({
    save() {
      assert.ok(true, 'save should be called');
      return RSVP.resolve();
    },
  }).create();

  route.controllerFor = (name) => {
    if (name === 'rental.show') {
      return controllerStub;
    }
  };
  route.modelFor = (name) => {
    if (name === 'rental') {
      return rentalStub;
    }
  };
  route.transitionTo = (routeName, rentalArgument) => {
    assert.equal(routeName, 'rental.show',
      'should transition to rental.show route');
    assert.deepEqual(rentalArgument, rentalStub,
      'should be called with proper argument');
  };

  run(() => {
    route.actions.createBooking.bind(route)(bookingStub);
  });
});
```

The test is quite similar, but there is one major difference - we are  wrapping the method call inside `Ember.run` function, to avoid any potential surprises with promises and their async nature.

Since there are a lot of duplications in this file,  you might be wondering about DRYing the tests. Personally, I'm not a big fan DRY in tests. The readability and expressiveness are essential in testing and we lose both of them when we attempt to extract some parts. I don't really do it unless the benefits are substantial. Herem it would make a small difference, so it's ok to leave those tests as they are.

There is also one more thing that should be added to both `rental/show` and `rental/show/createBooking` routes: authentication. We are going to reuse the same code as for other routes. Obviously, we will start with tests:

```{.javascript .numberLines}
// book-me/tests/unit/routes/rental/show/create-booking-test.js
import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember';

const {
  RSVP,
  run,
  computed,
} = Ember;

moduleFor('route:rental/show/create-booking', 'Unit | Route |
  rental/show/create booking', {
  needs: ['service:session'], // required for other tests
});

test("closeModal action deletes booking record, resets calendar's
  range and peforms transition to `rental/show` route", function(assert) {
  assert.expect(4);

  const route = this.subject();

  const controllerStub = Ember.Object.extend({
    resetRange() {
      assert.ok(true, 'resetRange should be called');
    },
  }).create();
  const rentalStub = Ember.Object.create();
  const bookingStub = Ember.Object.extend({
    deleteRecord() {
      assert.ok(true, 'deleteRecord should be called');
    },
  }).create();

  route.controllerFor = (name) => {
    if (name === 'rental.show') {
      return controllerStub;
    }
  };
  route.modelFor = (name) => {
    if (name === 'rental') {
      return rentalStub;
    }
  };
  route.transitionTo = (routeName, rentalArgument) => {
    assert.equal(routeName, 'rental.show',
      'should transition to rental.show route');
    assert.deepEqual(rentalArgument, rentalStub,
      'should be called with proper argument');
  };

  route.actions.closeModal.bind(route)(bookingStub);
});

test("createBooking action creates booking, resets calendar's range and
  peforms transition to `rental/show` route", function(assert) {
  assert.expect(4);

  const route = this.subject();

  const controllerStub = Ember.Object.extend({
    resetRange() {
      assert.ok(true, 'resetRange should be called');
    },
  }).create();
  const rentalStub = Ember.Object.create();
  const bookingStub = Ember.Object.extend({
    save() {
      assert.ok(true, 'save should be called');
      return RSVP.resolve();
    },
  }).create();

  route.controllerFor = (name) => {
    if (name === 'rental.show') {
      return controllerStub;
    }
  };
  route.modelFor = (name) => {
    if (name === 'rental') {
      return rentalStub;
    }
  };
  route.transitionTo = (routeName, rentalArgument) => {
    assert.equal(routeName, 'rental.show',
      'should transition to rental.show route');
    assert.deepEqual(rentalArgument, rentalStub,
      'should be called with proper argument');
  };

  run(() => {
    route.actions.createBooking.bind(route)(bookingStub);
  });
});

// new test

test('it requires authentication', function(assert) {
  assert.expect(1);

  const sessionStub = Ember.Service.extend({
    isAuthenticated: computed(() => {
      assert.ok(true, 'isAuthenticated has to be used for checking authentication');

      return true;
    }),
  });

  this.register('service:session', sessionStub);
  this.inject.service('session');

  const route = this.subject();

  route.beforeModel();
});
```

```{.javascript .numberLines}
// book-me/tests/unit/routes/rental/show-test.js
import { moduleFor, test } from 'ember-qunit';
import Ember from 'ember'

const {
  computed,
} = Ember;

moduleFor('route:rental/show', 'Unit | Route | rental/show', {
  needs: ['service:session'],
});

// new test

test('it requires authentication', function(assert) {
  assert.expect(1);

  const sessionStub = Ember.Service.extend({
    isAuthenticated: computed(() => {
      assert.ok(true, 'isAuthenticated has to be used for checking authentication');

      return true;
    }),
  });

  this.register('service:session', sessionStub);
  this.inject.service('session');

  const route = this.subject();

  route.beforeModel();
});
```

The implementation is going to be dead-simple: just extend the route with `AuthenticatedRouteMixin` mixin:

```{.javascript .numberLines}
// book-me/app/routes/rental/show.js
import Ember from 'ember';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

const {
  set,
} = Ember

export default Ember.Route.extend(AuthenticatedRouteMixin, {
  model() {
    return this.modelFor('rental');
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'rental', model);
  },
});
```

```{.javascript .numberLines}
// book-me/app/routes/rental/show/create-booking.js
import Ember from 'ember';
import moment from 'moment';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

const {
  get,
  set,
} = Ember;

export default Ember.Route.extend(AuthenticatedRouteMixin, {
  model(params) {
    const rental = this.modelFor('rental');
    const dailyRate = get(rental, 'dailyRate');
    const beginsAt = moment.utc(params.start);
    const finishesAt = moment.utc(params.end);
    const booking = this.store.createRecord('booking', {
      rental,
      beginsAt,
      finishesAt,
    });

    const price = get(booking, 'lengthOfStay') * dailyRate;
    set(booking, 'price',  price);

    return booking;
  },

  setupController(controller, model) {
    this._super();

    set(controller, 'booking', model);
  },

  actions: {
    closeModal(booking) {
      booking.deleteRecord();

      this._transitionToRentalRoute(this)
    },

    createBooking(booking) {
      booking.save().then(this._transitionToRentalRoute.bind(this));
    },
  },

  _transitionToRentalRoute() {
    this.controllerFor('rental.show').resetRange();

    const rental = this.modelFor('rental');

    this.transitionTo('rental.show', rental);
  },
});
```

To finish points `1` and `2`, we need to ensure those actions are handled in the component. For `createBooking` we already know that it works - the acceptance test is passing just fine. However, `closeModal` is not used yet, so we definitely need to cover it.

Let's update the template for `rental/show/createBooking`:

```{.html .numberLines}
<!-- book-me/templates/rental/show/create-booking.hbs -->
{{#modal-dialog targetAttachment='center' translucentOverlay=true}}
  <h3>Create booking</h3>

  {{create-booking-form
    booking=booking
    rentalBookings=rental.bookings
    onCreateBooking=(route-action 'createBooking')
    onCancelCreation=(route-action 'closeModal')
  }}
{{/modal-dialog}}
```

As already discussed, we are not going to cover it with acceptance test, which is not perfect as a small part of this functionality won't be covered with tests at all, but it's not a business critical feature anyway, so even in worst case scenario when something breaks, it's not going to be the end of the world.

The next step will be writing component's integration tests. We will cover with tests both the action for creating booking (already implemented) and for canceling the creation (not added yet).

Again, let's start with the tests:

```{.javascript .numberLines}
// book-me/tests/integration/components/create-booking-form-test.js
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import testSelector from 'ember-test-selectors';

const {
  set,
} = Ember;

moduleForComponent('create-booking-form', 'Integration | Component | create
  booking form', {
  integration: true
});

test('submitting form fires onCreateBooking action with booking
  as argument', function(assert) {
  assert.expect(1);

  const {
    $,
  } = this;
  const bookingStub = Ember.Object.create();
  const onCreateBooking = (argument) => {
    assert.deepEqual(argument, bookingStub,
      'onCreateBooking should be called with booking');
  };

  set(this, 'booking', bookingStub);
  set(this, 'onCreateBooking', onCreateBooking)

  this.render(hbs`{{create-booking-form booking=booking
    onCreateBooking=onCreateBooking}}`);

  $(testSelector('create-booking')).click();
});

test('clicking cancel button fires onCancelCreation action with booking
  as argument', function(assert) {
  assert.expect(1);

  const {
    $,
  } = this;
  const bookingStub = Ember.Object.create();
  const onCancelCreation = (argument) => {
    assert.deepEqual(argument, bookingStub,
      'onCancelCreation should be called with booking');
  };

  set(this, 'booking', bookingStub);
  set(this, 'onCancelCreation', onCancelCreation)

  this.render(hbs`{{create-booking-form booking=booking
    onCancelCreation=onCancelCreation}}`);

  $(testSelector('cancel-creation')).click();
});
```

The structure of the tests is quite simple: we are doing the necessary setup and providing stubs for bookings and actions, where we perform the assertions that the function is actually called (thanks to `assert.expect(1)` at the beginning of the tests) and that it is called with the right argument. Then, we are rendering the component and clicking the button. Here is the implementation of the component and its template to make tests happy:

```{.javascript .numberLines}
// book-me/app/components/create-booking-form.js
import Ember from 'ember';

const {
  get,
} = Ember;

export default Ember.Component.extend({
  actions: {
    createBooking() {
      const booking = get(this, 'booking');

      get(this, 'onCreateBooking')(booking)
    },

    cancelCreation() {
      const booking = get(this, 'booking');

      get(this, 'onCancelCreation')(booking)
    },
  },
});
```

```{.html .numberLines}
<!-- book-me/app/templates/components/create-booking-form.hbs -->
<form {{action 'createBooking' on='submit'}}>
  <div class="form-group">
    <label for="booking-client-email">Client Email</label>
    {{input
      data-test-booking-client-email
      id="client-email"
      value=(mut booking.clientEmail)
      class="form-control"
    }}
  </div>

  <button data-test-create-booking type="submit"
    class="btn btn-primary">Create booking</button>
  <button data-test-cancel-creation type="button" {{action 'cancelCreation'}}
    class="btn btn-danger">Close</button>
</form>
```

We are back to green!

Now, it's time for the final part of the app described in the 3rd point: validations. The most tricky one is going to be a validation that the dates do not overlap with already existing bookings, especially since format or presence validation is quite trivial to implement. That definitely sounds like `ember-changeset` validations, so let's start with generating a validator:

```
ember generate validator booking
```

To implement the proper validation for dates' overlapping, we need figure out what that even means in the first place. Let's imagine we want to create a booking with `beginsAt` time as `2017-10-01 14:00:00` and `finishesAt` as `2017-10-10 10:00:00`. We need to make sure that at no time does this dates range cover any other booking. There are four possibilities of covering some other booking:

1. Another booking has `beginsAt` before a new booking's `beginsAt` and `finishesAt` after `finishesAt` time of the new booking. The example would be a booking lasting from `2017-10-01 10:00:00` (notice the hour) to `2017-10-11 10:00:00`.

2. Other booking has `beginsAt` before a new booking's `beginsAt` and `finishesAt` between `beginsAt` / `finishesAt` time of the new booking. The example would be a booking lasting from `2017-10-01 10:00:00` (notice the hour) to `2017-10-05 10:00:00`.

3. Other booking has `beginsAt` between new booking's `beginsAt` / `finishesAt` and `finishesAt` time also between `beginsAt` / `finishesAt` time of the new booking. The example would be a booking lasting from `2017-10-02 14:00:00` to `2017-10-09 10:00:00`.

4. Other booking has `beginsAt` between new booking's `beginsAt` / `finishesAt` and `finishesAt` after `finishesAt` time of the new booking. The example would be a booking lasting from `2017-10-05 10:00:00` to `2017-10-12 10:00:00`.

Let's assume that we are inclusive in all case on the exact times, so if one booking finishes at `2017-10-10 10:00:00`, it is also possible for another booking to start from `2017-10-11 10:00:00`.

Are you able to notice any pattern in those examples?

It looks like any potential overlapping booking would have its `beginsAt` before new booking's `finishesAt` and at the same time its `finishesAt` after new booking's `beginsAt`. So a non-overlapping booking would need to have both `beginsAt` and `finishesAt` before new booking's `beginsAt` time or both `beginsAt` and `finishesAt` after new booking's `finishesAt`.

Now that we know how the logic should be implemented, we can start thinking how it could be integrated with `ember-changeset-validator`. It sounds like we need a custom validation function. After consulting the [docs](https://github.com/DockYard/ember-changeset-validations#synchronous-validators), we see that it is not that hard - to make it work we need to implement a function returning another function taking `key`, `newValue`, `oldValue`, `changes` and `content` as arguments. If the result is valid, we need to return `true`. Otherwise, we return an error message. The only argument we will be interested in from those will be `content` as this is going to be a new booking with populated `beginsAt` and `finishesAt` properties.

 Also, we need to somehow have access to all the bookings for given rental. Thanks to the design of validation functions, it is going to be pretty straight-forward. We will just take advantage of JS closures. Since we have to implement a function returning another function, we can pass `bookings` as the argument to the outer function. This argument will be available in the inner function's scope. `ember-changeset-validators` addon expects that the factory function will take object argument. In that case, the potential implementation of such custom validator might look like this:

```{.javascript .numberLines}
import Ember from 'ember';

const {
  get,
} = Ember;

function validateNoOverlapping({ bookings }) {
  return (_key, _value, _oldValue, _changes, content) => {
    const overlappingBookings = bookings.filter((booking) => {
      return content !== booking &&
             get(booking, 'beginsAt').isBefore(get(content, 'finishesAt')) &&
             get(booking, 'finishesAt').isAfter(get(content, 'beginsAt'))
    });

    if (overlappingBookings.length === 0) {
      return true;
    } else {
      return 'Dates must not overlap with other bookings';
    }
  };
}
```

Thanks to `moment` functions like `isBefore` or `isAfter`, implementing such logic is not that hard. We are just looking for overlapping bookings by the just mentioned criteria and if we don't find any, we consider the result valid.

It looks like we have the most challenging part covered. What else do we need to have when it comes to booking's validations?

For client's email we just need to validate the presence of the email address and the right format and, as far as price goes, it must be an integer that is greater than 0.

One optional validation would be making sure that `finishesAt` time is after `beginsAt`, but it's not possible to perform such selection with `ember-power-calendar`, so it might be enough if such validation existed exclusively server-side.

Let's write the tests then. However, the structure of the validator itself is going to be different than the ones in previous cases. For example, in case of a rental validator, we are just returning a simple object with attributes as keys and validation functions as values. Here, we need to implement a function taking `bookings` collection as an argument that returns an object with attributes as keys and validation functions as values - that's the only way to have access to `bookings`. Here are the tests that cover all the mentioned use cases:

```{.javascript .numberLines}
// book-me/tests/unit/validators/booking-test.js
import { module, test } from 'qunit';
import validateBooking from 'book-me/validators/booking';
import Ember from 'ember';
import moment from 'moment';

module('Unit | Validator | booking');

test('it validates presence of client email', function(assert) {
  const bookings = [];
  const validator = validateBooking(bookings);

  assert.equal(validator.clientEmail[0]('clientEmail', ''),
    "Client email can't be blank");

  assert.ok(validator.clientEmail[0]('clientEmail',
    'example@mail.com'));
});

test('it validates format of client email', function(assert) {
  const bookings = [];
  const validator = validateBooking(bookings);

  assert.equal(validator.clientEmail[1]('clientEmail', 'example@'),
    'Client email must be a valid email address');

  assert.ok(validator.clientEmail[1]('clientEmail',
    'example@mail.com'));
});

test('it validates if price is an integer greater than 0', function(assert) {
  const bookings = [];
  const validator = validateBooking(bookings);

  assert.equal(validator.price('price', null), 'Price must be a number');
  assert.equal(validator.price('price', 123.12), 'Price must be an integer');

  assert.ok(validator.price('price', 100));
});

test('it validates if dates overlap with existing bookings', function(assert) {
  const bookings = [
    Ember.Object.create({
      beginsAt: moment.utc('2017-10-01 14:00:00'),
      finishesAt: moment.utc('2017-10-10 10:00:00')
    })
  ];
  const validator = validateBooking(bookings);
  const _ = null;

  let content = Ember.Object.create({
    beginsAt: moment.utc('2017-10-01 14:00:00'),
    finishesAt: moment.utc('2017-10-10 10:00:00')
  });
  assert.equal(validator.dates(_, _, _, _, content),
    'Dates must not overlap with other bookings');

  content = Ember.Object.create({
    beginsAt: moment.utc('2017-10-01 10:00:00'),
    finishesAt: moment.utc('2017-10-11 10:00:00')
  });
  assert.equal(validator.dates(_, _, _, _, content),
    'Dates must not overlap with other bookings');

  content = Ember.Object.create({
    beginsAt: moment.utc('2017-10-01 10:00:00'),
    finishesAt: moment.utc('2017-10-05 10:00:00')
  });
  assert.equal(validator.dates(_, _, _, _, content),
    'Dates must not overlap with other bookings');

  content = Ember.Object.create({
    beginsAt: moment.utc('2017-10-02 14:00:00'),
    finishesAt: moment.utc('2017-10-09 10:00:00')
  });
  assert.equal(validator.dates(_, _, _, _, content),
    'Dates must not overlap with other bookings');

  content = Ember.Object.create({
    beginsAt: moment.utc('2017-10-05 10:00:00'),
    finishesAt: moment.utc('2017-10-12 10:00:00')
  });
  assert.equal(validator.dates(_, _, _, _, content),
    'Dates must not overlap with other bookings');

  content = Ember.Object.create({
    beginsAt: moment.utc('2017-10-10 10:00:00'),
    finishesAt: moment.utc('2017-10-12 10:00:00')
  });
  assert.ok(validator.dates(_, _, _, _, content));

  content = Ember.Object.create({
    beginsAt: moment.utc('2017-09-10 10:00:00'),
    finishesAt: moment.utc('2017-10-01 14:00:00')
  });
  assert.ok(validator.dates(_, _, _, _, content));

  content = Ember.Object.create({
    beginsAt: moment.utc('2017-09-10 10:00:00'),
    finishesAt: moment.utc('2017-10-01 13:00:00')
  });
  assert.ok(validator.dates(_, _, _, _, content));

  content = Ember.Object.create({
    beginsAt: moment.utc('2017-10-10 11:00:00'),
    finishesAt: moment.utc('2017-10-15 10:00:00')
  });
  assert.ok(validator.dates(_, _, _, _, content));
});
```

TDDing such functionality certainly requires some knowledge of the `ember-changeset-validations` API, but after writing few validators like this, it gets much simpler.

Here's the implementation:

```{.javascript .numberLines}
// book-me/app/validators/booking.js
import {
  validatePresence,
  validateFormat,
  validateNumber,
} from 'ember-changeset-validations/validators';

import Ember from 'ember';

const {
  get,
} = Ember;

export default function createBookingValidator(bookings) {
  return {
    clientEmail: [
      validatePresence(true),
      validateFormat({ type: 'email' })
    ],
    price: validateNumber({ integer: true, gt: 0 }),
    dates: validateNoOverlapping({ bookings }),
  }
}

function validateNoOverlapping({ bookings }) {
  return (_key, _value, _oldValue, _changes, content) => {
    const overlappingBookings = bookings.filter((booking) => {
      return content !== booking &&
             get(booking, 'beginsAt').isBefore(get(content, 'finishesAt')) &&
             get(booking, 'finishesAt').isAfter(get(content, 'beginsAt'))
    });

    if (overlappingBookings.length === 0) {
      return true;
    } else {
      return 'Dates must not overlap with other bookings';
    }
  };
}
```

Nice! All tests are passing again, so we can just take advantage of the validations in the `create-booking-form` component. Obviously, we are going to start with the integration test verifying that the error messages are properly displayed:

```{.javascript .numberLines}
// book-me/tests/integration/components/create-booking-form-test.js
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import testSelector from 'ember-test-selectors';

const {
  set,
} = Ember;

moduleForComponent('create-booking-form', 'Integration | Component |
  create booking form', {
  integration: true
});

test('it displays validation error when the data is invalid', function(assert) {
  assert.expect(2);

  const {
    $,
  } = this;
  const bookingStub = Ember.Object.create();

  set(this, 'booking', bookingStub);
  set(this, 'rentalBookings', []);
  set(this, 'onCreateBooking', () => {
    throw new Error('action should not be called');
  });

  this.render(hbs`{{create-booking-form booking=booking
    onCreateBooking=onCreateBooking rentalBookings=rentalBookings}}`);

  assert.notOk($(testSelector('booking-errors')).length,
    'errors should not initially be visible')

  $(testSelector('create-booking')).click();

  assert.ok($(testSelector('booking-errors')).length,
    'errors should be visible when submitting form with invalid data');
});
```

The idea behind the test is simple - initially, the errors should not be visible, but after attempting to create a booking, some errors should be displayed if data is invalid.

Here is the implementation that would make the new test pass:

```{.javascript .numberLines}
// book-me/app/components/create-booking-form.js
import Ember from 'ember';
import Changeset from 'ember-changeset';
import lookupValidator from 'ember-changeset-validations';
import BookingValidators from 'book-me/validators/booking';

const {
  get,
  set,
} = Ember;

export default Ember.Component.extend({
  init() {
    this._super(...arguments);

    const rentalBookings = get(this, 'rentalBookings');
    const booking = get(this, 'booking')
    const validators = BookingValidators(rentalBookings);
    const changeset = new Changeset(booking, lookupValidator(validators), validators);

    set(this, 'changeset', changeset);
  },

  actions: {
    createBooking() {
      const changeset = get(this, 'changeset');

      changeset.validate().then(() => {
        if (get(changeset, 'isValid')) {
          get(this, 'onCreateBooking')(changeset)
        }
      });
    },

    cancelCreation() {
      const booking = get(this, 'booking');

      get(this, 'onCancelCreation')(booking);
    },
  },
});
```

The structure is almost the same as the one for persisting a rental. The only difference is setting up validators where we are passing `rentalBookings`.

Here is the template:

```{.html .numberLines}
<!-- book-me/app/templates/components/create-booking-form.hbs -->
{{#if changeset.isInvalid}}
  <section data-test-booking-errors>
    {{#each changeset.errors as |error|}}
      <div class="alert alert-danger" role="alert">
        {{error.validation}}
      </div>
    {{/each}}
  </section>
{{/if}}

<form {{action 'createBooking' on='submit'}}>
  <div class="form-group">
    <label for="booking-client-email">Client Email</label>
    {{input
      data-test-booking-client-email
      id="client-email"
      value=(mut changeset.clientEmail)
      class="form-control"
    }}
  </div>

  <button data-test-create-booking type="submit"
    class="btn btn-primary">Create booking</button>
  <button data-test-cancel-creation type="button" {{action 'cancelCreation'}}
    class="btn btn-danger">Close</button>
</form>
```

Notice that we also adjusted `input` - we are no longer dealing with `booking` directly but `changeset`.

We managed to make the new test pass, but the old one, verifying that `onCreateBooking`, action gets called fails. The acceptance test for creating a new booking fails as well.

Let's start with the component's integration test. We need to adjust it by making sure the data is valid before submitting the form and that the action gets called with `changeset` argument, not a model. Also, we need to pass `rentalBookings` array

Here is the test after adjustments:

```{.javascript .numberLines}
// book-me/tests/integration/components/create-booking-form-test.js
test('submitting form fires onCreateBooking action with booking as
  argument', function(assert) {
  assert.expect(1);

  const {
    $,
  } = this;
  const bookingStub = Ember.Object.create({
    beginsAt: moment.utc('2017-10-01 14:00:00'),
    finishesAt: moment.utc('2017-10-10 10:00:00'),
    price: 100,
  });
  const onCreateBooking = (argument) => {
    assert.deepEqual(argument._content, bookingStub,
      'onCreateBooking should be called with booking changeset');
  };

  set(this, 'booking', bookingStub);
  set(this, 'rentalBookings', []);
  set(this, 'onCreateBooking', onCreateBooking)

  this.render(hbs`{{create-booking-form booking=booking
    onCreateBooking=onCreateBooking rentalBookings=rentalBookings}}`);

  $(testSelector('booking-client-email')).val('client@example.com').change();

  $(testSelector('create-booking')).click();
});

// other tests
```

Now it's time for the final thing - making the acceptance test green again. The problem is that we are not passing `rentalBookings` to `create-booking-form`. Since this is a route that is nested inside `rental` route, we can easily get the rental via `this.modelFor('rental')`. Let's assign then a `rental` property to `controller` in `rental/show/create-booking` route:

```{.javascript .numberLines}
// book-me/app/routes/rental/create-booking.js
import Ember from 'ember';
import moment from 'moment';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

const {
  get,
  set,
} = Ember;

export default Ember.Route.extend(AuthenticatedRouteMixin, {
  model(params) {
    const rental = this.modelFor('rental');
    const dailyRate = get(rental, 'dailyRate');
    const beginsAt = moment.utc(params.start);
    const finishesAt = moment.utc(params.end);
    const booking = this.store.createRecord('booking', {
      rental,
      beginsAt,
      finishesAt,
    });

    const price = get(booking, 'lengthOfStay') * dailyRate;
    set(booking, 'price',  price);

    return booking;
  },

  setupController(controller, model) {
    this._super();

    const rental = this.modelFor('rental');

    set(controller, 'booking', model);
    set(controller, 'rental', rental)
  },

  actions: {
    closeModal(booking) {
      booking.deleteRecord();

      this._transitionToRentalRoute(this)
    },

    createBooking(booking) {
      booking.save().then(this._transitionToRentalRoute.bind(this));
    },
  },

  _transitionToRentalRoute() {
    this.controllerFor('rental.show').resetRange();

    const rental = this.modelFor('rental');

    this.transitionTo('rental.show', rental);
  },
});
```

And now we can just pass the bookings of this rental to `create-booking-form` component. Since we are relying on the values of the bookings' attributes for validations, it would make sense to not render the component until the bookings are fetched and populated. Just passing `rental.bookings` won't be enough as it merely returns a promise that is not initially resolved. To have all the properties of the bookings available in the data fetched from the server, we need to make sure that the promise is settled. Fortunately, this is pretty simple. We just need to check the state of the promise. In this case, we will render the component only if `rental.bookings.isSettled` is true:

```{.html .numberLines}
<!-- book-me/app/templates/components/create-booking-form.hbs -->
{{#modal-dialog targetAttachment='center' translucentOverlay=true}}
  <h3>Create booking</h3>

  {{#if rental.bookings.isSettled}}
    {{create-booking-form
      booking=booking
      rentalBookings=rental.bookings
      onCreateBooking=(route-action 'createBooking')
      onCancelCreation=(route-action 'closeModal')
    }}
  {{/if}}
{{/modal-dialog}}
```

And this all! We've successfully implemented all the features. Of course, there are a lot of small things that could be improved (e.g., handling server-side validation errors for new bookings), but after reading this booking adding, such simple features by practicing TDD should be your second nature :).

\pagebreak
