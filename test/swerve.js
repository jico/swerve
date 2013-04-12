// Generated by CoffeeScript 1.6.2
(function() {
  var Swerve, expect, jsdom;

  expect = require('expect.js');

  jsdom = require('jsdom');

  Swerve = require('../lib/swerve');

  describe('Swerve', function() {
    var mock_config;

    mock_config = {
      development: {
        feature_one: true,
        feature_two: {
          setting_one: true,
          setting_two: true
        }
      },
      production: {
        feature_one: false,
        feature_two: {
          setting_one: true,
          setting_two: false
        }
      }
    };
    describe('.setEnv', function() {
      return it('sets the environment', function() {
        expect(Swerve.env).to.be(void 0);
        Swerve.setEnv('development');
        return expect(Swerve.env).to.be('development');
      });
    });
    describe('.configure', function() {
      return it('caches the configuration', function() {
        expect(Swerve.configuration).to.be(void 0);
        Swerve.configure(mock_config);
        return expect(Swerve.configuration).to.eql(mock_config);
      });
    });
    describe('.feature', function() {
      window = jsdom.createWindow();
      window.location.href = 'http://www.example.com';      it('returns feature value from cached configuration', function() {
        Swerve.configure(mock_config);
        Swerve.setEnv('development');
        expect(Swerve.feature('feature_one')).to.be(true);
        return expect(Swerve.feature('feature_two')).to.eql(mock_config.development.feature_two);
      });
      it('returns undefined for features undefined', function() {
        Swerve.configure(mock_config);
        Swerve.setEnv('development');
        return expect(Swerve.feature('feature_three')).to.be(void 0);
      });
      return it('allows url params to override environment feature settings', function() {
        window = jsdom.createWindow();
        window.location.href = 'http://www.example.com?feature_one=false';        Swerve.configure(mock_config);
        Swerve.setEnv('development');
        return expect(Swerve.feature('feature_one')).to.eql(false);
      });
    });
    describe('.urlParamPresent', function() {
      return it('checks existence of url param', function() {
        window = jsdom.createWindow();
        window.location.href = 'http://www.example.com?feature_one=yes';        expect(Swerve.urlParamPresent('feature_one')).to.be(true);
        return expect(Swerve.urlParamPresent('feature_two')).to.be(false);
      });
    });
    return describe('.getUrlParam', function() {
      it('gets value of given key from current href', function() {
        window = jsdom.createWindow();
        window.location.href = 'http://www.example.com?feature_one=yes';        return expect(Swerve.getUrlParam('feature_one')).to.be('yes');
      });
      return it('casts value appropriately by default', function() {
        window = jsdom.createWindow();
        window.location.href = 'http://www.example.com?one=true&two=10';        expect(Swerve.getUrlParam('one')).to.be(true);
        expect(Swerve.getUrlParam('one')).to.be.a('boolean');
        expect(Swerve.getUrlParam('two')).to.be(10);
        return expect(Swerve.getUrlParam('two')).to.be.a('number');
      });
    });
  });

}).call(this);