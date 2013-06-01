dieFaces = ['&#x2680;', '&#x2681;', '&#x2682;', '&#x2683;', '&#x2684;', '&#x2685;']
values = ['yes', 'no', 'harry', 'indeed', '23cm', '85kg']

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

$ ->
  buttons = $('.questions .btn')

  _.each buttons, (button) ->
    $(button).html(gimmeFace)

  buttons.on 'click', (e) =>
    button = $(e.target)
    commenceRollin button, ->
      button.siblings('input').val(values[rand(values.length)])
