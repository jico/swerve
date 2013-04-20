[![Build Status](https://travis-ci.org/jico/swerve.png?branch=master)](https://travis-ci.org/jico/swerve)

# Swerve

Feature flipping for Node.js

## Installation

Add `swerve` to your `package.json` file and `npm install`. Or:

```bash
npm install swerve --save
```

If you're using Hem, also make sure you add it to your `slug.json` file as a
dependency.

## Configuration

Require Swerve (globally, in most cases). In CoffeeScript, you'll have something
similar to below.

```coffeescript
Swerve = require('swerve')

# Or, if you have this in some setup file
window?.Swerve = require('swerve')
```

Then, you'll need to configure Swerve with the feature settings you want for
each environment. There are three ways to do this:

* Pass in a hash.

  ```coffeescript
  Swerve.configure
    development:
      notifications: true
    production:
      notifications: false
  ```

* Store your settings in a JSON file and pass the file name
instead.

  ```coffeescript
  Swerve.configure('features.json')
  ```

* Or, since `configure()` searches for a file named `swerve.json` in the current
  working directory, you can save your settings in that file, or call `save()`
  at some point in your application.

Finally, once you've configured your feature settings, you need to set the current environment:

```coffeescript
Swerve.setEnv('development')
```

### Saving configuration

You can save the state of your current configuration at any time by calling
`.save()`. This function takes a single, optional file name argument, which
defaults to `swerve.json`.

## Feature flipping

Now you can toggle different blocks of code throughout your app based on enabled features.

```coffeescript
if Swerve.feature('notifications')
  # Code for new notifications feature
else
  # Current code without new notifications
```

`Swerve.feature()` returns the value from the configuration (or URL param, see
section below). While you usually set the value to either `true` or `false`, you
have the flexibility of setting it to whatever you may need (i.e. a hash of
settings for that feature for each environment).

## Toggling on the fly

A feature can be enabled by calling `Swerve.enable('notifications')` for
example, which simply sets that feature to `true` under the current environment.
You can optionally set the feature to a value:

```coffeescript
notification_options =
  gutter:  true
  disrupt: false
Swerve.enable 'notifications', notification_options
```

Similarly, a feature can be disabled (set to `false`) by calling
`Swerve.disable('notifications')`.

## Toggling with URL parameters

Features can also be enabled or disabled by passing in the feature name as a
query string in the URL. These params take precedence over those set in the
configuration.

So if we visit `http://www.example.com?notifications=true` in our production
environment, then that feature will be considered enabled, regardless of the
setting passed in through the original configuration.

## License

Copyright 2013 Jico Baligod.

Licensed under the [MIT License](http://github.com/jico/swerve/raw/master/LICENSE).
