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

  options: {
    id_prefix: ''
  }

  fullscreen_placeholder: undefined

  initialize: ->
    @render()

  render: ->
    that = @

    @options.id_prefix = 'table' + _.random(0, 1000)

    @container = $(window.yat.templates.timelineContainer())

    @viewport = new window.yat.ViewportView {
        model: @model,
        dispatcher: @options.dispatcher,
        id_prefix: @options.id_prefix
    }

    @navigation = $(window.yat.templates.timelineNavigation())
    @overview = new window.yat.OverviewView {
        model: @model.getStartEnd(),
        dispatcher: @options.dispatcher
    }

    @navigationBar = new window.yat.NavigationView {
      model: @model,
      dispatcher: @options.dispatcher
    }
    @navigation.append(@overview.$el)
    @navigation.append(@navigationBar.$el)

    @container.children('.yat-timeline-inner1').append(@navigation)
    @container.children('.yat-timeline-inner1').append(@viewport.$el)
    that.$el.append(@container)

    #@fullscreen()

  fullscreen: ->
    that = @

    setTimeout (->
        that.$el.after '<div class="yat-fullscreen-placeholder" style="display:none" />'
        that.fullscreen_placeholder = that.$el.next()
        container = $('body').append('<div id="yat-fullscreen-' + that.options.id_prefix + '" />');
        container.append that.$el
    ), 1

  fullscreen_end: ->
    that = @

    setTimeout (->
        that.fullscreen_placeholder.after that.$el
        $('#yat-fullscreen-' + that.options.id_prefix).remove()
        that.fullscreen_placeholder.remove()
    ), 1




