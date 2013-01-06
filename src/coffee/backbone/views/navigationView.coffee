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

  options:
    position:
      top: '2.5'
    id_prefix: ''
    id_postfix: ''
    vertical_offset: 5
    horizontal_offset: 5
    navigation_height: 100
    margin_left: 30
    margin_right: 30

  mainElement = undefined

  className: 'yat-navigation'

  initialize: ->
    @options.dispatcher.trigger 'load_component_start'
    @viewManager = new window.yat.NavigationViewManager(
      @model
      {
        element_width: 200
        margin_left: @options.margin_left
        margin_right: @options.margin_right
      }
    )
    @elementList = $(window.yat.templates.timelineNavigationElementList())
    @mainElement = $("<div class='yat-inner' />")
    @mainElement.append(@elementList)
    @navigation_width = 0

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

  offset_to_percentage: (offset) ->
    offset / ( @navigation_width - @mainElement.width() - @options.horizontal_offset + @options.margin_right )

  percentage_to_offset: (percentage) ->
    percentage * ( @navigation_width - @mainElement.width() - @options.horizontal_offset + @options.margin_right )

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
      #percentage = that.viewManager.get_percentage_for_offset offset
      #percentage = offset / that.line
      #percentage = offset / _.max(_lastElements)
      that.options.dispatcher.trigger 'navigation_position_change', that.offset_to_percentage( offset )

    # bind the overview to viewport changes
    @options.dispatcher.on 'viewport_scrollstop', (elements) ->
      # if the first of this elements is the global first
      if _.first(arguments[0]).model.get("date") == startEnd.start
        that.jump_to_cid _.first(arguments[0]).model.cid, true

      # if the last of this elements is the global last
      else if _.last(arguments[0]).model.get("date") == startEnd.end
        that.jump_to_cid _.last(arguments[0]).model.cid, true

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
      current_position = that.offset_to_percentage(that.mainElement.scrollLeft())
      offset = (that.elementList.parent().width() / that.viewManager.paneWidth) / 2
      percentage = current_position - offset
      that.jump_to_percentage percentage, true

    @options.dispatcher.on 'navigation_next', ->
      current_position = that.offset_to_percentage(that.mainElement.scrollLeft())
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
    @placeholder_right = $(window.yat.templates.timelineNavigationPlaceholder())
    @placeholder_right.css('width', @options.margin_right)
    @elementList.append @placeholder_right
    @repositionElements(elements)

  renderMore: (item) ->
    that = @
    navElement = new window.yat.NavigationElementView
      model: item.model
      dispatcher: that.options.dispatcher
    navElement.$el.attr("id", @options.id_prefix + item.model.cid + @options.id_postfix)
    @elementList.append(navElement.$el)
    navElement

  repositionElements: (elements) ->
    that = @

    # Abstand nach Links in Pixeln, die neue Elemente mindestens haben m√ºssen
    @line = @options.margin_left

    # array: Speichert alle Elemente, deren rechter Rand rechts von der line sind
    @current_objects = []

    window.setTimeout( ->
      for el in elements
        @callIndex = 0
        that.arrange_element(el)
    , 10)

  arrange_element: (element) ->
    that = @
    success = false

    if !element.pos
      element.pos =
        left: element.position,
        top: 0,
        height: parseInt(element.view.$el.css('height'), 10)
        width: parseInt(element.view.$el.css('width'), 10)

    element.pos.nextLeft = ->
      @left + @width + that.options.horizontal_offset
    element.pos.nextTop = ->
      @top + @height + that.options.vertical_offset

    if element.pos.left > @line
      @line = element.pos.left

    @cleanup_current_objects()

    if @current_objects.length == 0
      element.pos.top = 0
      #element.pos.left = @line
      success = true
    else
      shortest_right = _.min @current_objects, (item) ->
        item.pos.nextLeft()
      shortest_right = shortest_right.pos.nextLeft() if shortest_right?

      # current_objects wird nach top-Wert ASC sortiert, durchgegangen:
      @current_objects = _.sortBy @current_objects, (item) ->
        item.pos.top

      element.pos.left = @line
      element.pos.top = 0

      if @position_is_valid @current_objects, element.pos
        success = true
      else
        _.each( @current_objects, (item) ->
          pos = _.clone element.pos
          pos.left = @line
          pos.top = item.pos.nextTop()
          if @position_is_valid @current_objects, pos
            element.pos.left = pos.left
            element.pos.top = pos.top
            success = true
        , @ )

    if success
      @current_objects.push element
      @current_objects = _.uniq @current_objects
      element.view.$el.css('left', element.pos.left + 'px')
      element.view.$el.css('top', element.pos.top + 'px')
      @placeholder_right.css('left', element.pos.left + element.pos.width)
      @navigation_width = element.pos.nextLeft()
    else
      if shortest_right > @line
        @line = shortest_right
      else
        @line += @options.horizontal_offset

      @cleanup_current_objects()
      element.pos.top = 0
      element.pos.left = @line
      @arrange_element element

  # checks whether the position intersects with any of the elements or is outside the navigation borders
  position_is_valid: (elements, position) ->
    if position.nextTop() < @options.navigation_height + @options.vertical_offset
      result = !_.some elements, (el) ->
        el.pos.left < position.nextLeft() && position.left < el.pos.nextLeft() &&
        el.pos.top < position.nextTop() && position.top < el.pos.nextTop()
      result
    else
      false

  cleanup_current_objects: ->
    start = @current_objects.length
    @current_objects = _.reject @current_objects, (item) ->
      item.pos.nextLeft() <= @line
    , @

  # jumps to a percentage position
  jump_to_percentage: (percentage, animate)->
    scrollLeft = @viewManager.get_offset_for_percentage(percentage)
    scrollLeft = @percentage_to_offset percentage
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

