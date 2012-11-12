conceptBuilder = (json, name) ->
  switch json.dataType
    when "DvQuantity"
      new DvQuantity(json, name)
    when "DV_CODED_TEXT"
      new DvCodedText(json, name)
    when "DV_BOOLEAN"
      new DvBoolean(json, name)
    when "DV_TEXT"
      new DvText(json, name)
    when "DV_COUNT"
      new DvCount(json, name)
    when "DvOrdinal"
      new DvOrdinal(json, name)
    when "DV_MULTIMEDIA"
      new DvMultiMedia(json, name)
    when "DV_DATE_TIME"
      new DvDateTime(json, name)
    when "DV_INTERVAL"
      new DvInterval(json, name)
    when "DV_PROPORTION"
      new DvProportion(json, name)
    when "DV_URI"
      new DvUri(json, name)
    when "DvMultipleElements"
      new DvMultipleElements(json, name)
    when "DvCluster"
      new DvCluster(json, name)
    else
      new DvAny(json, name)

class Concept
  constructor: (json, adlName) ->
    @name = json.name
    @adlName = adlName
    @path = @adlName + "." + json.path.replace(/\./g, "___")
    @type = json.dataType

  # <input type="text" value="@value" aqbe:path="@path" />
  inputBuilder: (placeholder="") ->
    $("<input>").attr("type", "text").attr("value", "").attr("aqbe:path", @path).attr("aqbe:type", @type).attr("placeholder", placeholder)

  # <input type="text" value="@value" aqbe:path="@path" id="fieldDate" />
  calenderBuilder: () ->
    @inputBuilder().attr("id", "fieldDate")

  # <select aqbe:path="@path"><option value="">Please Select</option></select>
  selectBuilder: (path=@path, type=@type, require=false) ->
    selecter = $("<select>").attr("aqbe:path", path).attr("aqbe:type", type)
    if require
      selecter
    else
      selecter.append("""<option value="">Please Select</option>""")

  # = != > < <= >= のセレクトボックス
  conditionBuilder: (type="text") ->
    selecter = $("<select>").attr("class", "condition")
    selecter.append("""<option value="0">=</option>""")
    selecter.append("""<option value="1">!=</option>""")
    selecter.append("""<option value="2">&gt;</option>""") if type is "number" # >
    selecter.append("""<option value="3">&lt;</option>""") if type is "number" # <
    selecter.append("""<option value="4">&gt;=</option>""") if type is "number" # >=
    selecter.append("""<option value="5">&lt;=</option>""") if type is "number" # <=
    selecter

  submitBuilder: () ->
    submitter = $("<input>").attr("type", "button").attr("class", "submit").val("add")
    submitter.click ->
      submit(submitter)
    submitter

  getHtml: (adlName) ->
    $("#pathList").append("#{@path},#{@name}\n")
    $("<tr>").append($("<td>").append($("<input>").attr("type","checkbox").attr("aqbe:path",@path).attr("class","selection")).append($("<span>").append(@name)))

class DvQuantity extends Concept
  constructor: (json, name) ->
    super json, name
    @path = @path + "/magnitude"
    @unitPath = @path.replace("/magnitude", "/units")
    @min  = if json.min[0]? then json.min else [-999999]
    @max  = if json.max? then json.max else [999999]
    @unit = json.unit
  getHtml: ->
    input = @inputBuilder("0.0").attr("aqbe:min", @min[0]).attr("aqbe:max", @max[0])
    unitSelecter = @selectBuilder(path=@unitPath, type="DvQuantityUnit", require=true)
    for k, v in @unit
      unitSelecter.append("<option value=\"#{v}\">#{k}</option>")
    unitSelecter.change =>
      index = unitSelecter.val()
      $(input).attr("aqbe:min", @min[index]).attr("aqbe:max", @max[index])
    super.append($("<td>").append(@conditionBuilder("number")).append(" ").append(input).append(" ").append(unitSelecter).append("<span class=\"error\">").append(@submitBuilder()))

class DvCodedText extends Concept
  constructor: (json, name) ->
    super json, name
    @codeList = json.codeList
  getHtml: ->
    select = @selectBuilder()
    for code in @codeList
      select.append("<option value=\"#{code}\">#{code}</option>")
    super.append($("<td>").append(@conditionBuilder()).append(select).append(@submitBuilder()))

class DvBoolean extends Concept
  constructor: (json, name) ->
    super json, name
  getHtml: ->
    super.append($("<td>").append(@selectBuilder().append("""<option value="true">true</option>""").append("""<option value="false">false</option>""")).append(@submitBuilder()))

class DvText extends Concept
  constructor: (json, name) ->
    super json, name
  getHtml: ->
    super.append($("<td>").append(@conditionBuilder()).append(" ").append(@inputBuilder("FreeText")).append(@submitBuilder()))

class DvCount extends Concept
  constructor: (json, name) ->
    super json, name
    @min  = if json.min? then json.min else -999999
    @max  = if json.max? then json.max else 999999
  getHtml: ->
    super.append($("<td>").append(@conditionBuilder("number")).append(" ").append(@inputBuilder("0").attr("aqbe:min", @min).attr("aqbe:max", @max)).append("<span class=\"error\">").append(@submitBuilder()))

