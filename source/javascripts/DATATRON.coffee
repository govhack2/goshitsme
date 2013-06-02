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
      url: 'api/questions.json'
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
        answer.ratio = new Probability(option.count, 21504702)
        answer
      # q.answers = _.sortBy q.answers, (answer) -> answer.value
      q
