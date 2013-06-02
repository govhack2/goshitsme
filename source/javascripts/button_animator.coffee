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
  button.siblings('input').val(if randomAnswer then randomAnswer.value else 'no answers')

newFace = (button, onDone) ->
  spins = button.data('spins')
  if spins > 0
    setFace(button, gimmeFace())
    gimmeAnswer(button)
    button.data('spins', spins - 1)
    setTimeout((->newFace(button, onDone)), 65)
  else
    onDone() if onDone

commenceRollin = (button, onDone)->
  unless button.data('spins')
    button.data('spins', 6)

  newFace button

  setTimeout((->newFace(button, ->
      onDone() if onDone
    )), 65)

# Pick a random sound based on the Sound Choice category
playSound = ->
  numSounds = soundIds["Dice"].length
  id = soundIds["Dice"][rand(numSounds)]
  sound = $('#'+id)[0]
  sound.playbackRate = _.random(50, 90) / 100 if sound.playbackRate
  sound.play()

$ ->

  $('.questions').on 'change', 'select', (e) ->
    select = $(@)
    select.closest('.question').data("question").dropdownSelected()

  $('.questions').on 'click', '.autoroll-button', (e) ->
    button = $(@)
    button.closest('.question').data("question").autorollButtonClicked()

  $('.questions').on 'click', '.answer-and-dice', (e) ->
    button = $(@)
    playSound()
    button.closest('.question').data("question").clicked()
    commenceRollin button, ->
      # the final (non-rollin') answer must be weighted random
      question = button.closest('.question').data("question")
      randomAnswer = question.weightedRandomAnswer()
      question.setAnswer(randomAnswer)

  source   = $("#question-template").html()
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

      answer_selector = element.find("select.answer-selector")
      answer_selector.append($("<option />").text('Choose Answer').attr('disabled', true).attr('selected', true))
      $.each question.answers, ->
        answer_selector.append($("<option />").val(this.value).text(this.value))


    _.each $('.dice'), (button) ->
      setFace(button, gimmeFace())

