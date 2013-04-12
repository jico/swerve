module.exports =
  setEnv: (env) ->
    @env = env

  configure: (configuration) ->
    @configuration = configuration

  feature: (name) ->
    config = @configuration[@env]
    if config[name]?
      if @urlParamPresent(name) then @getUrlParam(name) else config[name]
    else
      undefined

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
