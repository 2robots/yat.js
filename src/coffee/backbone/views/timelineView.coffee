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

    @container = $(window.yat.templates.timelineContainer())

    @viewportContainer = $(window.yat.templates.timelineViewport())
    @viewport = new window.yat.ViewportView model: @model
    @viewportContainer.append(@viewport.$el)

    @navigation = $(window.yat.templates.timelineNavigation())
    @overview = new window.yat.OverviewView model: @model.getStartEnd()
    @navigationBar = new window.yat.NavigationView model: @model
    @navigation.append(@overview.$el)
    @navigation.append(@navigationBar.$el)

    @container.children('.yat-timeline-inner1').append(@navigation)
    @container.children('.yat-timeline-inner1').append(@viewportContainer)
    that.$el.append(@container)

    @model.each((item) ->
      view = new window.yat.ItemView {model: item}
#      that.$el.append(view.$el)
    )

