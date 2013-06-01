class window.Source
  constructor: (@name, @license, @attribution, @year) ->

  toString: ->
    if @attribution then "#{@attribution} (#{@year})" else "Source unknown."
