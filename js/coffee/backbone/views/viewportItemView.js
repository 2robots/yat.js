// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.yat = window.yat || {};

  window.yat.viewportItemView = (function(_super) {

    __extends(_Class, _super);

    function _Class() {
      return _Class.__super__.constructor.apply(this, arguments);
    }

    _Class.prototype.tagName = 'li';

    _Class.prototype.initialize = function() {
      this.inDom = false;
      return this.render();
    };

    _Class.prototype.render = function() {
      var that;
      this.inDom = true;
      this.$el.html(window.yat.templates.timelineViewportElement(this.model.toJSON()));
      that = this;
      return setTimeout((function() {
        if ($(that.$el).find('.yat-element-inner2').height() > ($(that.$el).find('.yat-element-inner').height() - 10)) {
          that.$el.addClass('overflow');
          return that.$el.append(window.yat.templates.timelineViewportReadMore);
        }
      }));
    };

    return _Class;

  })(Backbone.View);

}).call(this);
