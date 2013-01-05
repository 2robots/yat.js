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
        tags: null,
        important: null
      },
      callbacks: {
        alterItems: function(elements) {
          return elements;
        },
        alterShorttitle: function(element) {
          return element.text();
        },
        alterDate: function(element) {
          return new Date(moment(element.text()));
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
        alterImportant: function(element) {
          return false;
        },
        beforeInit: null,
        afterInit: null
      },
      attributes: ['shorttitle', 'date', 'content', 'category', 'tags', 'important']
    };
    YatWrapper = (function() {
      var items;

      items = [];

      function YatWrapper(element, selectors, containerElement, callbacks, attributes) {
        this.element = element;
        this.containerElement = containerElement;
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
        $(this.element).find(this.options.selectors.items).each(function(i, v) {
          return t.registerChild(v);
        });
        return this.initBackbone();
      };

      YatWrapper.prototype.initBackbone = function() {
        $(this.element).hide();
        return new window.yat.App({
          items: items,
          containerElement: this.containerElement
        });
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
          if (val.length === 0) {
            val = $(child).filter(this.options.selectors[i]);
          }
          if (val.length > 0 && this.options.callbacks[cb_name] !== void 0) {
            obj[i] = this.options.callbacks[cb_name](val);
          } else {
            obj[i] = void 0;
          }
        }
        if (obj.content !== void 0 && obj.shorttitle !== void 0 && obj.date !== void 0) {
          return items.push(obj);
        }
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
