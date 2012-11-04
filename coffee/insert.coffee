$(document).ready ->
  conceptSelector()

conceptSelector = ->
  $.ajax(
    type: "GET"
    url: "http://wako3.u-aizu.ac.jp:8080/service/adl/"
    dataType: "json"
    success: (json) ->
      for k, v of json.adl
        $("#concept").append($("<option>").val(v).text(v))
      $("#concept").change ->
        getConcept $("#concept").val()
  )

getConcept = (name) ->
  $.ajax(
    type: "GET"
    # for Degug
    # url: "http://wako3.u-aizu.ac.jp:8080/service/adl/" + name
    url: "http://wako3.u-aizu.ac.jp:8080/service/concept/" + name
    dataType: "json"
    success: (json) ->
      parseConcept json
  )

parseConcept = (json) ->
  parseAdl = (key, json) ->
    key = key.replace(/\./g, "___")
    name = "undefined"
    for k, v of json
      if k is "name"
        name = v
        $("#insert").append("<br />")
        $("#insert").append("<h3>#{name}</h3>")
        $("#insert").append($("<table>").attr("id", "#{key}").attr("class", "adl"))
      else
        $("##{key}").append("<tr><th colspan=\"2\">#{k}</th></tr>")
        parseData key, v

  parseData = (name, array) ->
    concept = for x in array then conceptBuilder(x)
    for c in concept
      $("##{name}").append(c.getHtml())

  # for Debug
  # parseAdl json
  $("#insert").append("<br />").append("<h3>Basic Data</h3>")
  $("#insert").append($("<table>").attr("class", "adl2").append("""<tr><td>Patient Name</td><td><input type="text" name="pname" class="obj" /></td></tr>"""))
  for k, v of json
    parseAdl k, v
  submit = $("<input>").attr("type", "submit").attr("value", "add data")
  $("#insert").append($("<h4>").append(submit))
  submit.click ->
    addData()

addData = ->
  validate = (data) ->
    val = data.val()
    if data.attr("min")?
      if parseInt(val) < parseInt(data.attr("min"))
        val = data.attr("min")
    if data.attr("max")?
      if parseInt(data.attr("max")) < parseInt(val)
        val = data.attr("max")
    val

  json = {}
  pname = validate($("[name=pname]"))
  json.pname = pname
  table = $(".adl")
  for t in table
    id = $(t).attr("id")
    json["#{id}"] = {}
    input = $(".obj", t)
    for i in input
      val = validate($(i))
      path = $(i).attr("name")
      json["#{id}"]["#{path}"] = val

  $.ajax(
    type: "POST"
    url: "http://wako3.u-aizu.ac.jp:8080/service/insert"
    contentType: "text/json"
    data: JSON.stringify(json)
    success: (res) ->
      alert res
  )

