$ ->
  $('body').on 'click', '.instruction .close', (e) ->
    button = $(this)
    div = button.closest('.instruction')
    div.addClass("fadeout")