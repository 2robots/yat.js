# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# The item is one "event" at a specific time on the timeline
window.yat.ViewportView = class extends Backbone.View

  className: 'yat-inner'

  initialize: ->
    @render()

  remove: ->
    Backbone.View.prototype.remove.call(this);

  render: ->

    # get viewport element list
    viewport = $(window.yat.templates.timelineViewportElementList())

    # render all the children
    @model.each((item) ->
      view = new window.yat.viewportItemView {model: item}
      viewport.append(view.$el)
    )

    # render the navlinks
    navlinks = $(window.yat.templates.timelineViewportNavlinks())

    # render the viewport at all
    @$el.html(viewport)
    @$el.parent().append(navlinks)

    @registerEventListener()


  # register listener for all events
  registerEventListener: ->

    # bind touchmove (ios) and scroll (other browser) events
    @$el.bind 'touchmove', ->
      console.log "touchmove"

    @$el.scroll ->
      console.log "scroll"

    # viewport item select
    @$el.children().first().children().click ->
      console.log "viewport item click"