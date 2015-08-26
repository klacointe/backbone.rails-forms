RailsForms = {}
_ = require?("underscore") || window._
$ = require?("jquery") || window.$
Backbone = require?("backbone") || window.Backbone

if module?
  module.exports = RailsForms
else
  Backbone.RailsForms = RailsForms
