# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# The item is one "event" at a specific time on the timeline
window.yat.NavigationView = class extends Backbone.View

  className: 'yat-inner'

  initialize: ->
    @render()
    @registerEventListener()

  remove: ->
    Backbone.View.prototype.remove.call(this);

  registerEventListener: ->

    that = @

    # trigger events

    # bind touchmove (ios) and scroll (other browser) events
    @$el.bind 'touchmove', ->
      that.options.dispatcher.trigger 'navigation_position_change'

    @$el.scroll ->
      that.options.dispatcher.trigger 'navigation_position_change'

  render: ->
    overview = $(window.yat.templates.timelineNavigationElementList())
    paneWidth = 150 * (@model.length / 2)
    startEnd = @model.getStartEnd()
    interval = Math.abs(moment(startEnd.start).diff(startEnd.end, 'days'))
    pixelPerDay = Math.round(paneWidth / interval)
    console.log(paneWidth, interval, pixelPerDay)
    lastElements = [-10000, -10000, -10000]
    elements = []
    for item in @model.models
      navElement = $(window.yat.templates.timelineNavigationElement {shorttitle: item.get('shorttitle'), linkHref: '#'})
      days = moment(item.get('date')).diff(startEnd.start, 'days')
      position = days * pixelPerDay

      line = 0
      if lastElements[line] >= position
        # there's not enough space in the first line --> reposition element
        while lastElements[line] >= position && line < 3
          line++
        if line > 2
          line = 0
          position = lastElements[line]

      lastElements[line] = position + 155
      console.log(item.get('shorttitle'), line, position)
      navElement.css('top', line * 25 + 'px')
      navElement.css('left', position + 'px')
      overview.append(navElement)
    @$el.html(overview)
