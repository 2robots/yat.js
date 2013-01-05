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

    if that.model.get('important')
      that.$el.addClass 'important'

    setTimeout (->

      if $(that.$el).find('.yat-element-inner2').height() > ($(that.$el).find('.yat-element-inner').height() - 10)
        that.$el.addClass 'overflow'
        that.$el.append window.yat.templates.timelineViewportReadMore
    )