class window.Probability
  constructor: (@numerator, @denominator) ->

  toString: () ->
    "#{@percentage()}%"

  percentage: ->
    return 0 unless @numerator and @denominator
    # Calculate percentage to 0dp:
    result = Math.round((@numerator / @denominator) * 100)
    if result < 1
      # Calculate to 3dp:
      result = Math.round((@numerator / @denominator) * 100000) / 1000
    result
