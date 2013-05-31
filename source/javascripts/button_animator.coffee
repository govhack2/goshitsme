dieFaces = ['&#x2680;', '&#x2681;', '&#x2682;', '&#x2683;', '&#x2684;', '&#x2685;']

faceMe = ->
  dieFaces[Math.round(Math.random() * dieFaces.length)]

$ ->
  $('.questions .btn').on 'click', (e) =>
    button = $(e.target)
    button.html(faceMe)

