
$ ->
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
