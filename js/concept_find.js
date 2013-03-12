// Generated by CoffeeScript 1.3.3
var Concept, DvAny, DvBoolean, DvCluster, DvCodedText, DvCount, DvDateTime, DvInterval, DvMultiMedia, DvMultipleElements, DvOrdinal, DvProportion, DvQuantity, DvText, DvUri, con2str, conceptBuilder, submit,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

conceptBuilder = function(json, name) {
  switch (json.dataType) {
    case "DvQuantity":
      return new DvQuantity(json, name);
    case "DV_CODED_TEXT":
      return new DvCodedText(json, name);
    case "DV_BOOLEAN":
      return new DvBoolean(json, name);
    case "DV_TEXT":
      return new DvText(json, name);
    case "DV_COUNT":
      return new DvCount(json, name);
    case "DvOrdinal":
      return new DvOrdinal(json, name);
    case "DV_MULTIMEDIA":
      return new DvMultiMedia(json, name);
    case "DV_DATE_TIME":
      return new DvDateTime(json, name);
    case "DV_INTERVAL":
      return new DvInterval(json, name);
    case "DV_PROPORTION":
      return new DvProportion(json, name);
    case "DV_URI":
      return new DvUri(json, name);
    case "DvMultipleElements":
      return new DvMultipleElements(json, name);
    case "DvCluster":
      return new DvCluster(json, name);
    default:
      return new DvAny(json, name);
  }
};

Concept = (function() {

  function Concept(json, adlName) {
    this.name = json.name;
    this.adlName = adlName;
    this.path = this.adlName + "." + json.path.replace(/\./g, "___");
    this.type = json.dataType;
  }

  Concept.prototype.inputBuilder = function(placeholder) {
    if (placeholder == null) {
      placeholder = "";
    }
    return $("<input>").attr("type", "text").attr("value", "").attr("aqbe:path", this.path).attr("aqbe:type", this.type).attr("placeholder", placeholder);
  };

  Concept.prototype.calenderBuilder = function() {
    return this.inputBuilder().attr("id", "fieldDate");
  };

  Concept.prototype.selectBuilder = function(path, type, require) {
    var selecter;
    if (path == null) {
      path = this.path;
    }
    if (type == null) {
      type = this.type;
    }
    if (require == null) {
      require = false;
    }
    selecter = $("<select>").attr("aqbe:path", path).attr("aqbe:type", type);
    if (require) {
      return selecter;
    } else {
      return selecter.append("<option value=\"\">Please Select</option>");
    }
  };

  Concept.prototype.conditionBuilder = function(type) {
    var selecter;
    if (type == null) {
      type = "text";
    }
    selecter = $("<select>").attr("class", "condition");
    selecter.append("<option value=\"0\">=</option>");
    selecter.append("<option value=\"1\">!=</option>");
    if (type === "number") {
      selecter.append("<option value=\"2\">&gt;</option>");
    }
    if (type === "number") {
      selecter.append("<option value=\"3\">&lt;</option>");
    }
    if (type === "number") {
      selecter.append("<option value=\"4\">&gt;=</option>");
    }
    if (type === "number") {
      selecter.append("<option value=\"5\">&lt;=</option>");
    }
    return selecter;
  };

  Concept.prototype.submitBuilder = function() {
    var submitter;
    submitter = $("<input>").attr("type", "button").attr("class", "submit btn").val("add");
    submitter.click(function() {
      return submit(submitter);
    });
    return submitter;
  };

  Concept.prototype.getHtml = function(adlName) {
    $("#pathList").append("" + this.path + "," + this.name + "\n");
    return $("<tr>").append($("<td>").append($("<input>").attr("type", "checkbox").attr("aqbe:path", this.path).attr("class", "selection")).append($("<span>").append(this.name)));
  };

  return Concept;

})();

