fs   = require('fs')
path = require('path')

module.exports =
  setEnv: (env) ->
    @_keys or= Object.keys(@)
    @env     = env
    @setFeatureKeys()
    @env

  configure: (configuration) ->
    @_keys or= Object.keys(@)
    configuration or= 'swerve.json'
    if typeof configuration == 'string'
      filepath = path.join(process.cwd(), configuration)
      if fs.existsSync(filepath)
        configuration = JSON.parse(fs.readFileSync(filepath))
      else
        throw new Error('Invalid or missing configuration')

    if conflicts = @invalidConfig(configuration)
      throw new Error("Illegal feature names: #{conflicts}")
    else
      @configuration = configuration
      @setFeatureKeys()
      @configuration

  feature: (name) ->
    return @getUrlParam(name) if @urlParamPresent(name)

    config = @configuration[@env]
    if config?[name]? then config[name] else undefined

  enable: (name, value) ->
    config = @configuration[@env]
    value ?= true
    if config?[name]? then config[name] = value else undefined

  disable: (name) ->
    config = @configuration[@env]
    if config?[name]? then config[name] = false else undefined

  urlParamPresent: (name) ->
    regex = RegExp("#{name}=(.+?)(&|$)")
    match = (regex.exec(window.location.search) || [null,null])[1]
    match?

  getUrlParam: (name) ->
    regex = RegExp("#{name}=(.+?)(&|$)")
    match = (regex.exec(window.location.search) || [null,null])[1]
    @castVariable decodeURI(match)

  save: (file_path) ->
    fs.writeFileSync(file_path || 'swerve.json', JSON.stringify(@configuration))

  reset: ->
    if @configuration?[@env]?
      @[key] = undefined for key, _ of @configuration[@env]
    [@configuration, @env] = [undefined, undefined]

  # Private

  castVariable: (variable) ->
    switch variable
      when 'true'  then return true
      when 'false' then return false
      when 'null'  then return null
    if !isNaN(parseInt(variable)) && isFinite(variable)
      return parseInt(variable)
    if !isNaN(parseFloat(variable)) && isFinite(variable)
      return parseInt(variable)
    variable

  setFeatureKeys: ->
    if @configuration?[@env]?
      @[key] = value for key, value of @configuration[@env]

  invalidConfig: (configuration) ->
    conflicts = []
    for _, features of configuration
      for feature, _ of features
        conflicts.push(feature) if @_keys.indexOf(feature) >= 0
    if conflicts.length then conflicts else false
