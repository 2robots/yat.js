# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# The item is one "event" at a specific time on the timeline
window.yat.TimelineView = class extends Backbone.View
  initialize: ->
    @render()

  render: ->
    that = @
#    @viewport =
    @navigation = $(window.yat.templates.timelineNavigation())
    @overview = new window.yat.OverviewView model: @model.getStartEnd()
    @navigation.append(@overview.$el)
    that.$el.append(@navigation)
    @model.each((item) ->
      view = new window.yat.ItemView {model: item}
#      that.$el.append(view.$el)
    )