DvQuantity = (function(_super) {

  __extends(DvQuantity, _super);

  function DvQuantity(json, name) {
    DvQuantity.__super__.constructor.call(this, json, name);
    this.path = this.path + "/magnitude";
    this.unitPath = this.path.replace("/magnitude", "/units");
    this.min = json.min[0] != null ? json.min : [-999999];
    this.max = json.max[0] != null ? json.max : [999999];
    this.unit = json.unit;
  }

  DvQuantity.prototype.getHtml = function() {
    var input, k, path, require, type, unitSelecter, v, _i, _len, _ref,
      _this = this;
    input = this.inputBuilder("0.0").attr("aqbe:min", this.min[0]).attr("aqbe:max", this.max[0]);
    unitSelecter = this.selectBuilder(path = this.unitPath, type = "DvQuantityUnit", require = true);
    _ref = this.unit;
    for (v = _i = 0, _len = _ref.length; _i < _len; v = ++_i) {
      k = _ref[v];
      unitSelecter.append("<option value=\"" + v + "\">" + k + "</option>");
    }
    unitSelecter.change(function() {
      var index;
      index = unitSelecter.val();
      return $(input).attr("aqbe:min", _this.min[index]).attr("aqbe:max", _this.max[index]);
    });
    return DvQuantity.__super__.getHtml.apply(this, arguments).append($("<td>").append(this.conditionBuilder("number")).append(" ").append(input).append(" ").append(unitSelecter).append("<span class=\"error\">").append(this.submitBuilder()));
  };

  return DvQuantity;

})(Concept);

DvCodedText = (function(_super) {

  __extends(DvCodedText, _super);

  function DvCodedText(json, name) {
    DvCodedText.__super__.constructor.call(this, json, name);
    this.codeList = json.codeList;
  }

  DvCodedText.prototype.getHtml = function() {
    var code, select, _i, _len, _ref;
    select = this.selectBuilder();
    _ref = this.codeList;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      code = _ref[_i];
      select.append("<option value=\"" + code + "\">" + code + "</option>");
    }
    return DvCodedText.__super__.getHtml.apply(this, arguments).append($("<td>").append(this.conditionBuilder()).append(select).append(this.submitBuilder()));
  };

  return DvCodedText;

})(Concept);

DvBoolean = (function(_super) {

  __extends(DvBoolean, _super);

  function DvBoolean(json, name) {
    DvBoolean.__super__.constructor.call(this, json, name);
  }

  DvBoolean.prototype.getHtml = function() {
    return DvBoolean.__super__.getHtml.apply(this, arguments).append($("<td>").append(this.selectBuilder().append("<option value=\"true\">true</option>").append("<option value=\"false\">false</option>")).append(this.submitBuilder()));
  };

  return DvBoolean;

})(Concept);

DvText = (function(_super) {

  __extends(DvText, _super);

  function DvText(json, name) {
    DvText.__super__.constructor.call(this, json, name);
  }

  DvText.prototype.getHtml = function() {
    return DvText.__super__.getHtml.apply(this, arguments).append($("<td>").append(this.conditionBuilder()).append(" ").append(this.inputBuilder("FreeText")).append(this.submitBuilder()));
  };

  return DvText;

})(Concept);

DvCount = (function(_super) {

  __extends(DvCount, _super);

  function DvCount(json, name) {
    DvCount.__super__.constructor.call(this, json, name);
    this.min = json.min != null ? json.min : -999999;
    this.max = json.max != null ? json.max : 999999;
  }

  DvCount.prototype.getHtml = function() {
    return DvCount.__super__.getHtml.apply(this, arguments).append($("<td>").append(this.conditionBuilder("number")).append(" ").append(this.inputBuilder("0").attr("aqbe:min", this.min).attr("aqbe:max", this.max)).append("<span class=\"error\">").append(this.submitBuilder()));
  };

  return DvCount;

})(Concept);

DvOrdinal = (function(_super) {

  __extends(DvOrdinal, _super);

  function DvOrdinal(json, name) {
    DvOrdinal.__super__.constructor.call(this, json, name);
    this.codeList = json.codeList;
  }

  DvOrdinal.prototype.getHtml = function() {
    var c, select, _i, _len, _ref;
    select = this.selectBuilder();
    _ref = this.codeList;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      select.append("<option value=\"" + c._1 + "\">" + c._2 + "</option>");
    }
    return DvOrdinal.__super__.getHtml.apply(this, arguments).append($("<td>").append(this.conditionBuilder()).append(select).append(this.submitBuilder()));
  };

  return DvOrdinal;

})(Concept);

