dieFaces = [1,2,3,4,5,6]

# Sound types
diceIds = ["dice1", "dice2"]
laughIds = ["laugh1", "laugh2", "laugh3", "laugh4", "laugh5", "laugh6"]
randomIds = ["random1", "random2"]
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
  answers = question.answers
  randomAnswer = answers[rand(answers.length)]
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
  numSounds = soundIds[$('#soundChoice').text()].length
  id = soundIds[$('#soundChoice').text()][rand(numSounds-1)]
  $('#'+id)[0].play()

$ ->
  $('.questions').on 'click', '.dice', (e) ->
    button = $(@)
    playSound()
    commenceRollin button, ->
      sourceElement = button.closest('.question').find('.source')
      sourceElement.fadeIn('fast') unless sourceElement.is(':visible')

  # Cycle through the sound choice catergories on click:
  $soundChoice = $('#soundChoice')
  $soundChoice.on 'click', (e) =>
    if $soundChoice.text() == "Dice"
      $soundChoice.text("Laugh")
    else if $soundChoice.text() == "Laugh"
      $soundChoice.text("Random")
    else if $soundChoice.text() == "Random"
      $soundChoice.text("Dice")



