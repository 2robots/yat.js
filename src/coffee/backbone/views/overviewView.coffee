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
    $(window).bind("resize.app", _.bind(this.resize, this));
    @resize()
    @render()

  remove: ->
    $(window).unbind("resize.app");
    Backbone.View.prototype.remove.call(this);

  resize: ->
    console.log 'resized'

  render: ->
    overview = $(window.yat.templates.timelineOverview())
    for y in [@model.start.getFullYear()..@model.end.getFullYear()]
      overview.append(window.yat.templates.timelineOverviewYear {year: y})
    overview.append(window.yat.templates.timelineOverviewSelection())
    @$el.html(overview)
