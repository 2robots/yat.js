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
  next_index: 0
  total_index: 0

  options: {
    animation_duration: 200
    initial_element_count: 4
    id_prefix: ''
  }

  initialize: ->
    @render()

  remove: ->
    Backbone.View.prototype.remove.call(this);

  render: ->

    that = @

    # get viewport element list
    viewport = $(window.yat.templates.timelineViewportElementList())

    # render the navlinks
    navlinks = $(window.yat.templates.timelineViewportNavlinks())

    # render the viewport at all
    @$el.html(viewport)
    @$el.append(navlinks)

    # save total count of elements
    @total_index = @model.length

    # render all inital children
    setTimeout (->

      that.$el.find('ol.yat-elements').css('width', 0)

      _.times that.options.initial_element_count, (->
        that.insert_next_element()
      )
    ), 10

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

    @$el.find('> .yat-inner').bind 'scrollstart', ->
      that.options.dispatcher.trigger 'viewport_scrollstart'

    @$el.find('> .yat-inner').bind 'scrollstop', ->
      that.options.dispatcher.trigger 'viewport_scrollstop', that.getCurrentElementModels()

    # navlinks click
    @$el.find('.yat-navlinks .yat-left a').click ->
      that.options.dispatcher.trigger 'viewport_prev'
      that.options.dispatcher.trigger 'viewport_item_deselect'

    # navlinks click
    @$el.find('.yat-navlinks .yat-right a').click ->
      that.options.dispatcher.trigger 'viewport_next'
      that.options.dispatcher.trigger 'viewport_item_deselect'


    # listen to events

    # listen to jump_to events
    that.options.dispatcher.on 'viewport_jump_to', ->
      that.jump_to arguments[0], arguments[1]

    # trigger viewport_jump_to on click next and prev
    that.options.dispatcher.on 'viewport_prev', ->
      that.options.dispatcher.trigger 'viewport_jump_to', _.first(that.getCurrentElements()).prev()

    that.options.dispatcher.on 'viewport_next', ->
      that.options.dispatcher.trigger 'viewport_jump_to', _.last(that.getCurrentElements()).next()

    # open an element on click
    that.options.dispatcher.on 'viewport_item_select', ->
      that.open_element arguments[0]

    # close an element on click
    that.options.dispatcher.on 'viewport_item_deselect', ->
      that.close_open_element arguments[0]

    # load more elements on scroll
    that.options.dispatcher.on 'viewport_position_change', ->
      that.load_more()


  # returns all visible elements
  getCurrentElements: ->
    # minumum and maximum position-left
    scroll_l = @$el.find('> .yat-inner').scrollLeft()
    scroll_r = scroll_l + @$el.find('> .yat-inner').width()

    current_elements = [];

    @$el.find('ol.yat-elements').children().each ->

      el_width = $(this).outerWidth() +
        parseInt($(this).css('margin-left'), 10) +
        parseInt($(this).css('margin-right'), 10);

      if $(this).position().left >= scroll_l && ($(this).position().left + el_width) <= scroll_r
        current_elements.push($(this));

      if $(this).position().left > scroll_r
        return false;

    current_elements

  # get element_models
  getCurrentElementModels: ->

    that = @
    elements = []

    _.each @getCurrentElements(), ( (element)->
      elements.push({
        dom: element
        model: that.model.get(element.attr('id').substr that.options.id_prefix.length)
        })
    )
    elements

  # insert next element in collection
  insert_next_element: ->

    that = @
    model = @model.at @next_index
    element_view = new window.yat.viewportItemView {model: model}
    element = @$el.find('ol.yat-elements').append(element_view.$el)
    last = element.children().last()

    last.attr('id', @options.id_prefix + model.cid)
    @change_list_width( @element_width last)

    # viewport item select
    last.click ->
      if $(@).hasClass 'open'
        that.options.dispatcher.trigger 'viewport_item_deselect'
      else
        that.options.dispatcher.trigger 'viewport_item_select', $(@)

    @next_index++

  # load more elements on scroll
  load_more: ->

    # if we inserted all items, unbind the load_more action
    if (@next_index + 1) < @total_index
      that = @
      setTimeout (->
        that.insert_next_element()
      ), 10


  # scrolls to the given element
  jump_to: ->

    # if this element is defined
    if arguments[0][0] != undefined

      # get container width
      container_width = @$el.find('> .yat-inner').outerWidth()

      # get element width
      element_width =
        arguments[0].outerWidth() +
        parseInt(arguments[0].css("margin-left"), 10) +
        parseInt(arguments[0].css("margin-right"), 10);

      @$el.find('> .yat-inner').animate {
        scrollLeft: ( arguments[0].position().left - (container_width/2 - element_width/2) )
      }, {
        duration: @options.animation_duration
      }


  # open an element
  open_element: ->

    that = @

    # close any open elements first
    @close_open_element()

    element = arguments[0]

    # get the old width of the element
    old_element_width = @element_width element

    # open this element
    element.addClass 'open'

    # after opening the element adjsut the list width
    new_element_width = @element_width element
    @change_list_width new_element_width - old_element_width, true

    # center the element
    @options.dispatcher.trigger 'viewport_jump_to', element



  # close the open element
  close_open_element: ->

    that = @

    # decrese the container-width if there is an open element
    if @$el.find('ol.yat-elements li.open').length > 0

      # get the current element
      element = @$el.find('ol.yat-elements li.open').first()

      # get the old width of the element
      old_element_width = @element_width element

      @$el.find('ol.yat-elements li.open').removeClass 'open'

      # after closing of the element, adjust the list width
      new_element_width = @element_width element
      @change_list_width new_element_width - old_element_width, true



  # get total width of an element
  element_width: (element) ->
    element.outerWidth() + parseInt(element.css('margin-left'), 10) + parseInt(element.css('margin-right'), 10)


  # change the width of the list
  change_list_width: (width) ->

    width = parseInt(@$el.find('ol.yat-elements').css('width'), 10) + width
    @$el.find('ol.yat-elements').css 'width', width


