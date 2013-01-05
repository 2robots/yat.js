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

_lastElements = []

# The item is one "event" at a specific time on the timeline
window.yat.NavigationView = class extends Backbone.View

  options: {
    position: {
      top: '2.5'
    }
    id_prefix: ''
    id_postfix: ''
    vertical_offset: 5
    horizontal_offset: 5
  }

  mainElement = undefined

  className: 'yat-navigation'

  initialize: ->
    @options.dispatcher.trigger 'load_component_start'
    @viewManager = new window.yat.NavigationViewManager(@model)
    @elementList = $(window.yat.templates.timelineNavigationElementList())
    @mainElement = $("<div class='yat-inner' />")
    @mainElement.append(@elementList)

    # render the navlinks
    navlinks = $(window.yat.templates.timelineNavigationNavlinks())

    @$el.html(@mainElement)

    # render the viewport at all
    @$el.append(navlinks)

    @registerEventListener()
    @render()

  _updateViewportPos: ->
    scrollLeft = @mainElement.scrollLeft()
    _viewportPos =
      left: scrollLeft
      right: scrollLeft + @mainElement.width()
      width: @mainElement.width()
    @viewManager.updateViewport(_viewportPos)

  registerEventListener: ->

    that = @
    startEnd = that.model.getStartEnd()

    # trigger events

    # bind touchmove (ios) and scroll (other browser) events
    @mainElement.bind 'touchmove', ->
      that.options.dispatcher.trigger 'navigation_position_change', that.viewManager.get_date_for_offset that.mainElement.scrollLeft()

    @mainElement.scroll ->
      offset = that.mainElement.scrollLeft()
      that.scrollOffset = offset
      percentage = that.viewManager.get_percentage_for_offset offset
      #percentage = offset / _.max(_lastElements)
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
        that.jump_to_cid arguments[0][index].model.cid, true

    @options.dispatcher.on 'navigation_position_change', ->
      that._updateViewportPos()

    @options.dispatcher.on 'overview_position_change', (percentage) ->
      that.jump_to_percentage percentage, false


    # navlinks click
    @$el.find('.yat-navlinks .yat-left a').click ->
      that.options.dispatcher.trigger 'navigation_prev'

    # navlinks click
    @$el.find('.yat-navlinks .yat-right a').click ->
      that.options.dispatcher.trigger 'navigation_next'

    @options.dispatcher.on 'navigation_prev', ->

      current_position = that.viewManager.get_percentage_for_offset(that.mainElement.scrollLeft())
      offset = (that.elementList.parent().width() / that.viewManager.paneWidth) / 2
      percentage = current_position - offset
      that.jump_to_percentage percentage, true

    @options.dispatcher.on 'navigation_next', ->
      current_position = that.viewManager.get_percentage_for_offset(that.mainElement.scrollLeft())
      offset = (that.elementList.parent().width() / that.viewManager.paneWidth) / 2
      percentage = current_position + offset
      that.jump_to_percentage percentage, true


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
    navElement.$el.attr("id", @options.id_prefix + item.model.cid + @options.id_postfix)
    @elementList.append(navElement.$el)

    #setTimeout (->
    #  that.repositionElement(navElement)
    #), 1

    navElement

  repositionElements: (elements) ->
    that = @
    window.setTimeout(->
      for item in elements
        if _lastElements.length > 4
          _lastElements.shift()
#        line = 0
#        position = item.position
#        if _lastElements[line] >= position
#          # there's not enough space in the first line --> reposition element
#          while _lastElements[line] >= position && line < 3
#            line++
#          if line > 2
#            position = _.min(_lastElements)
#            line = _.indexOf(_lastElements, position)
#        _lastElements[line] = position + item.view.width() + 5
#        item.view.$el.css('top', line * that.options.position.top + 'em')
#        item.view.$el.css('left', position + 'px')
        item.pos = {
          left: item.position,
          top: 0,
          height: parseInt(item.view.$el.css('height'), 10)
          width: parseInt(item.view.$el.css('width'), 10)
        }
        item.pos.nextLeft = item.pos.left + item.pos.width + 10
        item.pos.nextTop = ->
          @top + @height + 10


        if _lastElements.length > 0
          maxLeft = _.max _lastElements, (it) ->
            it.pos.nextLeft
          maxLeft = maxLeft.pos.nextLeft
        else
          maxLeft = 0

        if item.pos.left < maxLeft
          if _lastElements.length > 0
            maxTop = _.max _lastElements, (it) ->
              if item.pos.left < it.pos.nextLeft && item.pos.left > it.pos.left
                it.pos.nextTop()
              else
                0
            if typeof maxTop == 'object'
              maxTop = maxTop.pos.nextTop()
            maxTop = Math.max(maxTop, 0)
            item.pos.top = maxTop

            if item.pos.nextTop() > 110
              item.pos.top = 0
              firstLineItem = _.find _lastElements, (it) ->
                it.pos.top == 0
              if typeof firstLineItem == 'object'
                item.pos.left = firstLineItem.pos.nextLeft
            
            relevantItems = _.filter _lastElements, (it) ->
              item.pos.left < it.pos.nextLeft && item.pos.left > it.pos.left

            relevantItems = _.sortBy relevantItems, (it) ->
              it.pos.top

            if relevantItems.length > 0
              console.log relevantItems.length
              leftMost = _.min relevantItems, (it) ->
                it.pos.nextLeft
              item.pos.left = leftMost.pos.nextLeft
              item.pos.top = leftMost.pos.top

        item.view.$el.css('left', item.pos.left + 'px')
        item.view.$el.css('top', item.pos.top + 'px')

        _lastElements.push(item)
    , 0)



  # reposition an element next to last elements
  repositionElement2: (navElement) ->

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

  repositionElements2: (elements) ->

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

      that.viewManager.paneWidth = position + item.view.$el.outerWidth() - that.$el.outerWidth()
      that.viewManager.pixelPerDay = Math.round(that.viewManager.paneWidth / that.viewManager.interval)
      that.options.dispatcher.trigger 'load_component_end'
    , 0)

  addElement: ->

  # jumps to a percentage position
  jump_to_percentage: (percentage, animate)->
    scrollLeft = @viewManager.get_offset_for_percentage(percentage)
    if animate
      @mainElement.animate({
        scrollLeft: scrollLeft
      }, @options.animation_duration)
    else
      @mainElement.scrollLeft(scrollLeft)

  # jumps to the date
  jump_to: (date, animate)->
    scrollLeft = @viewManager.get_offset_for_date(date)
    if animate
      @mainElement.animate({
        scrollLeft: scrollLeft
      }, @options.animation_duration)
    else
      @mainElement.scrollLeft(scrollLeft)

  # jumps to element with Client ID
  jump_to_cid: (cid, animate)->
    if $('#' + @options.id_prefix + cid + @options.id_postfix)[0] != undefined
      scrollLeft = $('#' + @options.id_prefix + cid + @options.id_postfix).position().left - @$el.outerWidth()/2
      if animate
        @mainElement.animate({
          scrollLeft: scrollLeft
        }, @options.animation_duration)
      else
        @mainElement.scrollLeft(scrollLeft)

