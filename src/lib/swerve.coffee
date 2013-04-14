fs = require('fs')

module.exports =
  setEnv: (env) ->
    @env = env

  configure: (configuration) ->
    if typeof configuration == 'string' && fs.existsSync(configuration)
      @configuration = JSON.parse fs.readFileSync(configuration)
    else
      @configuration = configuration

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
