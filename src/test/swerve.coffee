expect = require('expect.js')
jsdom  = require('jsdom')
Swerve = require('../lib/swerve')

describe 'Swerve', ->
  mock_config =
    development:
      feature_one: true
      feature_two:
        setting_one: true
        setting_two: true
    production:
      feature_one: false
      feature_two:
        setting_one: true
        setting_two: false

  describe '.setEnv', ->
    it 'sets the environment', ->
      expect(Swerve.env).to.be(undefined)
      Swerve.setEnv('development')
      expect(Swerve.env).to.be('development')

  describe '.configure', ->
    it 'caches the configuration', ->
      expect(Swerve.configuration).to.be(undefined)
      Swerve.configure mock_config
      expect(Swerve.configuration).to.eql(mock_config)

  describe '.feature', ->
    `window = jsdom.createWindow()`
    `window.location.href = 'http://www.example.com'`

    it 'returns feature value from cached configuration', ->
      Swerve.configure mock_config
      Swerve.setEnv 'development'
      expect(Swerve.feature('feature_one')).to.be(true)
      expect(Swerve.feature('feature_two')).to.eql(mock_config.development.feature_two)

    it 'returns undefined for environments undefined', ->
      Swerve.configure mock_config
      Swerve.setEnv 'nonexistent_env'
      expect(Swerve.feature('feature_one')).to.be(undefined)

    it 'returns undefined for features undefined', ->
      Swerve.configure mock_config
      Swerve.setEnv 'development'
      expect(Swerve.feature('feature_three')).to.be(undefined)

    it 'allows url params to override environment feature settings', ->
      `window = jsdom.createWindow()`
      `window.location.href = 'http://www.example.com?feature_one=false'`
      Swerve.configure mock_config
      Swerve.setEnv 'development'
      expect(Swerve.feature('feature_one')).to.eql(false)

    it 'allows url params to set feature even if feature undefined in environment', ->
      `window = jsdom.createWindow()`
      `window.location.href = 'http://www.example.com?feature_one=true'`
      Swerve.configure mock_config
      Swerve.setEnv 'nonexistent_env'
      expect(Swerve.feature('feature_one')).to.eql(true)

  describe '.urlParamPresent', ->
    it 'checks existence of url param', ->
      `window = jsdom.createWindow()`
      `window.location.href = 'http://www.example.com?feature_one=yes'`
      expect(Swerve.urlParamPresent('feature_one')).to.be(true)
      expect(Swerve.urlParamPresent('feature_two')).to.be(false)

  describe '.getUrlParam', ->
    it 'gets value of given key from current href', ->
      `window = jsdom.createWindow()`
      `window.location.href = 'http://www.example.com?feature_one=yes'`
      expect(Swerve.getUrlParam('feature_one')).to.be('yes')

    it 'casts value appropriately by default', ->
      `window = jsdom.createWindow()`
      `window.location.href = 'http://www.example.com?one=true&two=10'`
      expect(Swerve.getUrlParam('one')).to.be(true)
      expect(Swerve.getUrlParam('one')).to.be.a('boolean')
      expect(Swerve.getUrlParam('two')).to.be(10)
      expect(Swerve.getUrlParam('two')).to.be.a('number')
