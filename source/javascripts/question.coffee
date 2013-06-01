class window.Question
  constructor: (@name, @desc, @source, @answers, @selectedAnswers) ->
    @clickCount = 0

  randomAnswer: ->
    return null unless @answers.length > 0

    sortedAnswers = _.sortBy @answers, (answer) -> answer.probability.numerator

    total = 0

    slices = _.map sortedAnswers, (answer) =>
      group = answer.probability.percentage()
      [total = group + total, answer]

    randomPercentage = Math.floor(Math.random() * 100)

    winner = _.find(slices, (slice) -> slice[0] >= randomPercentage)

    winner[1] || slices[slices.count-1]
    # (return slice) for slice in slices when slice > randomPercentage

  clicked: ->
    @clickCount++
    if @clickCount == 5
      alert("5")
