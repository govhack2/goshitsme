
$ ->
  source   = $("#question-template").html()
  template = Handlebars.compile(source)

  DATATRON.get_questions (questions)->
    for question in questions
      html = template(question)
      element = $(html)
      element.data('question', question)
      $('.questions').append( element )
