# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# The item is one "event" at a specific time on the timeline
window.yat.NavigationViewManager = class
  constructor: (@model) ->
    @initialize()
    @index = 0

  initialize: ->
    @paneWidth =  200 * (@model.length / 2)
    @startEnd = @model.getStartEnd()
    interval = Math.abs(moment(@startEnd.start).diff(@startEnd.end, 'days'))
    @pixelPerDay = Math.round(@paneWidth / interval)

  hasRenderCandidate: ->
    @index < @model.models.length

  getNextElement: ->
    item = @model.at(@index++)
    days = moment(item.get('date')).diff(@startEnd.start, 'days')
    {
      position: days * @pixelPerDay
      model: item
    }

  updateViewport: (@viewportPos) ->

  # get date for pixel
  get_date_for_offset: (offset) ->
    start = moment(@startEnd.start).clone()
    end = moment(@startEnd.end).clone()
    daysTotal = end.diff(start, 'days')
    days = offset / @pixelPerDay
    widthInDays = Math.round(@viewportPos.width / @pixelPerDay)

    #add the width of the viewport proportionally so that when fully scrolled to the right the value of "days" becomes "daysTotal"
    days += ( days / (daysTotal - widthInDays) ) * widthInDays

    start.add( 'days',  days)

  # get pixel offset for date
  get_offset_for_date: (date)->
    #width = $('.yat-current-position').width()
    #start = moment(@model.start)
    #end = moment(@model.end)
    #(date.diff(start) / end.diff(start)) * width
    #moment(date).clone()moment(@startEnd.start).clone()
    #date.startOf('day')
    start = moment(@startEnd.start).clone()
    end = moment(@startEnd.end).clone()
    daysTotal = end.diff(start, 'days')
    widthInDays = @viewportPos.width / @pixelPerDay
    r = moment(date).clone().diff(@startEnd.start, 'days')
    d = Math.round(r / (1 + (widthInDays / (daysTotal - widthInDays))))
    d * @pixelPerDay

  get_percentage_for_offset: (offset) ->
    start = moment(@startEnd.start).clone()
    end = moment(@startEnd.end).clone()
    daysTotal = end.diff(start, 'days')
    offset / (daysTotal * @pixelPerDay)

  get_offset_for_percentage: (percentage) ->
    start = moment(@startEnd.start).clone()
    end = moment(@startEnd.end).clone()
    daysTotal = end.diff(start, 'days')
    daysTotal * @pixelPerDay * percentage