class DvOrdinal extends Concept
  constructor: (json, name) ->
    super json, name
    @codeList = json.codeList
  getHtml: ->
    select = @selectBuilder()
    for c in @codeList
      select.append("<option value=\"#{c._1}\">#{c._2}</option>")
    super.append($("<td>").append(@conditionBuilder()).append(select).append(@submitBuilder()))

class DvMultiMedia extends Concept
  constructor: (json, name) ->
    super json, name
    @codeList = json.codeList
  getHtml: ->
    select = @selectBuilder()
    for c in @codeList
      select.append("<option value=\"#{c}\">#{c}</option>")
    super.append($("<td>").append(@conditionBuilder()).append(select).append(@submitBuilder()))

class DvDateTime extends Concept
  constructor: (json, name) ->
    super json, name
  getHtml: ->
    super.append($("<td>").append(@conditionBuilder("number")).append(" ").append(@calenderBuilder("Date Time")).append("""<input type="hidden" value="" aqbe:type="DvDateTimeInteger" aqbe:path=""" + @path + """ />""").append(@submitBuilder()))

class DvInterval extends Concept
  constructor: (json, name) ->
    super json, name
    @interval = json.interval
  getHtml: ->
    newTable = $("<table>").attr("class", "adl")
    for c in @interval
      cc = conceptBuilder(c, @adlName)
      newTable.append(cc.getHtml())
    super.append($("<td>").append(newTable))

class DvProportion extends Concept
  constructor: (json, name) ->
    super json, name
    @minNum = json.minNum
    @maxNum = json.maxNum
    @minDen = json.minDen
    @maxDen = json.maxDen
  getHtml: ->
    @min = @minNum
    @max = @maxNum
    num = @inputBuilder("0")
    @min = @minDen
    @max = @maxNum
    den = @inputBuilder("0")
    super.append($("<td>").append(@conceptBuilder("number")).append(" ").append(num).append(" : ").appedn(den).append(@submitBuilder()))

class DvUri extends Concept
  constructor: (json, name) ->
    super json, name
  getHtml: ->
    super.append($("<td>").append(@conceptBuilder()).append(" ").append(@inputBuilder("input", "url").attr("placeholder", "URL")).append(@submitBuilder()))

class DvAny extends Concept
  constructor: (json, name) ->
    super json, name
  getHtml: ->
    super.append($("<td>").append("""<span class="any">[Any]<span>"""))

class DvCluster extends Concept
  constructor: (json, name) ->
    super json, name
    @cluster = json.cluster
  getHtml: ->
    newTable = $("<table>").attr("class", "adl2")
    for c in @cluster
      cc = conceptBuilder(c, @adlName)
      newTable.append(cc.getHtml())
    super.append($("<td>").append(newTable))

class DvMultipleElements extends Concept
  constructor: (json, name) ->
    super json, name
    @elements = json.elements
  getHtml: ->
    newTable = $("<table>").attr("class", "adl2")
    for c in @elements
      cc = conceptBuilder(c._2, @adlName)
      newTable.append(cc.getHtml())
    super.append($("<td>").append(newTable))


submit = (obj) ->
  parent = $(obj).parent("td")                # 親要素の取得
  # validation
  unless parent.find("span").text() is ""
    alert "Error"
    return

  input = parent.find("input, select")        # 各種inputの取得
  name = parent.prev("td").find("span").text() # nameの取得
  empty = ""
  for i in input
    unless $(i).attr("class") is "submit" or $(i).attr("class") is "remover"
      if $(i).attr("class") is "condition"
        condition = $(i).val()
      else
        unless path?
          path = $(i).attr("aqbe:path")
        else
          path = path
        type = $(i).attr("aqbe:type")
        if type is "DvQuantityUnit"
          unit = $(i).val()
          unitStr = $(i).children(":selected").text()
          pathUnit = $(i).attr("aqbe:path")
        else if type is "DV_DATE_TIME"
          calStr = $(i).val()
        else
          value = $(i).val()
        $(i).val("")

  # empty value
  if value is ""
    alert "empty!"
    return

  # condition to conditonString
  conStr = con2str(condition)

  # make string
  if name is "" then name = path.replace("$","")
  str = "#{name},#{path},#{condition},#{conStr},#{value},#{unit},#{unitStr},#{pathUnit},#{calStr}"

  # display
  remover = $("<input>").attr("type","button").attr("class", "remover").val("x")
  remover.click ->
    remover.parent("p").remove()
    text = $("#stack").text()
    $("#stack").empty()
    flag = true
    for x in text.split("\n")
      if x is str and flag
        flag = false
      else
        $("#stack").append("#{x}\n")

  $(obj).parent("td").append($("<p>").text("#{conStr} #{(if calStr? then calStr else value)} #{(if unitStr? then unitStr else empty)}").append(remover))
  # stack data
  # name, path, condition, condition string, value, unit, unit string, calendar string \n
  $("#stack").append("#{str}\n")


con2str = (condition) ->
  switch parseInt(condition)
    when 0
      conStr = "="
    when 1
      conStr = "!="
    when 2
      conStr = ">"
    when 3
      conStr = "<"
    when 4
      conStr = ">="
    when 5
      conStr = "<="
    else
      conStr = "="
  conStr
