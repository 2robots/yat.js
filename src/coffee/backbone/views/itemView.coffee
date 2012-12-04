# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# The item is one "event" at a specific time on the timeline
window.yat.ItemView = class extends Backbone.View
  initialize: ->
    @inDom = false
    @render()

  render: ->
    @inDom = true
    @$el.html(window.yat.templates.item @model.toJSON())

