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

  compontent_load_counter: 0

  initialize: ->
    @render()

  render: ->
    that = @

    @container = $(window.yat.templates.timelineContainer())

    # LOADING
    @container.addClass 'loading'

    that.options.dispatcher.on 'load_component_start', ->
      that.compontent_load_counter++

    that.options.dispatcher.on 'load_component_end', ->
      that.compontent_load_counter--

      if that.compontent_load_counter <= 0
        that.container.removeClass 'loading'

    @$el.append(that.container)

    window.setTimeout (->
      that.options.id_prefix = 'table' + _.random(0, 1000)

      that.viewport = new window.yat.ViewportView {
          model: that.model,
          dispatcher: that.options.dispatcher,
          id_prefix: that.options.id_prefix
      }

      that.overview = new window.yat.OverviewView {
          model: that.model.getStartEnd(),
          dispatcher: that.options.dispatcher
      }

      that.navigation = new window.yat.NavigationView {
        model: that.model,
        dispatcher: that.options.dispatcher
      }
      that.navigation.$el.append(that.overview.$el)

      that.container.children('.yat-timeline-inner1').append(that.navigation.$el)
      that.container.children('.yat-timeline-inner1').append(that.viewport.$el)

      that.fullscreen_button = $(window.yat.templates.timelineFullScreen())
      that.fullscreen_button_end = $(window.yat.templates.timelineFullScreenEnd())
      that.fullscreen_button_end.hide()

      that.fullscreen_button.click ->
        that.options.dispatcher.trigger 'fullscreen_start'

      that.fullscreen_button_end.click ->
        that.options.dispatcher.trigger 'fullscreen_end'

      that.options.dispatcher.on 'fullscreen_start', ->
        that.fullscreen_start()

      that.options.dispatcher.on 'fullscreen_end', ->
        that.fullscreen_end()

      that.container.append that.fullscreen_button
      that.container.append that.fullscreen_button_end
    ), 1



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




