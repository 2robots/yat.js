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

  className: 'yat-inner'

  initialize: ->
    @render()

  render: ->
    that = @

    @container = $(window.yat.templates.timelineContainer())

    @viewportContainer = $(window.yat.templates.timelineViewport())
    @viewport = new window.yat.ViewportView model: @model
    @viewportContainer.append(@viewport.$el)

    @navigation = $(window.yat.templates.timelineNavigation())
    @overview = new window.yat.OverviewView { model: @model.getStartEnd(), dispatcher: @dispatcher }
    @navigationBar = new window.yat.NavigationView model: @model
    @navigation.append(@overview.$el)
    @navigation.append(@navigationBar.$el)

    @container.children('.yat-timeline-inner1').append(@navigation)
    @container.children('.yat-timeline-inner1').append(@viewportContainer)
    that.$el.append(@container)
