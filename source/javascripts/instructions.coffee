$ ->
  buttons = $('.instruction .close')

  buttons.on 'click', (e) =>
    button = $(e.target)
    div = button.closest('.instruction')
    div.addClass("fadeout")