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

  options: {
    animation_duration: 200
  }

  initialize: ->
    @render()

  remove: ->
    Backbone.View.prototype.remove.call(this);

  render: ->
    that = @
    overview = $(window.yat.templates.timelineOverview())
    years = [@model.start.getFullYear()..@model.end.getFullYear()]
    itemWidth = 100 / years.length

    for y in years
      overview.append(window.yat.templates.timelineOverviewYear {year: y, width: itemWidth + '%'})

    selection = $(window.yat.templates.timelineOverviewSelection())

    setTimeout (->
      main_width = parseInt(selection.css('width'), 10)
      inner_width = parseInt(selection.find('.yat-position-inner').css('width'), 10)
      selection.find('.yat-position-container').css('width', main_width)
      selection.find('.yat-position-container').css('padding-left', (main_width - inner_width))

      that.jump_to(moment(that.model.start))
    ), 10

    @$el.html(overview)
    @$el.append(selection)

    # jump to the right position, when user clicks
    selection.parent().click (event)->
      that.options.dispatcher.trigger 'overview_jump_to', that.get_date_for_offset (event.pageX - $('.yat-current-position').offset().left)

    # listen to jump to events
    that.options.dispatcher.on 'overview_jump_to', ->

      animate = true

      if arguments.length > 1
        animate = arguments[1]

      that.jump_to(arguments[0], animate)

    # fire event, when user stops scrolling to position
    @$el.find('.yat-current-position').bind 'scrollstop', ->
      pos_left = $('.yat-position-inner').offset().left
      element_width = $('.yat-position-inner').width()
      that.options.dispatcher.trigger 'overview_position_change', that.get_date_for_offset (pos_left - $('.yat-current-position').offset().left)

    # bind the overview to viewport changes
    @options.dispatcher.on 'viewport_scrollstop', ->
      that.jump_to moment(arguments[0][0].model.get("date")), true

  # jumps to the date
  jump_to: (date, animate)->

    left = @get_offset_for_date(date)
    width = $('.yat-current-position').width()
    element_width = $('.yat-position-inner').width()

    if animate
      @$el.find('.yat-current-position').animate({
        scrollLeft: (width - left - (element_width/2))
      }, @options.animation_duration)
    else
      @$el.find('.yat-current-position').scrollLeft (width - left - (element_width/2))

  # get pixel for date
  get_offset_for_date: (date)->

    width = $('.yat-current-position').width()
    start = moment(@model.start)
    end = moment(@model.end)

    (date.diff(start) / end.diff(start)) * width

  # get date for pixel
  get_date_for_offset: (offset)->

    width = $('.yat-current-position').width()
    start = moment(@model.start)
    end = moment(@model.end)

    moment(start).add( end.diff(start) * (offset / width) )




