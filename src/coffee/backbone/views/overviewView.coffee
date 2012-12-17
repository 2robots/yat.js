# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# The item is one "event" at a specific time on the timeline
window.yat.OverviewView = class extends Backbone.View

  className: 'yat-timeline-overview'

  initialize: ->
    @render()

  remove: ->
    Backbone.View.prototype.remove.call(this);

  render: ->
    overview = $(window.yat.templates.timelineOverview())
    years = [@model.start.getFullYear()..@model.end.getFullYear()]
    itemWidth = Math.round(10000 / years.length, 2) / 100
    for y in years
      overview.append(window.yat.templates.timelineOverviewYear {year: y, width: itemWidth + '%'})
    overview.append(window.yat.templates.timelineOverviewSelection())
    @$el.html(overview)
