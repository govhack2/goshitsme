class window.DATATRON
  constructor: ($, _, onReady)->
    $.ajax
      url: 'data.json'
      success: (data, textStatus, jqXHR) =>
        @data = data
        onReady() if onReady

  questions: ->
    _.map @data.dimensions, (dimension)=>
      name: dimension.label
      desc: dimension.description
      sourceName: 'department of fake departments'
      sourceUrl: 'http://fake.gov.au/'




