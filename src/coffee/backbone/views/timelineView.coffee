# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# The item is one "event" at a specific time on the timeline
window.yat.TimelineView = class extends Backbone.View

  className: 'yat-inner'

  options: {
    id_prefix: ''
  }

  fullscreen_placeholder: undefined
  fullscreen_button: undefined
  fullscreen_button_end: undefined

  initialize: ->
    @render()

  render: ->
    that = @

    @options.id_prefix = 'table' + _.random(0, 1000)

    @container = $(window.yat.templates.timelineContainer())

    @viewport = new window.yat.ViewportView {
        model: @model,
        dispatcher: @options.dispatcher,
        id_prefix: @options.id_prefix
    }

    @navigation = $(window.yat.templates.timelineNavigation())
    @overview = new window.yat.OverviewView {
        model: @model.getStartEnd(),
        dispatcher: @options.dispatcher
    }

    @navigationBar = new window.yat.NavigationView {
      model: @model,
      dispatcher: @options.dispatcher
    }
    @navigation.append(@overview.$el)
    @navigation.append(@navigationBar.$el)

    @container.children('.yat-timeline-inner1').append(@navigation)
    @container.children('.yat-timeline-inner1').append(@viewport.$el)

    @fullscreen_button = $(window.yat.templates.timelineFullScreen())
    @fullscreen_button_end = $(window.yat.templates.timelineFullScreenEnd())
    @fullscreen_button_end.hide()

    @fullscreen_button.click ->
      that.options.dispatcher.trigger 'fullscreen_start'

    @fullscreen_button_end.click ->
      that.options.dispatcher.trigger 'fullscreen_end'

    @options.dispatcher.on 'fullscreen_start', ->
      that.fullscreen_start()

    @options.dispatcher.on 'fullscreen_end', ->
      that.fullscreen_end()

    @container.append @fullscreen_button
    @container.append @fullscreen_button_end

    that.$el.append(@container)

  fullscreen_start: ->
    that = @
    current_element = that.viewport.getCurrentElement()

    that.$el.after '<div class="yat-fullscreen-placeholder" style="display:none" />'
    that.fullscreen_placeholder = that.$el.next()
    container = $('<div class="yat-fullscreen" id="yat-fullscreen-' + that.options.id_prefix + '" />')
    $('body').append container
    container.append that.$el

    that.viewport.insert_prev_element(that.viewport.getCurrentElements().length + 2)
    that.viewport.insert_next_element(that.viewport.getCurrentElements().length + 2)
    that.viewport.disable_load_more_till_scrollend = true
    that.viewport.jump_to current_element, true, (->
      that.viewport.disable_load_more_till_scrollend = false
    )

    that.fullscreen_button_end.show()
    that.fullscreen_button.hide()

  fullscreen_end: ->
    that = @
    current_element = that.viewport.getCurrentElement()

    that.fullscreen_placeholder.after that.$el
    $('#yat-fullscreen-' + that.options.id_prefix).remove()
    that.fullscreen_placeholder.remove()

    that.viewport.insert_prev_element(that.viewport.getCurrentElements().length + 2)
    that.viewport.insert_next_element(that.viewport.getCurrentElements().length + 2)
    that.viewport.disable_load_more_till_scrollend = true
    that.viewport.jump_to current_element, true, (->
      that.viewport.disable_load_more_till_scrollend = false
    )

    that.fullscreen_button_end.hide()
    that.fullscreen_button.show()




