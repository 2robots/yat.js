// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.yat = window.yat || {};

  window.yat.ViewportView = (function(_super) {

    __extends(_Class, _super);

    function _Class() {
      return _Class.__super__.constructor.apply(this, arguments);
    }

    _Class.prototype.className = 'yat-inner';

    _Class.prototype.initialize = function() {
      $(window).bind("resize.app", _.bind(this.resize, this));
      this.resize();
      return this.render();
    };

    _Class.prototype.remove = function() {
      $(window).unbind("resize.app");
      return Backbone.View.prototype.remove.call(this);
    };

    _Class.prototype.resize = function() {
      return console.log('resized');
    };

    _Class.prototype.render = function() {
      var viewport;
      viewport = $(window.yat.templates.timelineViewport());
      return this.$el.html(viewport);
    };

    return _Class;

  })(Backbone.View);

}).call(this);
