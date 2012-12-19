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
    paneWidth = 150 * (@model.length / 2)
    @startEnd = @model.getStartEnd()
    interval = Math.abs(moment(@startEnd.start).diff(@startEnd.end, 'days'))
    @pixelPerDay = Math.round(paneWidth / interval)

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
  get_date_for_offset: (offset)->
    moment(@startEnd.start).clone().add( 'days', Math.round(offset / @pixelPerDay) )