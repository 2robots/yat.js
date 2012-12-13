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

  className: 'yat-viewport'

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
      viewport.children().append(view.$el)
    )

    # render the navlinks
    navlinks = $(window.yat.templates.timelineViewportNavlinks())

    # render the viewport at all
    @$el.html(viewport)
    @$el.append(navlinks)

    @registerEventListener()


  # register listener for all events
  registerEventListener: ->

    that = @

    # trigger events

    # bind touchmove (ios) and scroll (other browser) events
    @$el.find('> .yat-inner').bind 'touchmove', ->
      that.options.dispatcher.trigger 'viewport_position_change'

    @$el.find('> .yat-inner').scroll ->
      that.options.dispatcher.trigger 'viewport_position_change'

    # viewport item select
    @$el.find('ol.yat-elements').children().click ->
      that.options.dispatcher.trigger 'viewport_item_select', $(@)

    # navlinks click
    @$el.find('.yat-navlinks .yat-left a').click ->
      that.options.dispatcher.trigger 'viewport_prev'

    # navlinks click
    @$el.find('.yat-navlinks .yat-right a').click ->
      that.options.dispatcher.trigger 'viewport_next'


    # listen to events

    # listen to jump_to events
    that.options.dispatcher.on 'viewport_jump_to', ->
      that.jump_to arguments[0]

    # trigger viewport_jump_to on click next and prev
    that.options.dispatcher.on 'viewport_prev', ->
      that.options.dispatcher.trigger 'viewport_jump_to', that.getCurrentElement().prev()

    that.options.dispatcher.on 'viewport_next', ->
      that.options.dispatcher.trigger 'viewport_jump_to', that.getCurrentElement().next()

    # open an element on click
    that.options.dispatcher.on 'viewport_item_select', ->
      that.open_element arguments[0]



  # returns the current left element of all visible elements
  getCurrentElement: ->
    # minumum and maximum position-left
    scroll_l = @$el.find('> .yat-inner').scrollLeft()
    scroll_r = scroll_l + @$el.find('> .yat-inner').width()

    current_element = null;

    @$el.find('ol.yat-elements').children().each ->
      if $(this).position().left >= scroll_l && $(this).position().left <= scroll_r
        current_element = $(this);
        return false;

    current_element


  # scrolls to the given element
  jump_to: ->
    @$el.find('> .yat-inner').animate {
      scrollLeft: arguments[0].position().left
    }, {
      duration: 100
    }

  # open element
  open_element: ->

    arguments[0].toggleClass 'open'

    @$el.find('ol.yat-elements').children(':not(.open)').each ->
      $(@).removeClass 'open'