DvMultiMedia = (function(_super) {

  __extends(DvMultiMedia, _super);

  function DvMultiMedia(json, name) {
    DvMultiMedia.__super__.constructor.call(this, json, name);
    this.codeList = json.codeList;
  }

  DvMultiMedia.prototype.getHtml = function() {
    var c, select, _i, _len, _ref;
    select = this.selectBuilder();
    _ref = this.codeList;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      select.append("<option value=\"" + c + "\">" + c + "</option>");
    }
    return DvMultiMedia.__super__.getHtml.apply(this, arguments).append($("<td>").append(this.conditionBuilder()).append(select).append(this.submitBuilder()));
  };

  return DvMultiMedia;

})(Concept);

DvDateTime = (function(_super) {

  __extends(DvDateTime, _super);

  function DvDateTime(json, name) {
    DvDateTime.__super__.constructor.call(this, json, name);
  }

  DvDateTime.prototype.getHtml = function() {
    return DvDateTime.__super__.getHtml.apply(this, arguments).append($("<td>").append(this.conditionBuilder("number")).append(" ").append(this.calenderBuilder("Date Time")).append("<input type=\"hidden\" value=\"\" aqbe:type=\"DvDateTimeInteger\" aqbe:path=" + this.path + " />").append(this.submitBuilder()));
  };

  return DvDateTime;

})(Concept);

DvInterval = (function(_super) {

  __extends(DvInterval, _super);

  function DvInterval(json, name) {
    DvInterval.__super__.constructor.call(this, json, name);
    this.interval = json.interval;
  }

  DvInterval.prototype.getHtml = function() {
    var c, cc, newTable, _i, _len, _ref;
    newTable = $("<table>").attr("class", "adl2 table table-bordered");
    _ref = this.interval;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      cc = conceptBuilder(c, this.adlName);
      newTable.append(cc.getHtml());
    }
    return DvInterval.__super__.getHtml.apply(this, arguments).append($("<td>").append(newTable));
  };

  return DvInterval;

})(Concept);

DvProportion = (function(_super) {

  __extends(DvProportion, _super);

  function DvProportion(json, name) {
    DvProportion.__super__.constructor.call(this, json, name);
    this.minNum = json.minNum;
    this.maxNum = json.maxNum;
    this.minDen = json.minDen;
    this.maxDen = json.maxDen;
  }

  DvProportion.prototype.getHtml = function() {
    var den, num;
    this.min = this.minNum;
    this.max = this.maxNum;
    num = this.inputBuilder("0");
    this.min = this.minDen;
    this.max = this.maxNum;
    den = this.inputBuilder("0");
    return DvProportion.__super__.getHtml.apply(this, arguments).append($("<td>").append(this.conceptBuilder("number")).append(" ").append(num).append(" : ").appedn(den).append(this.submitBuilder()));
  };

  return DvProportion;

})(Concept);

DvUri = (function(_super) {

  __extends(DvUri, _super);

  function DvUri(json, name) {
    DvUri.__super__.constructor.call(this, json, name);
  }

  DvUri.prototype.getHtml = function() {
    return DvUri.__super__.getHtml.apply(this, arguments).append($("<td>").append(this.conceptBuilder()).append(" ").append(this.inputBuilder("input", "url").attr("placeholder", "URL")).append(this.submitBuilder()));
  };

  return DvUri;

})(Concept);

DvAny = (function(_super) {

  __extends(DvAny, _super);

  function DvAny(json, name) {
    DvAny.__super__.constructor.call(this, json, name);
  }

  DvAny.prototype.getHtml = function() {
    return DvAny.__super__.getHtml.apply(this, arguments).append($("<td>").append("<span class=\"any\">[Any]<span>"));
  };

  return DvAny;

})(Concept);

