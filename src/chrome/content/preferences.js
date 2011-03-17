const CC = Components.classes;
VERB=1;
DBUG=2;
INFO=3;
NOTE=4;
WARN=5;

https_everywhere = CC["@guardrail.wertarbyte.de/guardrail;1"].getService(Components.interfaces.nsISupports).wrappedJSObject;

const id_prefix = "he_enable";
function https_settings_changed(doc)
// The user changed one of the preferences, so make the rulesets sync to them
// This is not efficient but it doesn't matter
{
  var rs = doc.getElementById('https_everywhere_RuleSetList');
  var rulesets = https_everywhere.https_rules.rulesets;
  for (var i = 0; i < rulesets.length; i++) {
    var ruleset = rulesets[i];
    var elem = doc.getElementById(id_prefix + ruleset.name);
    ruleset.active = elem.checked;
  }
}

const row_width = 5;
function https_prefs_init(doc) {

  var o_httpsprefs = https_everywhere.get_prefs();

  var prefs_window = doc.getElementById('guardrail-prefs');
  var rs = doc.getElementById('https_everywhere_RuleSetList');
  var rulesets = https_everywhere.https_rules.rulesets;
  var hbox;

  for (var i = 0; i < rulesets.length; i++) {
    var ruleset = rulesets[i];

    var newopt = doc.createElement("listitem");

    // This pref should always have been created by the RuleSet constructor
    var enabled = o_httpsprefs.getBoolPref(ruleset.name);
    newopt.setAttribute("id", id_prefix + ruleset.name);
    var label = ruleset.name;
    if (ruleset.off_reason) {
      label += " ["+ruleset.off_reason+"]";
    }
    newopt.setAttribute("label", label);
    newopt.setAttribute("preference",null);
    newopt.setAttribute("type", "checkbox");
    newopt.setAttribute("checked", enabled);
    newopt.setAttribute("oncommand",
                        "https_settings_changed(document)");
    rs.appendChild(newopt);
  }
  // Do this here rather than in the .xul so that it goes after all these
  // postpendments
  //var spacer=doc.createElement("separator");
  //spacer.setAttribute("class", "groove");
  //rs.insertBefore(spacer,null);
}

function https_prefs_cancel(doc) {
  // the user changed some prefs but then cancelled; undo the consequences
  var o_httpsprefs = https_everywhere.get_prefs();
  var rulesets = https_everywhere.https_rules.rulesets;
  for (var i = 0; i < rulesets.length; i++) {
    var ruleset = rulesets[i];
    ruleset.active = o_httpsprefs.getBoolPref(ruleset.name);
  }
}


function https_prefs_save(doc) {
  var o_httpsprefs = https_everywhere.get_prefs();
  var rs = doc.getElementById('https_everywhere_RuleSetList');
  var rulesets = https_everywhere.https_rules.rulesets;
  for (var i = 0; i < rulesets.length; i++) {
    var ruleset = rulesets[i];
    var elem = doc.getElementById(id_prefix + ruleset.name);
    o_httpsprefs.setBoolPref(ruleset.name, elem.checked);
  }
}

function https_set_all(doc,val) {
  // set all rulesets to val (enable/disable, or -1 for "default")
  var o_httpsprefs = https_everywhere.get_prefs();
  var rulesets = https_everywhere.https_rules.rulesets;
  var rs = doc.getElementById('https_everywhere_RuleSetList');
  https_everywhere.log(3, "Setting rules to " + val);
  for (var i = 0; i < rulesets.length; i++) {
    var ruleset = rulesets[i];
    if (val == -1) {
      ruleset.active = ruleset.on_by_default;
    } else 
      ruleset.active = val;
    var elem = doc.getElementById(id_prefix + ruleset.name);
    elem.checked = ruleset.active;
  }
}
