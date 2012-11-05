$(document).ready ->
  conceptSelector()
  $("#add input").click ->
    addData()
  $("#context").AnyTime_picker({
    format: "%Y/%m/%d %H:%i:%s"
    earliest: "1980/01/01 01:00:00"
    latest: new Date()
  })
  $("#context").change( ->
    validateDvDateTime(@)
  )

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
    $("#insert").append("<h3>#{name}</h3>").append($("<table>").attr("class", "adl").attr("aqbe_adl_name", name))
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

addData = ->
  json = {}
  table = $("#insert table")
  data = {}
  for t in table
    temp = {}
    adlName = $(t).attr("aqbe_adl_name")
    data = $("input, select", t)
    for x in data
      # データの読み込み
      value = $(x).val()
      path  = $(x).attr("aqbe:path")
      type  = $(x).attr("aqbe:type")
      # 必須の入力を確認
      if type is "Require" and value is ""
        alert "Please Input Patient name"
        return
      # 不正な入力の確認
      error = false
      for o in $(".error") then if $(o).text() isnt "" then error = true
      if error
        alert "Check Error"
        return
      # JSONの作成
      if value isnt "" and type isnt "DvQuantityUnit" and type isnt "DV_DATE_TIME"
        if type is "DvQuantity"
          valueUnit = $(x).next().val()
          pathUnit  = $(x).next().attr("aqbe:path")
          temp[path] = parseFloat(value)
          temp[pathUnit] = valueUnit
        else if type is "DV_COUNT" or type is "DvDateTimeInteger" or type is "DvProportion"
          temp[path] = parseInt(value)
        else
          temp[path] = value
    json[adlName] = temp if adlName?

  $.ajax(
    type: "POST"
    url: "http://wako3.u-aizu.ac.jp:8080/service/insert"
    contentType: "text/json"
    data: JSON.stringify(json)
    success: (res) ->
      alert "Successfully added the data"
      document.location = document.location
    error: ->
      alert "Error"
  )
