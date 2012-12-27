# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# The item is one "event" at a specific time on the timeline
window.yat.viewportItemView = class extends Backbone.View

  tagName: 'li'

  initialize: ->
    @inDom = false
    @render()

  render: ->
    @inDom = true
    @$el.html(window.yat.templates.timelineViewportElement @model.toJSON())

    that = @

    setTimeout (->
      #var content = el.find('.content');
      #      $('#log').append('content fits: ' + (el.height() >= content.height()) + '<br/>');
      console.log $(that.$el).height()
      console.log $(that.$el).find('.yat-element-inner').height()
    )