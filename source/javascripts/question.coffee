
class window.Question
  idCount = 0
  autorollThresholdClicks = 10

  @summarise: ->
    finishMessageTemplate = Handlebars.compile( $("#finish-message-template").html() )
    answeredQuestions = _.map $(".question:visible"), (question_dom) ->
      $(question_dom).data("question")

    unique_questions = (question for question in answeredQuestions when question.answer && question.answer.ratio.percentage() <= 25)
    $('#finish-messages').html("")

    # add to dom
    _.each unique_questions, (question) ->
      element = $(finishMessageTemplate(question))
      $('#finish-messages').append(element)

    totalQuestions = $(".question").length
    if unique_questions.length > 5
      $("#finished-message").html("See! You are really unique!")
    else if unique_questions.length > 3
      $("#finished-message").html("See, you're different to the rest.")
    else if answeredQuestions.length == totalQuestions.length
      $("#finished-message").html("Ok, I guess you're average :(")
    else if answeredQuestions.length >= 2
      $("#finished-message").html("Hmm, still kind of average...")
    else
      $("#finished-message").html("Ok, get started above.")

  constructor: (@name, @desc, @source, @answers, @selectedAnswers) ->
    @clickCount = 0
    @autorollClickCount = 0
    @id = idCount
    @answer = null
    idCount++

  randomAnswer: () ->
    @answers[Math.floor(Math.random() * @answers.length)]

  setAnswer: (answer)=>
    @answer = answer
    $d = @dom()
    $dice = $d.find('.dice')
    $dice.siblings('input').val(if answer then answer.value else 'no answers')
    probabilityText = "You and #{answer.ratio.toString()} of the population"
    $sourceElement = $dice.closest('.question').find('.source').html(probabilityText)
    $sourceElement.fadeIn('fast') unless $sourceElement.is(':visible')

  findAnswer: (value)=>
    return null unless @answers.length > 0
    answer = a for a in @answers when a.value == value
    return answer

  weightedRandomAnswer: () ->
    return null unless @answers.length > 0

    sortedAnswers = _.sortBy @answers, (answer) -> answer.probability.numerator

    total = 0

    slices = _.map sortedAnswers, (answer) =>
      group = answer.probability.percentage()
      [total = group + total, answer]

    randomPercentage = Math.floor(Math.random() * 100)

    winner = _.find(slices, (slice) -> slice[0] >= randomPercentage)

    if winner
      winner[1]
    else
      slices[slices.count-1]
    # (return slice) for slice in slices when slice > randomPercentage

  dom: =>
    $("#question-#{@id}")

  showDropdown: =>
    $d = @dom()
    $d.find(".label").hide()
    $d.find(".answer-and-dice").hide()
    $d.find(".message").show()
    $d.find(".autoroll-select").show()

  hideDropdown: =>
    $d = @dom()
    $d.find(".label").show()
    $d.find(".answer-and-dice").show()
    $d.find(".message").hide()
    $d.find(".autoroll-select").hide()

  autoRoll: =>
    $d = @dom()
    @answerToAutoFind = @findAnswer($d.find("select").val())
    button = $d.find("button.dice")
    question = this

    donefn = =>
      @clickCount++
      randomAnswer = question.weightedRandomAnswer()
      if randomAnswer == @answerToAutoFind
        @setAnswer(@answerToAutoFind)
        Question.summarise()
      else
        @setAnswer(randomAnswer)
        commenceRollin button, donefn, 1

    commenceRollin button, donefn, 1

  dropdownSelected: =>
    $d = @dom()
    @hideDropdown()
    @hideAutorollButton()
    @autoRoll()
    @autorollClickCount = 0

  showAutorollButton: =>
    $d = @dom()
    $d.find('.autoroll-button').show()

  hideAutorollButton: =>
    $d = @dom()
    $d.find('.autoroll-button').hide()

  autorollButtonClicked: =>
    $d = @dom()
    if $d.find(".autoroll-select").is(":visible")
      @hideDropdown()
    else
      @showDropdown()

  clicked: =>
    @clickCount++
    @autorollClickCount++
    if @autorollClickCount == autorollThresholdClicks
      # Show the auto-roll functionality
      @showAutorollButton()