DvCluster = (function(_super) {

  __extends(DvCluster, _super);

  function DvCluster(json, name) {
    DvCluster.__super__.constructor.call(this, json, name);
    this.cluster = json.cluster;
  }

  DvCluster.prototype.getHtml = function() {
    var c, cc, newTable, _i, _len, _ref;
    newTable = $("<table>").attr("class", "adl2 table table-bordered");
    _ref = this.cluster;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      cc = conceptBuilder(c, this.adlName);
      newTable.append(cc.getHtml());
    }
    return DvCluster.__super__.getHtml.apply(this, arguments).append($("<td>").append(newTable));
  };

  return DvCluster;

})(Concept);

DvMultipleElements = (function(_super) {

  __extends(DvMultipleElements, _super);

  function DvMultipleElements(json, name) {
    DvMultipleElements.__super__.constructor.call(this, json, name);
    this.elements = json.elements;
  }

  DvMultipleElements.prototype.getHtml = function() {
    var c, cc, newTable, _i, _len, _ref, _results;
    newTable = $("<table>").attr("class", "adl2 table table-bordered");
    _ref = this.elements;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c = _ref[_i];
      cc = conceptBuilder(c._2, this.adlName);
      DvMultipleElements.__super__.getHtml.apply(this, arguments).append($("<td>").append(newTable));
      _results.push(newTable.append(cc.getHtml()));
    }
    return _results;
  };

  return DvMultipleElements;

})(Concept);

submit = function(obj) {
  var calStr, conStr, condition, empty, i, input, name, parent, path, pathUnit, remover, str, type, unit, unitStr, value, _i, _len;
  parent = $(obj).parent("td");
  if (parent.find("span").text() !== "") {
    alert("Error");
    return;
  }
  input = parent.find("input, select");
  name = parent.prev("td").find("span").text();
  empty = "";
  for (_i = 0, _len = input.length; _i < _len; _i++) {
    i = input[_i];
    if (!($(i).attr("class") === "submit btn" || $(i).attr("class") === "remover btn btn-mini")) {
      if ($(i).attr("class") === "condition") {
        condition = $(i).val();
      } else {
        if (typeof path === "undefined" || path === null) {
          path = $(i).attr("aqbe:path");
        } else {
          path = path;
        }
        type = $(i).attr("aqbe:type");
        if (type === "DvQuantityUnit") {
          unit = $(i).val();
          unitStr = $(i).children(":selected").text();
          pathUnit = $(i).attr("aqbe:path");
        } else if (type === "DV_DATE_TIME") {
          calStr = $(i).val();
        } else {
          value = $(i).val();
        }
        $(i).val("");
      }
    }
  }
  if (value === "") {
    alert("empty!");
    return;
  }
  conStr = con2str(condition);
  if (name === "") {
    name = path.replace("$", "");
  }
  str = "" + name + "," + path + "," + condition + "," + conStr + "," + value + "," + unit + "," + unitStr + "," + pathUnit + "," + calStr;
  remover = $("<input>").attr("type", "button").attr("class", "remover btn btn-mini").val("x");
  remover.click(function() {
    var flag, text, x, _j, _len1, _ref, _results;
    remover.parent("p").remove();
    text = $("#stack").text();
    $("#stack").empty();
    flag = true;
    _ref = text.split("\n");
    _results = [];
    for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
      x = _ref[_j];
      if (x === str && flag) {
        _results.push(flag = false);
      } else {
        _results.push($("#stack").append("" + x + "\n"));
      }
    }
    return _results;
  });
  $(obj).parent("td").append($("<p>").text("" + conStr + " " + (calStr != null ? calStr : value) + " " + (unitStr != null ? unitStr : empty)).append(remover));
  return $("#stack").append("" + str + "\n");
};

con2str = function(condition) {
  var conStr;
  switch (parseInt(condition)) {
    case 0:
      conStr = "=";
      break;
    case 1:
      conStr = "!=";
      break;
    case 2:
      conStr = ">";
      break;
    case 3:
      conStr = "<";
      break;
    case 4:
      conStr = ">=";
      break;
    case 5:
      conStr = "<=";
      break;
    default:
      conStr = "=";
  }
  return conStr;
};