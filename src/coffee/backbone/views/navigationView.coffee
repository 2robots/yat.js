# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

_viewportPos =
  left: 0
  right: 0

_lastElements = [-10000, -10000, -10000]

# The item is one "event" at a specific time on the timeline
window.yat.NavigationView = class extends Backbone.View

  options: {
    position: {
      top: '2.5'
    }
  }

  className: 'yat-inner'

  initialize: ->
    @registerEventListener()
    @viewManager = new window.yat.NavigationViewManager(@model)
    @overview = $(window.yat.templates.timelineNavigationElementList())
    @$el.html(@overview)
    @render()

  _updateViewportPos: ->
    scrollLeft = @$el.scrollLeft()
    _viewportPos =
      left: scrollLeft
      right: scrollLeft + @$el.width()
      width: @$el.width()
    @viewManager.updateViewport(_viewportPos)

  registerEventListener: ->

    that = @

    # trigger events

    # bind touchmove (ios) and scroll (other browser) events
    @$el.bind 'touchmove', ->
      that.options.dispatcher.trigger 'navigation_position_change', that.viewManager.get_date_for_offset that.$el.scrollLeft()

    @$el.scroll ->
      date = that.viewManager.get_date_for_offset that.$el.scrollLeft()
      that.options.dispatcher.trigger 'navigation_position_change', date

    @options.dispatcher.on 'navigation_position_change', ->
      that._updateViewportPos()

    @options.dispatcher.on 'overview_position_change', (date) ->
      that.jump_to date, true

  render: ->
    @_updateViewportPos()
    elements = []
    while @viewManager.hasRenderCandidate()
      item = @viewManager.getNextElement()
      item.view = @renderMore(item)
      elements.push item
    @repositionElements(elements)

  renderMore: (item) ->
    that = @
    navElement = new window.yat.NavigationElementView( model: item.model, dispatcher: that.options.dispatcher)
    @overview.append(navElement.$el)
    navElement

  repositionElements: (elements) ->

    that = @
    window.setTimeout(->
      for item in elements
        line = 0
        position = item.position
        if _lastElements[line] >= position
          # there's not enough space in the first line --> reposition element
          while _lastElements[line] >= position && line < 3
            line++
          if line > 2
            position = _.min(_lastElements)
            line = _.indexOf(_lastElements, position)
        _lastElements[line] = position + item.view.width() + 5
        item.view.$el.css('top', line * that.options.position.top + 'em')
        item.view.$el.css('left', position + 'px')
    , 0)

  addElement: ->

  # jumps to the date
  jump_to: (date, animate)->
    scrollLeft = @viewManager.get_offset_for_date(date)
    if animate
      @$el.animate({
        scrollLeft: scrollLeft
      }, @options.animation_duration)
    else
      @$el.scrollLeft(scrollLeft)

