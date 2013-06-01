class window.Probability
  constructor: (@numerator, @denominator) ->

  toString: () ->
    reduced = @reduce(@num)
    "#{reduced.numerator} in #{reduced.denominator} chance"

  # Reduce a fraction by finding the Greatest Common Divisor and dividing by it.
  reduce :() ->
    gcd = (a,b) ->
      if b then gcd(b, a % b) else a
    gcd = gcd(@numerator, @denominator)
    new Probability(@numerator/gcd, @denominator/gcd)
