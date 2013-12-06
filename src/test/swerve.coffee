expect = require('expect.js')
fs     = require('fs')
jsdom  = require('jsdom')
rimraf = require('rimraf')
Swerve = require('../lib/swerve')

describe 'Swerve', ->
  cwd     = process.cwd()
  testDir = "#{__dirname}/swerve_test"

  clean = -> rimraf.sync(testDir)

  beforeEach ->
    @mock_config =
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

    process.chdir(cwd)
    clean()
    fs.mkdirSync  testDir
    process.chdir testDir

    # Reset
    `window = jsdom.createWindow()`
    `window.location.href = 'http://www.example.com'`
    Swerve.reset()

  after ->
    process.chdir(cwd)
    clean()

  describe '.reset', ->
    it 'resets Swerve object and clears configuration', ->
      Swerve.configure(@mock_config)
      Swerve.setEnv('development')
      expect(Swerve.configuration).not.to.be(undefined)
      expect(Swerve.env).not.to.be(undefined)
      expect(Swerve.feature_one).not.to.be(undefined)
      Swerve.reset()
      expect(Swerve.configuration).to.be(undefined)
      expect(Swerve.env).to.be(undefined)
      expect(Swerve.feature_one).to.be(undefined)

  describe '.setEnv', ->
    it 'returns the environment', ->
      expect(Swerve.setEnv('development')).to.be('development')

    it 'sets the environment', ->
      Swerve.setEnv('development')
      expect(Swerve.env).to.be('development')

  describe '.configure', ->
    it 'returns the configuration', ->
      expect(Swerve.configure(@mock_config)).to.eql(@mock_config)

    it 'accepts a JSON object and caches the configuration', ->
      expect(Swerve.configuration).to.be(undefined)
      Swerve.configure @mock_config
      expect(Swerve.configuration).to.eql(@mock_config)

    it 'sets features as keys on the Swerve object', ->
      expect(Swerve.feature_one).to.be(undefined)
      expect(Swerve.feature_two).to.be(undefined)
      Swerve.configure @mock_config
      Swerve.setEnv 'development'
      expect(Swerve.feature_one).to.eql(@mock_config.development.feature_one)
      expect(Swerve.feature_two).to.eql(@mock_config.development.feature_two)

    it 'throws an error for features that will overwrite existing Swerve property', ->
      badConfig =
        development:
          feature_one: true
          enable:      true
      try
        Swerve.configure(badConfig)
      catch err
        expectedMessage = "Illegal feature names: enable"
        expect(err.message).to.eql(expectedMessage)

  describe '.feature', ->
    `window = jsdom.createWindow()`
    `window.location.href = 'http://www.example.com'`

    it 'returns feature value from cached configuration', ->
      Swerve.configure @mock_config
      Swerve.setEnv 'development'
      expect(Swerve.feature('feature_one')).to.be(true)
      expect(Swerve.feature('feature_two')).to.eql(@mock_config.development.feature_two)

    it 'returns undefined for environments undefined', ->
      Swerve.configure @mock_config
      Swerve.setEnv 'nonexistent_env'
      expect(Swerve.feature('feature_one')).to.be(undefined)

    it 'returns undefined for features undefined', ->
      Swerve.configure @mock_config
      Swerve.setEnv 'development'
      expect(Swerve.feature('feature_three')).to.be(undefined)

    it 'allows url params to override environment feature settings', ->
      `window = jsdom.createWindow()`
      `window.location.href = 'http://www.example.com?feature_one=false'`
      Swerve.configure @mock_config
      Swerve.setEnv 'development'
      expect(Swerve.feature('feature_one')).to.eql(false)

    it 'allows url params to set feature even if feature undefined in environment', ->
      `window = jsdom.createWindow()`
      `window.location.href = 'http://www.example.com?feature_one=true'`
      Swerve.configure @mock_config
      Swerve.setEnv 'nonexistent_env'
      expect(Swerve.feature('feature_one')).to.eql(true)

  describe '.enable', ->
    it 'enables a feature by setting it to true', ->
      Swerve.configure @mock_config
      Swerve.setEnv 'production'
      expect(Swerve.feature('feature_one')).to.be(false)
      Swerve.enable 'feature_one'
      expect(Swerve.feature('feature_one')).to.be(true)

    it 'allows a feature to be enabled with a value', ->
      Swerve.configure @mock_config
      Swerve.setEnv 'production'
      expect(Swerve.feature('feature_one')).to.be(false)
      Swerve.enable 'feature_one', foo: 'bar'
      expect(Swerve.feature('feature_one')).to.eql(foo: 'bar')

    it 'returns undefined for undefined features', ->
      Swerve.configure @mock_config
      Swerve.setEnv 'production'
      expect(Swerve.enable('nonexistent_feature')).to.be(undefined)

  describe '.disable', ->
    it 'disables a feature by setting it to false', ->
      Swerve.configure @mock_config
      Swerve.setEnv 'development'
      expect(Swerve.feature('feature_one')).to.be(true)
      Swerve.disable 'feature_one'
      expect(Swerve.feature('feature_one')).to.be(false)

    it 'returns undefined for undefined features', ->
      Swerve.configure @mock_config
      Swerve.setEnv 'development'
      expect(Swerve.disable('nonexistent_feature')).to.be(undefined)

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
