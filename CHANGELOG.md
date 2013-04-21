# Changelog

## v0.4.0 - 2013-04-21

* Added `.reset` for pristine `Swerve` object.
* Features are now set as properties on `Swerve` object.
* Throw error if feature name (in any environment) in passed configuration
  conflicts with existing `Swerve` property.

## v0.3.0 - 2013-04-20

* Added `.save` function to save current configuration to file.
* Calling `.configure` with no arguments looks for `swerve.json` config file by
  default.
* `.configure` throws error if `swerve.json` or passed file name is not found.

## v0.2.0 - 2013-04-14

* Added `.enable` and `.disable` functions for toggling features on the fly.

## v0.1.0 - 2013-04-13

* `.configure` accepts a JSON file name.

## v0.0.3 - 2013-04-12

* URL params enable a feature even if feature is `undefined` in current env.

## v0.0.2 - 2013-04-12

* Return undefined if `env` is not defined.
