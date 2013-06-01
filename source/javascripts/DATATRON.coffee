class window.DATATRON

  @datatron = null

  @get_questions: (callback)->
    if @datatron
      callback( @datatron.questions )
    else
      @datatron = new DATATRON (datatron)->
        @datatron = datatron
        callback @datatron.questions

  constructor: (onReady)->
    $.ajax
      url: 'data.json'
      success: (data, textStatus, jqXHR) =>
        @questions = @_mapQuestions(data)
        onReady(@) if onReady

  questions: ->
    @questions

  _mapQuestions: (data) ->
    _.map data.questions, (question) =>
      q = new Question
      q.name = question.label
      q.desc = question.description
      q.source = new Source(question.name, question.license, question.attribution, question.year)
      q.answers = _.map question.answers, (option) =>
        answer = new Answer()
        answer.value = option.label
        answer.probability = new Probability(option.count, question.count)
        answer
      q
