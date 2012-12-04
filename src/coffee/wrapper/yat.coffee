# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

# Note that when compiling with coffeescript, the plugin is wrapped in another
# anonymous function. We do not need to pass in undefined as well, since
# coffeescript uses (void 0) instead.
(($, window) ->

  pluginName = 'yat'
  document = window.document

  defaults =
    selectors:
      items: null
      shorttitle: null
      date: null
      content: null
      category: null
      tags: null
      important: null

    callbacks:
      alterItems: (elements) ->
        elements
      alterShorttitle: (element) ->
        element.text()

      alterDate: (element) ->
        new Date(element.text())

      alterContent: (element) ->
        element.html()

      alterCategory: (element) ->
        element.text()

      alterTags: (element) ->
        if element.text().length > 0
          element.text().split(", ");
        else
          []

      alterImportant: (element) ->
        return false

      beforeInit: null
      afterInit: null

    attributes: ['shorttitle', 'date', 'content', 'category', 'tags', 'important']


  # The actual plugin constructor
  class YatWrapper
    items = []

    # wrapper constructor
    constructor: (@element, selectors, @containerElement, callbacks, attributes) ->
      @options = {}
      @options.selectors = $.extend {}, defaults.selectors, selectors
      @options.callbacks = $.extend {}, defaults.callbacks, callbacks
      @options.attributes = $.extend {}, defaults.attributes, attributes
      @_defaults = defaults
      @_name = pluginName

      @init()

    # init the wrapper
    init: ->
      t = @

      # get all chhildren
      $(@element).find(@options.selectors.items).each (i,v) ->
         t.registerChild(v);

      @initBackbone()

    # initialize Backbone App
    initBackbone: ->
      console.log("INIT BACKBONE");
      $(@element).hide()
      new window.yat.App {items: items, containerElement: @containerElement}

    # register each child element
    registerChild: (child) ->

      t = @
      obj = {}

      # for each selector
      for n,i of @options.attributes

        cb_name = 'alter' + t.ucfirst(i)
        val = $(child).find(@options.selectors[i])

        # if we can't find any child, we try the selector on ourself
        if val.length == 0
          val = $(child).filter(@options.selectors[i])
        # if the dom object(s) is/are avaiable
        if val.length > 0 && @options.callbacks[cb_name] != undefined
          # get the output of the alter-callback
          obj[i] = @options.callbacks[cb_name] val
        else
          obj[i] = undefined

      console.log("REGISTER CHILD");
      items.push obj
      # THIS OS OUR OBJECT TO PASS TO THE BACKBONE APP
      #console.log obj;



    # helper function to provde ucfirst function
    ucfirst: (str) ->
      # http://kevin.vanzonneveld.net
      # original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
      # bugfixed by: Onno Marsman
      # improved by: Brett Zamir (http://brett-zamir.me)
      str += '';
      f = str.charAt(0).toUpperCase() + str.substr(1);


  # A really lightweight plugin wrapper around the constructor,
  # preventing against multiple instantiations
  $.fn[pluginName] = (selectors, callbacks, attributes) ->
    @each ->
      if !$.data(this, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new YatWrapper(@, selectors, callbacks, attributes))
)(jQuery, window)



