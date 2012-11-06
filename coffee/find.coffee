$(document).ready ->
  conceptSelector()
  $("#add input").click ->
    findData()
  $("#pathList").append("/name/value,Patient Name\n/composer/value,Composer\n/context/start_time,Context")

###
  * #concept要素にADL名一覧を展開
###
conceptSelector = ->
  $.ajax(
    type: "GET"
    url: "http://wako3.u-aizu.ac.jp:8080/service/adl/"
    dataType: "json"
    success: (json) ->
      arr = Array.prototype.slice.apply(json.adl)
      adlList = Array.sort(arr)
      for value in adlList
        $("#concept").append($("<option>").val(value).text(value))
      # ADLファイルが選択された時の操作
      $("#concept").change ->
        $.ajax(
          type: "GET"
          url: "http://wako3.u-aizu.ac.jp:8080/service/concept/" + $("#concept").val()
          dataType: "json"
          success: (adl) ->
            $("#concept").attr("disabled", "disabled")
            parseConcept adl
          error: ->
            alert "XML Not Found"
            document.location = document.location
        )
  )

###
  * Conceptを展開してテーブルに表示
###
parseConcept = (json) ->
  # ADLファイル名-ADLリストの取り出し
  adlList = {}
  for file, adl of json
    temp = {}
    for k,v of adl when k isnt "name"
      temp[k] = v
    adlList[adl.name] = temp
  # ADL Listの展開
  for name, list of adlList
    # 単ADL名の表示とテーブルの表示
    $("#find").append("<h3>#{name}</h3>").append($("<table>").attr("class", "adl").attr("aqbe_adl_name", name))
    # ADLList の展開
    for k,v of list
      # ADLList名の表示
      $("[aqbe_adl_name=#{name}]").append("<tr><th colspan=\"2\">#{k}</th></tr>")
      # 個別Dvオブジェクトの表示
      concept = for x in v then conceptBuilder(x)
      for c in concept
        $("[aqbe_adl_name=#{name}]").append(c.getHtml())
  # バリデーションの追加
  validate()

findData = ->
  json = {}
  condition = []
  table = $("#find table")
  data = {}
  count = 0
  for t in table
    adlName = $(t).attr("aqbe_adl_name")
    data = $("input, select", t)
    unless adlName? then continue
    for x in data
      temp = {}
      # データの読み込み
      value = $(x).val()
      path  = adlName + "." + $(x).attr("aqbe:path")
      type  = $(x).attr("aqbe:type")
      if $(x).attr("aqbe:path") is undefined then continue
      # 不正な入力の確認
      error = false
      for o in $(".error") then if $(o).text() isnt "" then error = true
      if error
        alert "Check Error"
        return
      # JSONの作成
      if value isnt "" and type isnt "DvQuantityUnit" and type isnt "DV_DATE_TIME" and $(x).attr("class") isnt "selection" and $(x).attr("class") isnt "condition"
        # condition = != > < <= >= の取得
        con = if type is "DvDateTimeInteger" then $(x).prev().prev(".condition").val() else $(x).prev(".condition").val()
        con = if con? then con else 0
        # JSONの作成 typeによって一部取得する値を変更する
        if type is "DvQuantity"
          valueUnit = $(x).next().val()
          pathUnit  = adlName + "." + $(x).next().attr("aqbe:path")
          o1 = {}; o1[path] = parseFloat(value)
          o2 = {}; o2[pathUnit] = valueUnit
          condition[count] = {"$and": [o1, o2]}
          count += 1
        else if type is "DV_COUNT" or type is "DvDateTimeInteger" or type is "DvProportion"
          obj = {}; obj[path] = parseInt(value)
          condition[count] = obj
          count += 1
        else
          obj = {}; obj[path] = value
          condition[count] = obj
          count += 1

  # selection
  selection = {"_id":0}
  table = $("#find table")
  data = {}
  for t in table
    adlName = $(t).attr("aqbe_adl_name")
    data = $(".selection", t)
    for s in data
      if $(s).attr("checked") is "checked"
        selection[adlName + "." + $(s).attr("aqbe:path")] = 1

  json["condition"] = {"$and": condition}
  json["selection"] = selection
  $.ajax(
    type: "POST"
    url: "http://wako3.u-aizu.ac.jp:8080/service/find"
    contentType: "text/json"
    data: JSON.stringify(json)
    success: (response) ->
      for result in response.result
        for key, obj of result
          console.log key
          for path, value of obj
            console.log toName(path) + " = " + value
    error: ->
      alert "Bad Request"
  )

toName = (path) ->
  text = $("#pathList").text().split("\n")
  pathList = {}
  for attr in text
    [a,b] = attr.split(",")
    pathList[a] = b
  return pathList[path]
