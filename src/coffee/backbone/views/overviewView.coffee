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
    #$(window).bind("resize.app", _.bind(this.resize, this));
    @resize()
    @render()

  remove: ->
    #$(window).unbind("resize.app");
    Backbone.View.prototype.remove.call(this);

  resize: ->
    console.log 'resized'

  render: ->
    that = @
    console.log @options.dispatcher
    overview = $(window.yat.templates.timelineOverview())
    years = [@model.start.getFullYear()..@model.end.getFullYear()]
    itemWidth = Math.round(10000 / years.length, 2) / 100
    for y in years
      overview.append(window.yat.templates.timelineOverviewYear {year: y, width: itemWidth + '%'})
    selection = $(window.yat.templates.timelineOverviewSelection())
    selection.draggable(
      axis: "x",
      containment: 'parent',
      drag: (event, ui) ->
        start = moment(that.model.start)
        end = moment(that.model.end)
        date = moment(start).add ( end.diff(start) * (ui.position.left / (that.$el.width() - selection.width())) )
        that.options.dispatcher.trigger('overview_change', date)
    )
    overview.append(selection)
    @$el.html(overview)
