class window.DATATRON
  constructor: ($, _, onReady)->
    $.ajax
      url: 'data.json'
      success: (data, textStatus, jqXHR) =>
        @data = data
        onReady() if onReady

  questions: ->
    _.map @data.dimensions, (dimension)=>
      question = new Question
      question.name = dimension.label
      question.desc = dimension.description
      question.source = new Source('department of fake departments', 'http://fake.gov.au/')
      question




