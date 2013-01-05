# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# The item is one "event" at a specific time on the timeline
window.yat.NavigationElementView = class extends Backbone.View

  tagName: 'li'

  events:
    'click': ->
      @options.dispatcher.trigger 'navigation_element_selected', @
      false

  initialize: ->
    @render()

  render: ->
    @$el.append(window.yat.templates.timelineNavigationElement {shorttitle: @model.get('shorttitle'), linkHref: '#'})

    if @model.get('category') != undefined
      @$el.addClass 'cat-' + @model.get('category')

  width: ->
    @$el.width()