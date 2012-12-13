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
    $(window).bind("resize.app", _.bind(this.resize, this));
    @resize()
    @render()
    @registerEventListener()

  remove: ->
    $(window).unbind("resize.app");
    Backbone.View.prototype.remove.call(this);

  registerEventListener: ->

    that = @

    # trigger events

    # bind touchmove (ios) and scroll (other browser) events
    @$el.bind 'touchmove', ->
      that.options.dispatcher.trigger 'navigation_position_change'

    @$el.scroll ->
      that.options.dispatcher.trigger 'navigation_position_change'

  resize: ->
    console.log 'resized'

  render: ->
    overview = $(window.yat.templates.timelineNavigationElementList())
    for item in @model.models
      overview.append(window.yat.templates.timelineNavigationElement {shorttitle: item.get('shorttitle'), linkHref: '#'})
    @$el.html(overview)
