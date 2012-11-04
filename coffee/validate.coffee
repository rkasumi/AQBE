validate = ->
  #id以外の属性で動作しない
  $("#fieldDate").AnyTime_picker({
    format: "%Y/%m/%d %H:%i:%s"
    earliest: "1980/01/01 01:00:00"
    latest: new Date()
  })
  $("input").each( ->
    addValidate(@)
  )

addValidate = (obj) ->
  type = $(obj).attr("aqbe:type")
  if type is "DvQuantity"
    $(obj).change -> validateDvQuantity(obj)
  else if type is "DV_COUNT"
    $(obj).change -> validateDvCount(obj)
  else if type is "DV_DATE_TIME"
    $(obj).change -> validateDvDateTime(obj)

errorWindow = (obj, text) ->
  span = $(obj).next("span")
  span.text(text)

validateDvQuantity = (obj) ->
  type = $(obj).attr("aqbe:type")
  min  = parseFloat($(obj).attr("aqbe:min"))
  max  = parseFloat($(obj).attr("aqbe:max"))
  value = parseFloat($(obj).val())
  unless min <= value <= max || $(obj).val() is ""
    errorWindow($(obj).next(), "Require => min: #{min} max: #{max}")
  else
    errorWindow($(obj).next(), "")

validateDvCount = (obj) ->
  type = $(obj).attr("aqbe:type")
  min  = parseInt($(obj).attr("aqbe:min"))
  max  = parseInt($(obj).attr("aqbe:max"))
  value = parseInt($(obj).val())
  unless min <= value <= max || $(obj).val() is ""
    errorWindow(obj, "Require => min: #{min} max: #{max}")
  else
    errorWindow(obj, "")
    $(obj).val(Math.round(value))

validateDvDateTime = (obj) ->
    date = new Date("#{$(obj).val()}")
    $(obj).next("input").val(date.getTime())
