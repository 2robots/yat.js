# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# The APP
window.yat.App = class

  # options contains: items, containerElement (The DOM-Element whose content will be overwritten by the HTML of our timeline)
  constructor: (options) ->
    @dispatcher = _.extend({}, Backbone.Events)
    #@dispatcher.on('all', ->
    #  console.log(arguments)
    #)
    @items = new window.yat.ItemList options.items
    @timelineView = new window.yat.TimelineView {
      el: options.containerElement
      model: @items
      dispatcher: @dispatcher
    }

