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
    _.map data.dimensions, (dimension) =>
      question = new Question
      question.name = dimension.label
      question.desc = dimension.description
      question.source = new Source('department of fake departments', 'http://fake.gov.au/')
      question.answers = _.map dimension.options, (option) =>
        answer = new Answer()
        answer.value = option.label
        answer.probability = new Probability(option.count, dimension.count)
        answer
      question




