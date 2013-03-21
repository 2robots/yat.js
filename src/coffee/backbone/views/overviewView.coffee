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
    quarter_dateformat: 'D.M.'
  }

  selection_element: undefined
  current_date: undefined
  current_position: undefined

  initialize: ->
    @scrollLeft = 0
    @render()

  resize: ->
    scroll_inner_width = parseInt(@selection_element.find('.yat-position-inner').width(), 10)
    @selection_element.find('.yat-position-container').css('width', '100%')
    @selection_element.find('.yat-position-container').css('padding-left', @$el.width() - scroll_inner_width + 'px')
    @selection_element.find('.yat-position-container').css('padding-right', 0)
    @selection_element.find('.yat-position-container').css('left', '1px')
    if @current_position?
      if typeof @current_position == 'number'
        @jump_to_percentage @current_position
      else
        @jump_to @current_position

  render: ->
    that = @
    overview = $(window.yat.templates.timelineOverview())

    @selection_element = $(window.yat.templates.timelineOverviewSelection())

    setTimeout (->
      that.resize()
    ), 10

    that.selection_element.find('.yat-position-container').bind 'resize', (->
      if that.current_date?
        that.jump_to that.current_date
    )

    @$el.html(overview)
    @$el.append(@selection_element)

    # jump to the right position, when user clicks
    @selection_element.parent().bind 'mouseup', (event)->
      that.options.dispatcher.trigger 'overview_jump_to', that.get_date_for_offset (event.pageX - $('.yat-current-position').offset().left)

    $(window).resize ->
      setTimeout (-> 
        that.resize()
      ), 10
    that.options.dispatcher.on 'fullscreen_start', ->
      setTimeout (-> that.resize()), 10
    that.options.dispatcher.on 'fullscreen_end', ->
      setTimeout (-> that.resize()), 10

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

    @options.dispatcher.on 'navigation_elements_positioned', (years) ->
      that.render_quarters overview, years

  render_quarters: (overview, years) ->
    that = @
    last_year = _.last(years)
    last_year.width -= 0.002
    _.each years, (y) ->
      year_view = jQuery(window.yat.templates.timelineOverviewYear {year: y.start.year(), width: Math.round(10000 * y.width) / 100 + '%'})

      if moment([y.start.year(), 0]).isSame(y.start, 'day')
        className = 'first'
      else
        className = ''

      year_view.append(window.yat.templates.timelineOverviewQuarter {offset: 100 * y.left, title: '', className: className})
      _.each y.quarters, (q)->
        year_view.append(window.yat.templates.timelineOverviewQuarter {offset: 100 * q.left, title: '', className: ''})
      overview.append(year_view)
      if year_view.width() < 32
        year_view.find('span:first').empty()

  # jumps to a specific position expressed as percentage
  jump_to_percentage: (percentage, animate)->
    left = @get_offset_for_percentage(percentage)
    width = $('.yat-current-position').width()
    slider_width = $('.yat-position-inner').width()
    @scrollLeft = Math.floor(width - left) - slider_width
    if animate
      @$el.find('.yat-current-position').animate({
        scrollLeft: @scrollLeft
      }, @options.animation_duration)
    else
      @$el.find('.yat-current-position').scrollLeft @scrollLeft
    @current_position = percentage

  # jumps to the date
  jump_to: (date, animate)->
    left = @get_offset_for_date(date)
    width = $('.yat-current-position').width()
    slider_width = $('.yat-position-inner').width()
    @scrollLeft = Math.floor(width - left - slider_width/2)
    if animate
      @$el.find('.yat-current-position').animate({
        scrollLeft: @scrollLeft
      }, @options.animation_duration)
    else
      @$el.find('.yat-current-position').scrollLeft @scrollLeft
    @current_date = date

  # get pixel for a position expressed as percentage
  get_percentage_for_offset: (offset)->
    width = $('.yat-current-position').width()
    slider_width = $('.yat-position-inner').width()
    1 - (offset / (width - slider_width))

  # get pixel for a position expressed as percentage
  get_offset_for_percentage: (percentage)->
    width = $('.yat-current-position').width()
    slider_width = $('.yat-position-inner').width()
    percentage * (width - slider_width)

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
    percentage = offset / width
    start = moment(@model.start)
    end = moment(@model.end)
    moment(start).add( end.diff(start) * percentage ).startOf('day')
