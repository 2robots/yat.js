# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {}

# The item is one "event" at a specific time on the timeline
window.yat.OverviewView = class extends Backbone.View

  className: 'yat-timeline-overview'

  options: {
    animation_duration: 200
  }

  selection_element: undefined
  current_date: undefined

  initialize: ->
    @scrollLeft = 0
    @render()

  render: ->
    that = @
    overview = $(window.yat.templates.timelineOverview())
    years = [@model.start.getFullYear()..@model.end.getFullYear()]
    days = moment(@model.end).clone().diff(moment(@model.start), 'days') + 1

    for y in years
      localStart = _.max([moment([y]), moment(@model.start)], (moment) -> moment.valueOf())
      localEnd = _.min([moment([y, 11, 31]), moment(@model.end)], (moment) -> moment.valueOf())
      localDays = localEnd.diff(localStart, 'days') + 1
      itemWidth = 100 / (days / localDays)
      overview.append(window.yat.templates.timelineOverviewYear {year: y, width: itemWidth + '%'})

    @selection_element = $(window.yat.templates.timelineOverviewSelection())

    setTimeout (->
      scroll_inner_width = parseInt(that.selection_element.find('.yat-position-inner').width(), 10)
      that.selection_element.find('.yat-position-container').css('width', '100%')
      that.selection_element.find('.yat-position-container').css('padding-left', '100%')
      that.selection_element.find('.yat-position-container').css('padding-right', scroll_inner_width/2)
      that.selection_element.find('.yat-position-container').css('left', -scroll_inner_width/2)

      that.jump_to(moment(that.model.start))
    ), 10

    that.selection_element.find('.yat-position-container').bind 'resize', (->
      that.jump_to that.current_date
    )

    @$el.html(overview)
    @$el.append(@selection_element)

    # jump to the right position, when user clicks
    @selection_element.parent().bind 'mouseup', (event)->
      that.options.dispatcher.trigger 'overview_jump_to', that.get_date_for_offset (event.pageX - $('.yat-current-position').offset().left)

    # listen to jump to events
    that.options.dispatcher.on 'overview_jump_to', ->
      animate = true
      if arguments.length > 1
        animate = arguments[1]
      that.jump_to(arguments[0], animate)

    # fire event, when user stops scrolling to position
#    @$el.find('.yat-current-position').bind 'scrollstop', ->
#      element = $(@)
#      that.options.dispatcher.trigger 'overview_position_change', 1 - element.scrollLeft() / element.width()

    @$el.find('.yat-current-position').scroll ->
      offset = that.get_percentage_for_offset $(@).scrollLeft()
      if that.scrollLeft != $(@).scrollLeft()
        that.options.dispatcher.trigger 'overview_position_change', offset

    # bind the overview to navigation changes
    @options.dispatcher.on 'navigation_position_change', (percentage) ->
      that.jump_to_percentage percentage, false

  # jumps to a specific position expressed as percentage
  jump_to_percentage: (percentage, animate)->

    left = @get_offset_for_percentage(percentage)
    width = $('.yat-current-position').width()
    @scrollLeft = Math.floor(width - left)
    if animate
      @$el.find('.yat-current-position').animate({
        scrollLeft: (width - left)
      }, @options.animation_duration)
    else
      @$el.find('.yat-current-position').scrollLeft (width - left)

  # jumps to the date
  jump_to: (date, animate)->
    left = @get_offset_for_date(date)
    width = $('.yat-current-position').width()
    if animate
      @$el.find('.yat-current-position').animate({
        scrollLeft: (width - left)
      }, @options.animation_duration)
    else
      @$el.find('.yat-current-position').scrollLeft (width - left)
    @current_date = date

  # get pixel for a position expressed as percentage
  get_percentage_for_offset: (offset)->
    width = $('.yat-current-position').width()
    1 - (offset / width)

  # get pixel for a position expressed as percentage
  get_offset_for_percentage: (percentage)->
    width = $('.yat-current-position').width()
    percentage * width

  # get pixel for date
  get_offset_for_date: (date)->
    date.startOf('day')
    width = $('.yat-current-position').width()
    start = moment(@model.start)
    end = moment(@model.end)

    (date.diff(start) / end.diff(start)) * width

  # get date for pixel
  get_date_for_offset: (offset)->

    width = $('.yat-current-position').width()
    start = moment(@model.start)
    end = moment(@model.end)

    moment(start).add( end.diff(start) * (offset / width) ).startOf('day')
