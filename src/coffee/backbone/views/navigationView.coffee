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

    vertical_offset: 5
    horizontal_offset: 5
  }

  className: 'yat-inner'

  initialize: ->
    @registerEventListener()
    @viewManager = new window.yat.NavigationViewManager(@model)
    @elementList = $(window.yat.templates.timelineNavigationElementList())
    @$el.html(@elementList)
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
    startEnd = that.model.getStartEnd()

    # trigger events

    # bind touchmove (ios) and scroll (other browser) events
    @$el.bind 'touchmove', ->
      that.options.dispatcher.trigger 'navigation_position_change', that.viewManager.get_date_for_offset that.$el.scrollLeft()

    @$el.scroll ->
      offset = that.$el.scrollLeft()
      that.scrollOffset = offset
      percentage = that.viewManager.get_percentage_for_offset offset
      that.options.dispatcher.trigger 'navigation_position_change', percentage

    # bind the overview to viewport changes
    @options.dispatcher.on 'viewport_scrollstop', (elements) ->
      # if the first of this elements is the global first
      if _.first(arguments[0]).model.get("date") == startEnd.start
        that.jump_to moment(startEnd.start), true

      # if the last of this elements is the global last
      else if _.last(arguments[0]).model.get("date") == startEnd.end
        that.jump_to moment(startEnd.end), true

      # default take the middle one
      else
        if arguments[0].length % 2 != 0
          index = (arguments[0].length - 1) / 2
        else
          index = arguments[0].length / 2

        that.jump_to moment(arguments[0][index].model.get("date")), true

    @options.dispatcher.on 'navigation_position_change', ->
      that._updateViewportPos()

    @options.dispatcher.on 'overview_position_change', (percentage) ->
      that.jump_to_percentage percentage, false

  render: ->
    @_updateViewportPos()
    elements = []
    while @viewManager.hasRenderCandidate()
      item = @viewManager.getNextElement()
      item.view = @renderMore(item)
      elements.push item
    #@repositionElements(elements)

  renderMore: (item) ->
    that = @
    navElement = new window.yat.NavigationElementView( model: item.model, dispatcher: that.options.dispatcher)
    @elementList.append(navElement.$el)

    setTimeout (->
      that.repositionElement(navElement)
    ), 1

    navElement

  # reposition an element next to last elements
  repositionElement: (navElement) ->

    element = navElement.$el
    prev = $(element).prev()

    if prev[0] != undefined

      model = navElement.model
      last_index = _.indexOf(@model.models, model) - 1
      last_model = @model.at(last_index)

      interval = Math.abs(moment(model.get("date")).diff(last_model.get("date"), 'days'))
      @startEnd = @model.getStartEnd()
      distance = Math.abs(moment(@startEnd.start).diff(@startEnd.end, 'days'))
      distance_to_prev = parseInt(((@model.length * element.width() / distance) * interval) / 10, 10)

      height = prev.height()
      parent_height = prev.parent().height()
      offset_top = prev.position().top
      offset_left = prev.position().left

      next = true
      # try to place it on top of last element
      if offset_top >= (height + @options.vertical_offset)
        element.css("top", prev.position().top - height - @options.vertical_offset)
        element.css("left", prev.position().left + distance_to_prev)

        if @is_there_an_element_at_this_positon(element.siblings(), element)
          next = true
        else
          next = false

      # try to place it under last element
      if next && (height*2 + offset_top + @options.vertical_offset) < parent_height
        element.css("top", height + offset_top + @options.vertical_offset)
        element.css("left", prev.position().left + distance_to_prev)

        if @is_there_an_element_at_this_positon(element.siblings(), element)
          next = true
        else
          next = false

      # try to place it next to last element
      if next
        if prev.position().left + prev.width() > distance_to_prev
          distance_to_prev = prev.position().left + prev.width()
        element.css("left", distance_to_prev + @options.horizontal_offset )




  is_there_an_element_at_this_positon: (elements, element)->

    left = element.position().left
    top = element.position().top

    ret = false

    elements.each (i,e)->

      if $(e).position().top <= top && $(e).position().top+$(e).height() >= top
        if $(e).position().left <= left && $(e).position().left+$(e).width() >= left
          ret = true
          return

      if ($(e).position().left + $(e).width() + $(e).width()) < left
        return

    return ret

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

  # jumps to a percentage position
  jump_to_percentage: (percentage, animate)->
    scrollLeft = @viewManager.get_offset_for_percentage(percentage)
    if animate
      @$el.animate({
        scrollLeft: scrollLeft
      }, @options.animation_duration)
    else
      @$el.scrollLeft(scrollLeft)

  # jumps to the date
  jump_to: (date, animate)->
    scrollLeft = @viewManager.get_offset_for_date(date)
    if animate
      @$el.animate({
        scrollLeft: scrollLeft
      }, @options.animation_duration)
    else
      @$el.scrollLeft(scrollLeft)

