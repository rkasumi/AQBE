$(document).ready ->
  conceptSelector()
  $("#add input").click ->
    sendConditionBox()
  $("#pathList").append("/name/value,Patient Name\n/composer/value,Composer\n/context/start_time,Context\n")
  $("#context").AnyTime_picker({
    format: "%Y/%m/%d %H:%i:%s"
    earliest: "1980/01/01 01:00:00"
    latest: new Date()
  })
  $(".submit").click ->
    submit(@)

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

sendConditionBox = ->
  text = $("#stack").text().split("\n")
  empty = ""
  $("#result").empty()
  table = $("<table>").attr("class","adl")
  table.append($("<tr>").append($("<th>").text("Object")).append($("<th>").text("Condition")))
  tbody = $("<tbody>").attr("id", "sortable")
  for t in text
    if t?
      [name, path, condition, conStr, value, unit, unitStr, pathUnit, calStr] = t.split(",")
      unless name is ""
        str = "#{name} #{conStr} #{(if calStr isnt "undefined" then calStr else value)} #{(if unitStr isnt "undefined" then unitStr else empty)}"
        sec = $("<input>").attr("type", "hidden").attr("class", "cb_1").val(t)
        cb  = $("<select>").attr("class", "cb_2").append($("<option>").val("AND").text("AND")).append($("<option>").val("OR").text("OR"))
        td1 = $("<td>").append(str).append(sec)
        td2 = $("<td>").append(cb)
        tbody.append($("<tr>").append(td1).append(td2))
  $("#result").append(table.append(tbody)).append($("<br>"))
  $("#sortable").sortable()
  $("#sortable").disableSelection()

  find = $("<input>").attr("type", "button").val("find data")
  find.click ->
    findData()
  $("#result").append($("<div>").attr("id", "add").append(find))

  # 検索フォームを隠し、結果を表示
  $("#find").hide()
  $("#add").hide()
  $("#result").show("fast")

  # 戻るボタンを表示
  $("#back").show()
  $("#back input").unbind() # 古いイベントを削除
  $("#back input").click ->
    $("#result").hide()
    $("#find").show("fast")
    $("#add").show()
    $("#back").hide() # ボタンを非表示に
    $("#result").empty() # 結果を削除

findData = ->
  con = []
  andor = []
  cnt = 0
  for o in $(".cb_1")
    con[cnt++] = $(o).val()
  cnt = 0
  for o in $(".cb_2")
    andor[cnt++] = $(o).val()

  array = []
  for i in [(cnt-1)..0]
    # 検索条件を追加
    [name, path, condition, conStr, value, unit, unitStr, pathUnit, calStr] = con[i].split(",")
    # condition
    switch parseInt(condition)
      when 1 # !=
        conv = "$ne"
      when 2 # >
        conv = "$gt"
      when 3 # <
        conv = "$lt"
      when 4 # >=
        conv = "$gte"
      when 5 # <=
        conv = "$lte"
    # -- normal
    if unit is "undefined"
      v = unless isNaN(value) then parseInt(value) else value
      temp = {}; temp[path] = v
      if conv?
        t1 = {}; t1[conv] = temp[path]
        t2 = {}; t2[path] = t1
        array[0]  = t2
      else
        array[0] = temp
    # -- DvQuantity
    else
      console.log unit
      o1 = {}; o1[path] = parseFloat(value)
      o2 = {}; o2[pathUnit] = unit
      if conv?
        t1 = {}; t1[conv] = o1[path]
        t2 = {}; t2[path] = t1
        temp = {}; temp["$and"] = [t2, o2]
      else
        temp = {}; temp["$and"] = [o1, o2]
      array[0] = temp

    # 組み合わせ条件をjsonに追加
    c = if andor[i] is "OR" then "$or" else "$and"
    json = {}; json[c] = array
    array = []

    # 配列に条件文を追加
    array[1] = json
  json = array[1]

  # where
  array = []
  i = 0
  array[i++] = json
  for w in $(".adl")
    w_name = $(w).attr("aqbe_adl_name")
    if w_name?
      temp = {}
      temp[w_name] = {"$exists": true}
      array[i++] = temp

  json = {"$and": array}

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

  #request
  request = {}
  request["condition"] = json
  request["selection"] = selection

  query = "db.docs.find(#{JSON.stringify(request.condition)}, #{JSON.stringify(request.selection)})"
  $("#result").empty().append($("<textarea>").text(query))

  $.ajax(
    type: "POST"
    url: "http://wako3.u-aizu.ac.jp:8080/service/find"
    contentType: "text/json"
    data: JSON.stringify(request)
    success: (response) ->
      # 成功したら結果をテーブルに表示
      for result in response.result
        table = $("<table>").attr("class","adl")
        for key, obj of result
          if key isnt "ehr"
            table.append($("<tr>").append($("<th>").attr("colspan",2).append(key)))
          for path, value of obj
            table.append($("<tr>").append($("<td>").append(toName(path))).append($("<td>").append(value)))
        $("#result").append(table).append($("<br>"))

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
