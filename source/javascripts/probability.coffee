class window.Probability
  constructor: (@numerator, @denominator) ->

  toString: () ->
    "#{@percentage()}%"

  percentage: ->
    return 0 unless @numerator and @denominator
    Math.round((@numerator / @denominator) * 100, 2)
