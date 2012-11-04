conceptBuilder = (json) ->
  switch json.dataType
    when "DvQuantity"
      new DvQuantity(json)
    when "DV_CODED_TEXT"
      new DvCodedText(json)
    when "DV_BOOLEAN"
      new DvBoolean(json)
    when "DV_TEXT"
      new DvText(json)
    when "DV_COUNT"
      new DvCount(json)
    when "DvOrdinal"
      new DvOrdinal(json)
    when "DV_MULTIMEDIA"
      new DvMultiMedia(json)
    when "DV_DATE_TIME"
      new DvDateTime(json)
    when "DV_INTERVAL"
      new DvInterval(json)
    when "DV_PROPORTION"
      new DvProportion(json)
    when "DV_URI"
      new DvUri(json)
    when "DvMultipleElements"
      new DvMultipleElements(json)
    when "DvCluster"
      new DvCluster(json)
    else
      new DvAny(json)

class Concept
  constructor: (json) ->
    @name = json.name
    @path = json.path

  inputBuilder: (form, type="", value="") ->
    switch form
      when "input"
        $("<input>").attr("type", type).attr("value", value).attr("name", @path).attr("class", "obj")
      when "select"
        $("<select>").attr("name", @path).attr("class", "obj").append("""<option value="">Please Select</option>""")
      else
        $("<span>")

  getHtml: ->
    $("<tr>").append($("<td>").text(@name))

class DvQuantity extends Concept
  constructor: (json) ->
    super json
    @path = @path + "/magnitude"
    @unitPath = @path.replace("/magnitude", "/units")
    @min  = json.min
    @max  = json.max
    @unit = json.unit
  getHtml: ->
    @input = @inputBuilder("input", "number", @min[0]).attr("min", @min[0]).attr("max", @max[0])
    @unitSelecter = $("<select>").attr("class", "obj").attr("name", @unitPath)
    for k, v in @unit
      @unitSelecter.append("<option value=\"#{k}\">#{k}</option>")
    @unitSelecter.change =>
      idx = @unitSelecter.val()
      $(@input).attr("min", @min[idx]).attr("max", @max[idx])
    super.append($("<td>").append(@input).append(" ").append(@unitSelecter))

class DvCodedText extends Concept
  constructor: (json) ->
    super json
    @codeList = json.codeList
  getHtml: ->
    select = @inputBuilder("select")
    for code in @codeList
      select.append("<option value=\"#{code}\">#{code}</option>")
    super.append($("<td>").append(select))

class DvBoolean extends Concept
  constructor: (json) ->
    super json
  getHtml: ->
    super.append($("<td>").append(@inputBuilder("select").append("""<option value="true">true</option>""").append("""<option value="false">false</option>""")))

class DvText extends Concept
  constructor: (json) ->
    super json
  getHtml: ->
    super.append($("<td>").append(@inputBuilder("input", "text").attr("placeholder", "Free Text")))

class DvCount extends Concept
  constructor: (json) ->
    super json
    @min  = json.min
    @max  = json.max
  getHtml: ->
    super.append($("<td>").append(@inputBuilder("input", "number", @min).attr("min", @min).attr("max", @max)))

class DvOrdinal extends Concept
  constructor: (json) ->
    super json
    @codeList = json.codeList
  getHtml: ->
    select = @inputBuilder("select")
    for c in @codeList
      select.append("<option value=\"#{c._1}\">#{c._2}</option>")
    super.append($("<td>").append(select))

class DvMultiMedia extends Concept
  constructor: (json) ->
    super json
    @codeList = json.codeList
  getHtml: ->
    select = @inputBuilder("select")
    for c in @codeList
      select.append("<option value=\"#{c}\">#{c}</option>")
    super.append($("<td>").append(select))

class DvDateTime extends Concept
  constructor: (json) ->
    super json
  getHtml: ->
    date = new Date()
    today = date.getFullYear()  + "-" + (date.getMonth() + 1) + "-" + date.getDate() + "-" + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds()
    super.append($("<td>").append(@inputBuilder("input", "text", today).attr("min", "1990-01-01-00:00:00").attr("max", today)))

class DvInterval extends Concept
  constructor: (json) ->
    super json
    @interval = json.interval
  getHtml: ->
    newTable = $("<table>").attr("class", "adl2")
    for c in @interval
      cc = conceptBuilder(c)
      newTable.append(cc.getHtml())
    super.append($("<td>").append(newTable))

class DvProportion extends Concept
  constructor: (json) ->
    super json
    @minNum = json.minNum
    @maxNum = json.maxNum
    @minDen = json.minDen
    @maxDen = json.maxDen
  getHtml: ->
    super.append($("<td>").append(@inputBuilder("input", "number", @minNum).attr("min", @minNum).attr("max", @maxNum)).append(" : ").
                 append("input", "number", @minDen).attr("min", @minDen).attr("max", @maxDen))

class DvUri extends Concept
  constructor: (json) ->
    super json
  getHtml: ->
    super.append($("<td>").append(@inputBuilder("input", "url").attr("placeholder", "URL")))

class DvAny extends Concept
  constructor: (json) ->
    super json
  getHtml: ->
    super.append($("<td>").append("""<span class="any">[Any]<span>"""))

class DvCluster extends Concept
  constructor: (json) ->
    super json
    @cluster = json.cluster
  getHtml: ->
    newTable = $("<table>").attr("class", "adl2")
    for c in @cluster
      cc = conceptBuilder(c)
      newTable.append(cc.getHtml())
    super.append($("<td>").append(newTable))

class DvMultipleElements extends Concept
  constructor: (json) ->
    super json
    @elements = json.elements
  getHtml: ->
    newTable = $("<table>").attr("class", "adl2")
    for c in @elements
      cc = conceptBuilder(c._2)
      newTable.append(cc.getHtml())
    super.append($("<td>").append(newTable))

