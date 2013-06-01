class window.Source
  constructor: (@name, @license, @attribution, @year) ->

  toString: ->
    "#{@attribution} (#{@year})"
