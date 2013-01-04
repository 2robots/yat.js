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
  total_index: 0
  current_scroll_position: 0

  options: {
    animation_duration: 200
    initial_element_count: 4
    id_prefix: ''
  }

  disable_load_more_till_scrollend = false;

  #rendered_elements: []
  not_rendered_yet: {}
  not_rendered_yet_position: 0
  not_rendered_yet_current_element: undefined
  rendered_count = 0

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

    _(@total_index).times (n)->
      that.not_rendered_yet[n] = false

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
      that.options.dispatcher.trigger 'viewport_position_change', direction

    @$el.find('> .yat-inner').scroll ->

      direction = 'left'
      if that.current_scroll_position < that.$el.find('> .yat-inner').scrollLeft()
        direction = 'right'

      that.current_scroll_position = that.$el.find('> .yat-inner').scrollLeft()
      that.options.dispatcher.trigger 'viewport_position_change', direction

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
      element = _.first(that.getCurrentElements()).prev()
      that.insert_prev_element()
      that.insert_prev_element()
      that.insert_prev_element()

      # jump to the element
      that.disable_load_more_till_scrollend = true
      that.options.dispatcher.trigger 'viewport_jump_to', element

    that.options.dispatcher.on 'viewport_next', ->
      element = _.last(that.getCurrentElements()).next()
      that.insert_next_element()
      that.insert_next_element()
      that.insert_next_element()

      # jump to the element
      that.disable_load_more_till_scrollend = true
      that.options.dispatcher.trigger 'viewport_jump_to', element

    # open an element on click
    that.options.dispatcher.on 'viewport_item_select', ->
      that.open_element arguments[0]

    # close an element on click
    that.options.dispatcher.on 'viewport_item_deselect', ->
      that.close_open_element arguments[0]

    # load more elements on scroll
    that.options.dispatcher.on 'viewport_position_change', ->
      that.load_more(arguments[0])

    # enable load more again after scroll-stops
    that.options.dispatcher.on 'viewport_scrollstop', ->
      that.disable_load_more_till_scrollend = false;

    # listen to jump_to events
    that.options.dispatcher.on 'navigation_element_selected', (navigationView) ->

      # get the element's position
      position = _.indexOf that.model.models, navigationView.model

      # if this element isn't rendered yet
      if that.not_rendered_yet[position] == false

        # render 10 elements on the way to the final element
        #dif = parseInt((final_index - that.rendered_count) / elements_to_render_on_the_way)
        #_(elements_to_render_on_the_way).times (n)->
        #  that.insert_element_at_position that.rendered_count + dif * n

        that.insert_element_at_position position

        that.insert_prev_element()
        that.insert_prev_element()
        that.insert_prev_element()

        that.insert_next_element()
        that.insert_next_element()
        that.insert_next_element()

      # jump to the element
      that.disable_load_more_till_scrollend = true
      that.jump_to $('#' + that.options.id_prefix + navigationView.model.cid)
      @not_rendered_yet_current_element = $('#' + that.options.id_prefix + navigationView.model.cid)
      @not_rendered_yet_position = position

      #that.performant_jump_to navigationView.model.cid

      #final_index = that.model.indexOf(that.model.get(navigationView.model.cid)) - 2
      #first_position = that.rendered_count
      # if thos element isn't rendered yet
      #if final_index > that.rendered_count

      #  elements_to_render_on_the_way = 10

        # render 10 elements on the way to the final element
      #  dif = parseInt((final_index - that.rendered_count) / elements_to_render_on_the_way)
      #  _(elements_to_render_on_the_way).times (n)->
      #    that.insert_element_at_position that.rendered_count + dif * n

        # render the final element
      #  that.insert_element_at_position final_index + 1
      #  that.insert_element_at_position final_index + 2
      #  that.insert_element_at_position final_index - 1
      #  that.insert_element_at_position final_index - 2
      #  that.insert_element_at_position final_index

        # render all elements, we missed by fast jumping to the new element
        #that.render_missing_elements first_position, final_index, $('#' + that.options.id_prefix + navigationView.model.cid).prev().prev(), $('#' + that.options.id_prefix + navigationView.model.cid)

      # jump to the final element
      #that.jump_to $('#' + that.options.id_prefix + navigationView.model.cid)






  # render missing elements
  #render_missing_elements: (first_position, last_position, last_element, fixed_element)->
  #
  #  if last_position <= first_position
  #    return true
  #
  #  that = @
  #  setTimeout (->
  #
  #    if !_.contains(that.rendered_elements, last_element.attr('id'))
  #      that.insert_element_at_position last_position-1, last_element
  #      that.$el.find('> .yat-inner').scrollLeft (that.$el.find('> .yat-inner').scrollLeft() + that.element_width(last_element.prev().prev()))
  #
  #    that.render_missing_elements first_position, last_position-1, last_element.prev(), fixed_element
  #  ), 5

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

  # get the current centered element
  getCurrentElement: ->
    elements = @getCurrentElements()
    index = parseInt(elements.length/2, 10)
    elements[index]

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

  # find next not rendered element
  find_next_not_rendered_element: ->

    index = @not_rendered_yet_position

    while(index < @total_index)
      if @not_rendered_yet[index] == false
        return index

      index++

    return @total_index

  # find prev not rendered element
  find_prev_not_rendered_element: ->

    index = @not_rendered_yet_position

    while(index >= 0)
      if @not_rendered_yet[index] == false
        return index

      index--

    return 0

  # insert next element in collection
  insert_next_element: ->
    index = @find_next_not_rendered_element()

    if index > 0
      el = jQuery('#' + @options.id_prefix + (@model.at index-1).cid)
    else
      el = undefined

    @insert_element_at_position index, undefined, el

  # insert prev element in collection
  insert_prev_element: ->

    index = @find_prev_not_rendered_element()

    if index <= @total_index
      el = jQuery('#' + @options.id_prefix + (@model.at index+1).cid)
    else
      el = undefined
    @insert_element_at_position index, el, undefined

  # insert an element with given position
  insert_element_at_position: (position, before, after)->

    if @not_rendered_yet[position] == false
      that = @
      model = @model.at position
      element_view = new window.yat.viewportItemView {model: model}

      element = null

      if before != undefined && before[0] != undefined
        before.before element_view.$el
        element = before.prev()
        @$el.find('> .yat-inner').scrollLeft(@$el.find('> .yat-inner').scrollLeft() + @element_width(element))
      else if after != undefined && after[0] != undefined
        after.after element_view.$el
        element = after.next()
      else
        all = @$el.find('ol.yat-elements').append(element_view.$el)
        element = all.children().last()

      element.attr('id', @options.id_prefix + model.cid)
      @change_list_width( @element_width element)

      # viewport item select
      element.click ->
        if $(@).hasClass 'overflow'
          if $(@).hasClass 'open'
            that.options.dispatcher.trigger 'viewport_item_deselect'
          else
            that.options.dispatcher.trigger 'viewport_item_select', $(@)

      element.data('yat-position', position)

      @not_rendered_yet[position] = true
      @not_rendered_yet_position = position
      @not_rendered_yet_current_element = element
      rendered_count++

  # load more elements on scroll
  load_more: (direction)->

    if rendered_count < @total_index && !@disable_load_more_till_scrollend
      if direction == 'left'
        @insert_prev_element()
      else
        @insert_next_element()

      return true

    return false


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

      if arguments[1] != undefined && arguments[1] == false
        @$el.find('> .yat-inner').scrollLeft arguments[0].position().left - (container_width/2 - element_width/2)
      else
        @$el.find('> .yat-inner').animate {
          scrollLeft: ( arguments[0].position().left - (container_width/2 - element_width/2) )
        }, {
          duration: @options.animation_duration
        }

      @not_rendered_yet_position = arguments[0].data("yat-position")
      @not_rendered_yet_current_element = arguments[0]


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


