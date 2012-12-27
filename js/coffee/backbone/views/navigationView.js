// Generated by CoffeeScript 1.3.3
(function() {
  var _lastElements, _viewportPos,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.yat = window.yat || {};

  _viewportPos = {
    left: 0,
    right: 0
  };

  _lastElements = [-10000, -10000, -10000];

  window.yat.NavigationView = (function(_super) {

    __extends(_Class, _super);

    function _Class() {
      return _Class.__super__.constructor.apply(this, arguments);
    }

    _Class.prototype.options = {
      position: {
        top: '2.5'
      }
    };

    _Class.prototype.className = 'yat-inner';

    _Class.prototype.initialize = function() {
      this.registerEventListener();
      this.viewManager = new window.yat.NavigationViewManager(this.model);
      this.overview = $(window.yat.templates.timelineNavigationElementList());
      this.$el.html(this.overview);
      return this.render();
    };

    _Class.prototype._updateViewportPos = function() {
      var scrollLeft;
      scrollLeft = this.$el.scrollLeft();
      _viewportPos = {
        left: scrollLeft,
        right: scrollLeft + this.$el.width(),
        width: this.$el.width()
      };
      return this.viewManager.updateViewport(_viewportPos);
    };

    _Class.prototype.registerEventListener = function() {
      var that;
      that = this;
      this.$el.bind('touchmove', function() {
        return that.options.dispatcher.trigger('navigation_position_change', that.viewManager.get_date_for_offset(that.$el.scrollLeft()));
      });
      this.$el.scroll(function() {
        var date;
        date = that.viewManager.get_date_for_offset(that.$el.scrollLeft());
        return that.options.dispatcher.trigger('navigation_position_change', date);
      });
      this.options.dispatcher.on('navigation_position_change', function() {
        return that._updateViewportPos();
      });
      return this.options.dispatcher.on('overview_position_change', function(date) {
        return that.jump_to(date, true);
      });
    };

    _Class.prototype.render = function() {
      var elements, item;
      this._updateViewportPos();
      elements = [];
      while (this.viewManager.hasRenderCandidate()) {
        item = this.viewManager.getNextElement();
        item.view = this.renderMore(item);
        elements.push(item);
      }
      return this.repositionElements(elements);
    };

    _Class.prototype.renderMore = function(item) {
      var navElement, that;
      that = this;
      navElement = new window.yat.NavigationElementView({
        model: item.model,
        dispatcher: that.options.dispatcher
      });
      this.overview.append(navElement.$el);
      return navElement;
    };

    _Class.prototype.repositionElements = function(elements) {
      var that;
      that = this;
      return window.setTimeout(function() {
        var item, line, position, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = elements.length; _i < _len; _i++) {
          item = elements[_i];
          line = 0;
          position = item.position;
          if (_lastElements[line] >= position) {
            while (_lastElements[line] >= position && line < 3) {
              line++;
            }
            if (line > 2) {
              position = _.min(_lastElements);
              line = _.indexOf(_lastElements, position);
            }
          }
          _lastElements[line] = position + item.view.width() + 5;
          item.view.$el.css('top', line * that.options.position.top + 'em');
          _results.push(item.view.$el.css('left', position + 'px'));
        }
        return _results;
      }, 0);
    };

    _Class.prototype.addElement = function() {};

    _Class.prototype.jump_to = function(date, animate) {
      var scrollLeft;
      scrollLeft = this.viewManager.get_offset_for_date(date);
      if (animate) {
        return this.$el.animate({
          scrollLeft: scrollLeft
        }, this.options.animation_duration);
      } else {
        return this.$el.scrollLeft(scrollLeft);
      }
    };

    return _Class;

  })(Backbone.View);

}).call(this);
