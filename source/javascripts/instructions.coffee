$ ->
  buttons = $('.instruction .close')

  buttons.on 'click', (e) =>
    button = $(e.target)
    div = button.parent('.instruction')
    div.addClass("fadeout")