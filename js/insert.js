// Generated by CoffeeScript 1.3.3
var addData, conceptSelector, parseConcept;

$(document).ready(function() {
  conceptSelector();
  return $("#add input").click(function() {
    return addData();
  });
});

/*
  * #concept要素にADL名一覧を展開
*/


conceptSelector = function() {
  return $.ajax({
    type: "GET",
    url: "http://wako3.u-aizu.ac.jp:8080/service/adl/",
    dataType: "json",
    success: function(json) {
      var adlList, arr, value, _i, _len;
      arr = Array.prototype.slice.apply(json.adl);
      adlList = Array.sort(arr);
      for (_i = 0, _len = adlList.length; _i < _len; _i++) {
        value = adlList[_i];
        $("#concept").append($("<option>").val(value).text(value));
      }
      return $("#concept").change(function() {
        return $.ajax({
          type: "GET",
          url: "http://wako3.u-aizu.ac.jp:8080/service/concept/" + $("#concept").val(),
          dataType: "json",
          success: function(adl) {
            $("#concept").attr("disabled", "disabled");
            return parseConcept(adl);
          },
          error: function() {
            alert("XML Not Found");
            return document.location = document.location;
          }
        });
      });
    }
  });
};

/*
  * Conceptを展開してテーブルに表示
*/


parseConcept = function(json) {
  var adl, adlList, c, concept, file, k, list, name, temp, v, x, _i, _len;
  adlList = {};
  for (file in json) {
    adl = json[file];
    temp = {};
    for (k in adl) {
      v = adl[k];
      if (k !== "name") {
        temp[k] = v;
      }
    }
    adlList[adl.name] = temp;
  }
  for (name in adlList) {
    list = adlList[name];
    $("#insert").append("<h3>" + name + "</h3>").append($("<table>").attr("class", "adl").attr("aqbe_adl_name", name));
    for (k in list) {
      v = list[k];
      $("[aqbe_adl_name=" + name + "]").append("<tr><th colspan=\"2\">" + k + "</th></tr>");
      concept = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = v.length; _i < _len; _i++) {
          x = v[_i];
          _results.push(conceptBuilder(x));
        }
        return _results;
      })();
      for (_i = 0, _len = concept.length; _i < _len; _i++) {
        c = concept[_i];
        $("[aqbe_adl_name=" + name + "]").append(c.getHtml());
      }
    }
  }
  return validate();
};

addData = function() {
  var adlName, data, error, json, o, path, pathUnit, t, table, temp, type, value, valueUnit, x, _i, _j, _k, _len, _len1, _len2, _ref;
  json = {};
  table = $("#insert table");
  data = {};
  for (_i = 0, _len = table.length; _i < _len; _i++) {
    t = table[_i];
    temp = {};
    adlName = $(t).attr("aqbe_adl_name");
    data = $("input, select", t);
    for (_j = 0, _len1 = data.length; _j < _len1; _j++) {
      x = data[_j];
      value = $(x).val();
      path = $(x).attr("aqbe:path");
      type = $(x).attr("aqbe:type");
      if (type === "Require" && value === "") {
        alert("Please Input Patient name");
        return;
      }
      error = false;
      _ref = $(".error");
      for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
        o = _ref[_k];
        if ($(o).text() !== "") {
          error = true;
        }
      }
      if (error) {
        alert("Check Error");
        return;
      }
      if (value !== "" && type !== "DvQuantityUnit" && type !== "DV_DATE_TIME") {
        if (type === "DvQuantity") {
          valueUnit = $(x).next().val();
          pathUnit = $(x).next().attr("aqbe:path");
          temp[path] = parseFloat(value);
          temp[pathUnit] = valueUnit;
        } else if (type === "DV_COUNT" || type === "DvDateTimeInteger" || type === "DvProportion") {
          temp[path] = parseInt(value);
        } else {
          temp[path] = value;
        }
      }
    }
    json[adlName] = temp;
  }
  return $.ajax({
    type: "POST",
    url: "http://wako3.u-aizu.ac.jp:8080/service/insert",
    contentType: "text/json",
    data: JSON.stringify(json),
    success: function(res) {
      alert("Successfully added the data");
      return document.location = document.location;
    },
    error: function() {
      return alert("Error");
    }
  });
};
