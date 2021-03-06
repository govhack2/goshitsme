dieFaces = [1,2,3,4,5,6]

# Sound types
diceIds = ["dice1", "dice2"]
laughIds = []
randomIds = []
soundIds = { "Dice": diceIds, "Laugh": laughIds, "Random": randomIds }

rand = (max) ->
  Math.floor(Math.random() * max)

gimmeFace = ->
  dieFaces[rand(dieFaces.length)]

setFace = (button, face) ->
  die = $(button).find("div")
  die.removeClass()
  die.addClass("dieface")
  die.addClass("dieface#{face}")

gimmeAnswer = (button) ->
  question = button.closest('.question').data("question")
  randomAnswer = question.randomAnswer()
  button.closest('.question').find('input').val(if randomAnswer then randomAnswer.value else 'no answers')

newFace = (button, onDone) ->
  spins = button.data('spins')
  if spins > 0
    setFace(button, gimmeFace())
    gimmeAnswer(button)
    button.data('spins', spins - 1)
    setTimeout((->newFace(button, onDone)), 65)
  else
    onDone() if onDone

window.commenceRollin = (button, onDone, spinAmount=6)->
  unless button.data('spins')
    button.data('spins', spinAmount)

  newFace button, ->
      onDone() if onDone

# Pick a random sound based on the Sound Choice category
playSound = ->
  numSounds = soundIds["Dice"].length
  id = soundIds["Dice"][rand(numSounds)]
  sound = $('#'+id)[0]
  sound.playbackRate = _.random(50, 90) / 100 if sound.playbackRate
  sound.play()

nextAnswer = _.debounce ->
  return if lastAnswered.data('nextified')
  lastAnswered.data('nextified', true)
  hiddenAnswers = $('div.question:hidden')
  newThing = if hiddenAnswers.length == 0
    $('#finished').fadeIn('fast')
  else
    hiddenAnswers.first().fadeIn('fast')

  # unless lastAnswered.closest('.question').data("question").autorollButtonVisible()
  #   newThing[0].scrollIntoView()
, 1250

lastAnswered = null


$ ->

  $('.questions').on 'change', 'select', (e) ->
    select = $(@)
    select.closest('.question').data("question").dropdownSelected()

  $('.questions').on 'click', '.autoroll-button', (e) ->
    button = $(@)
    button.closest('.question').data("question").autorollButtonClicked()

  $('.questions').on 'click', '.answer-and-dice', (e) ->
    button = $(@)
    questionContainer = button.closest('.question')
    questionModel = questionContainer.data("question")
    return if questionModel.isAutoRolling()

    questionModel.clicked()
    playSound()
    lastAnswered = questionContainer
    commenceRollin button, ->
      # the final (non-rollin') answer must be weighted random
      question = button.closest('.question').data("question")
      randomAnswer = question.weightedRandomAnswer()
      question.setAnswer(randomAnswer)
      Question.summarise()
      nextAnswer()

  source   = $("#question-template").html()
  if source
    template = Handlebars.compile(source)

    DATATRON.get_questions (questions)->
      i = 0
      for question in questions
        if i++ == 1
          question.first = true

        html = template(question)
        element = $(html)
        element.data('question', question)
        $('.questions').append( element )
        element.show() if i == 1

        # populate dropdown
        answer_selector = element.find("select.answer-selector")
        answer_selector.append($("<option />").text('Choose Answer').attr('disabled', true).attr('selected', true))
        $.each question.answers, ->
          answer_selector.append($("<option />").val(this.value).text(this.value))


      _.each $('.dice'), (button) ->
        setFace(button, gimmeFace())
