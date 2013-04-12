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

Require Swerve and passing a hash of feature settings for each environment.
Typically, you'll want Swerve globally available throughout your app.

```coffeescript
Swerve = require('swerve')
Swerve.configure
  development:
    notifications: true
  production:
    notifications: false
```

Set the current environment.

```coffeescript
Swerve.setEnv('development')
```

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
