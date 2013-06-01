dieFaces = ['&#x2680;', '&#x2681;', '&#x2682;', '&#x2683;', '&#x2684;', '&#x2685;']
values = ['yes', 'no', 'harry', 'indeed', '23cm', '85kg']

# Sound types
diceIds = ["dice1", "dice2"]
laughIds = ["laugh1", "laugh2", "laugh3", "laugh4", "laugh5", "laugh6"]
randomIds = ["random1", "random2"]
soundIds = { "Dice": diceIds, "Laugh": laughIds, "Random": randomIds }

rand = (max, min = 0) ->
  n = Math.round(Math.random() * max)
  if n > min then n else min

gimmeFace = ->
  console.log 'giving face'
  dieFaces[rand(dieFaces.length)]

newFace = (button, onDone) ->
  spins = button.data('spins')
  if spins > 0
    button.html(gimmeFace())
    button.siblings('input').val(values[rand(values.length)])
    button.data('spins', spins - 1)
    setTimeout((->newFace(button, onDone)), 65)
  else
    onDone()

commenceRollin = (button, onDone)->
  unless button.data('spins')
    button.data('spins', 5)

  setTimeout((->newFace(button, onDone)), 65)

# Pick a random sound based on the Sound Choice category
playSound = ->
  numSounds = soundIds[$('#soundChoice').text()].length
  id = soundIds[$('#soundChoice').text()][rand(numSounds-1)]
  $('#'+id)[0].play()

$ ->
  buttons = $('.questions .btn')

  _.each buttons, (button) ->
    $(button).html(gimmeFace)

  buttons.on 'click', (e) =>
    button = $(e.target)
    playSound()
    commenceRollin button, ->
      button.siblings('input').val(values[rand(values.length)])

  # Cycle through the sound choice catergories on click:
  $soundChoice = $('#soundChoice')
  $soundChoice.on 'click', (e) =>
    if $soundChoice.text() == "Dice"
      $soundChoice.text("Laugh")
    else if $soundChoice.text() == "Laugh"
      $soundChoice.text("Random")
    else if $soundChoice.text() == "Random"
      $soundChoice.text("Dice")



