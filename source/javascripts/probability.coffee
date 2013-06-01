class window.Probability
  constructor: (@numerator, @denominator) ->

  toString: () ->
    # TODO: simplify?
    "#{@numerator} in #{@denominator} chance"
