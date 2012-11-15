// Generated by CoffeeScript 1.3.3
(function() {

  (function($, window) {
    var YatWrapper, defaults, document, pluginName;
    pluginName = 'yat';
    document = window.document;
    defaults = {
      selectors: {
        items: null,
        shorttitle: null,
        date: null,
        content: null,
        category: null,
        tags: null
      },
      callbacks: {
        alterItems: function(elements) {
          return elements;
        },
        alterShorttitle: function(element) {
          return element.text();
        },
        alterDate: function(element) {
          return element.text();
        },
        alterContent: function(element) {
          return element.html();
        },
        alterCategory: function(element) {
          return element.text();
        },
        alterTags: function(element) {
          if (element.text().length > 0) {
            return element.text().split(", ");
          } else {
            return [];
          }
        },
        beforeInit: null,
        afterInit: null
      },
      attributes: ['shorttitle', 'date', 'content', 'category', 'tags']
    };
    YatWrapper = (function() {

      function YatWrapper(element, selectors, callbacks, attributes) {
        this.element = element;
        this.options = {};
        this.options.selectors = $.extend({}, defaults.selectors, selectors);
        this.options.callbacks = $.extend({}, defaults.callbacks, callbacks);
        this.options.attributes = $.extend({}, defaults.attributes, attributes);
        this._defaults = defaults;
        this._name = pluginName;
        this.init();
      }

      YatWrapper.prototype.init = function() {
        var t;
        t = this;
        this.initBackbone();
        return $(this.element).find(this.options.selectors.items).each(function(i, v) {
          return t.registerChild(v);
        });
      };

      YatWrapper.prototype.initBackbone = function() {
        return console.log("INIT BACKBONE");
      };

      YatWrapper.prototype.registerChild = function(child) {
        var cb_name, i, n, obj, t, val, _ref;
        t = this;
        obj = {};
        _ref = this.options.attributes;
        for (n in _ref) {
          i = _ref[n];
          cb_name = 'alter' + t.ucfirst(i);
          val = $(child).find(this.options.selectors[i]);
          if (val.length > 0 && this.options.callbacks[cb_name] !== void 0) {
            obj[i] = this.options.callbacks[cb_name](val);
          } else {
            obj[i] = void 0;
          }
        }
        return console.log("REGISTER CHILD");
      };

      YatWrapper.prototype.ucfirst = function(str) {
        var f;
        str += '';
        return f = str.charAt(0).toUpperCase() + str.substr(1);
      };

      return YatWrapper;

    })();
    return $.fn[pluginName] = function(selectors, callbacks, attributes) {
      return this.each(function() {
        if (!$.data(this, "plugin_" + pluginName)) {
          return $.data(this, "plugin_" + pluginName, new YatWrapper(this, selectors, callbacks, attributes));
        }
      });
    };
  })(jQuery, window);

}).call(this);
