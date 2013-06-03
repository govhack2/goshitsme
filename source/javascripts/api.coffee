states = ['NSW', 'VIC', 'QLD', 'SA', 'WA', 'TAS', 'NT', 'ACT', 'Other']

load_suburbs = (state) ->
  $("#suburb").hide();
  $("#statistics").hide();
  $("#statistics_link").hide();
  $("#statistics_link").empty();
  link = "http://www.statisticalme.com/api/#{state}/statistics.json"
  $('#statistics_link').append("<pre>\n        Link: <a href='#{link}'>#{link}</a>\n</pre>");
  $('#statistics_link').show();
  $.ajax
    url: link
    success: (data, textStatus, jqXHR) =>
      display_statistics(data);
  $.ajax
    url: "http://www.statisticalme.com/api/#{state}/questions.json"
    success: (data, textStatus, jqXHR) =>
      display_suburbs(data);

load_data = (state, suburb) ->
  suburb = suburb.replace /[ ]+/g, "_"
  $("#statistics_link").hide();
  $("#statistics_link").empty();
  link = "http://www.statisticalme.com/api/#{state}/#{suburb}/statistics.json"
  $('#statistics_link').append("<pre>\n        Link: <a href='#{link}'>#{link}</a>\n</pre>");
  $('#statistics_link').show();
  $.ajax
    url: link
    success: (data, textStatus, jqXHR) =>
      display_statistics(data);

display_suburbs = (data) ->
  state_selector = $("#state").find("select.state-selector")
  suburb_selector = $("#suburb").find("select.suburb-selector")
  suburb_selector.empty()
  suburb_selector.append($("<option />").text('Choose Answer').attr('disabled', true).attr('selected', true))
  _.map data.questions[0].answers, (suburb) =>
    suburb = suburb.label
    suburb_selector.append($("<option />").val(suburb).text(suburb))
  $("#suburb").show();
  $('.suburbs').on 'change', 'select', (e) ->
    state = state_selector.find(":selected").text()
    suburb = suburb_selector.find(":selected").text()
    load_data(state, suburb)

display_statistics = (data) ->
  $("#statistics").hide();
  $("#statistics").empty();
  html = window.statistics_template(data)
  element = $(html)
  element.data('statistics', data)
  $('#statistics').append(element)
  $("#statistics").show();

$ ->

  state_selector = $("#state").find("select.state-selector")
  if state_selector
    state_selector.append($("<option />").text('Choose Answer').attr('disabled', true).attr('selected', true))
    for state in states
      state_selector.append($("<option />").val(state).text(state))
    $("#state").show();
    link = "http://www.statisticalme.com/api/statistics.json"
    $('#statistics_link').append("<pre>\n        Link: <a href='#{link}'>#{link}</a>\n</pre>");
    $('#statistics_link').show();
    $.ajax
      url: link
      success: (data, textStatus, jqXHR) =>
        display_statistics(data);
    $('.states').on 'change', 'select', (e) ->
      state = state_selector.find(":selected").text()
      load_suburbs(state)
  source = $("#statistics-template").html()
  if source
    window.statistics_template = Handlebars.compile(source)
