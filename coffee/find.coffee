$(document).ready ->
  conceptSelector()
  $("#add input").click ->
    sendConditionBox()
  $("#pathList").append("ehr./name/value,Patient Name\nehr./composer/value,Composer\nehr./context/start_time,Context\n")
  $("#context").AnyTime_picker({
    format: "%Y/%m/%d %H:%i:%s"
    earliest: "1980/01/01 01:00:00"
    latest: new Date()
  })
  $(".submit").click ->
    submit(@)
  loadExists()
  loadRename()

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
      adlList = arr.sort()
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
            loadExists()
            loadRename()
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
    title = $("<h3>").append($("<input>").attr("type", "checkbox").attr("class", "selection").attr("aqbe:path", name)).append(name)
    $("#find").append(title).append($("<table>").attr("class", "adl").attr("aqbe_adl_name", name))
    # ADLList の展開
    for k,v of list
      # ADLList名の表示
      $("[aqbe_adl_name=#{name}]").append("<tr><th colspan=\"2\">#{k}</th></tr>")
      # 個別Dvオブジェクトの表示
      concept = for x in v then conceptBuilder(x, name)
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
  # where
  if $("#stack").val() is ""
    json = {}
  else
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
      # -- exists
      if path is "$exists"
        t1 = {}; t1[path] = true
        t2 = {}; t2[toPath(value)] = t1
        array[0] = t2
      # -- normal
      else if unit is "undefined"
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

  # from
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

  # select
  selection = {"_id":0}
  table = $("#find table, #find h3")
  data = {}
  for t in table
    data = $(".selection", t)
    for s in data
      if $(s).attr("checked") is "checked"
        selection[$(s).attr("aqbe:path")] = 1

  #request
  request = {}
  request["condition"] = json
  request["selection"] = selection

  # for debug
  query = "db.docs.find(#{JSON.stringify(request.condition)}, #{JSON.stringify(request.selection)})"
  $("#result").empty().append($("<textarea>").text(query).attr("rows", "1").attr("cols","1")).append("<br />")

  $.ajax(
    type: "POST"
    url: "http://wako3.u-aizu.ac.jp:8080/service/find"
    contentType: "text/json"
    data: JSON.stringify(request)
    success: (response) ->
      $("#result").append("Result => #{response.result.length} patients")
      # 成功したら結果をテーブルに表示
      for result in response.result
        table = $("<table>").attr("class","adl")
        for key, obj of result
          if key isnt "ehr"
            table.append($("<tr>").append($("<th>").attr("colspan",2).append(key)))
          for path, value of obj
            if parseInt(value) >= 315504000000
              date = new Date(parseInt(value))
              value = date.getFullYear() + "/" + date.getMonth() + "/" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds()
            if toName("#{key}.#{path}")?
              b_name = toName("#{key}.#{path}")
              console.log rename(b_name)
              table.append($("<tr>").append($("<td>").append(rename(b_name))).append($("<td>").append(value)))
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
toPath = (name) ->
  text = $("#pathList").text().split("\n")
  pathList = {}
  for attr in text
    [a,b] = attr.split(",")
    pathList[b] = a
  return pathList[name]

loadExists = ->
  $("#exists").empty().append("""<option value="">Please Select</option>""")
  text = $("#pathList").text().split("\n")
  for x in text
    if x isnt ""
      [w, v] = x.split(",")
      $("#exists").append($("<option>").val(v).text(v))

loadRename = ->
  $("#rename").empty().append("""<option value="">Please Select</option>""")
  text = $("#pathList").text().split("\n")
  for x in text
    if x isnt ""
      [w, v] = x.split(",")
      $("#rename").append($("<option>").val(v).text(v))
  $("#rename").change ->
    $("#rename").next("input").removeAttr("disabled").attr("placeholder", $("#rename").val())
    $("#rename").next("input").next("input").unbind().click ->
      value = $("#rename").next("input").val()
      str = "#{$("#rename").val()},#{value}"
      $("#renameList").append("#{str}\n")
      # display
      remover = $("<input>").attr("type","button").attr("class", "remover").val("x")
      remover.click ->
        remover.parent("p").remove()
        text = $("#renameList").text()
        $("#renameList").empty()
        flag = true
        for x in text.split("\n")
          if x is str and flag
            flag = false
          else
            $("#renameList").append("#{x}\n")
      $("#rename").parent("td").append($("<p>").text("#{$("#rename").val()} => #{value}").append(remover))
      $("#rename").val("")
      $("#rename").next("input").attr("disabled", "disabled").removeAttr("placeholder").val("")

rename = (name) ->
  text = $("#renameList").text().split("\n")
  renameList = {}
  for attr in text
    [a,b] = attr.split(",")
    renameList[a] = b
  return if renameList[name]? then renameList[name] else name