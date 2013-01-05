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
    var mainElement;

    __extends(_Class, _super);

    function _Class() {
      return _Class.__super__.constructor.apply(this, arguments);
    }

    _Class.prototype.options = {
      position: {
        top: '2.5'
      },
      vertical_offset: 5,
      horizontal_offset: 5
    };

    mainElement = void 0;

    _Class.prototype.className = 'yat-navigation';

    _Class.prototype.initialize = function() {
      var navlinks;
      this.options.dispatcher.trigger('load_component_start');
      this.viewManager = new window.yat.NavigationViewManager(this.model);
      this.elementList = $(window.yat.templates.timelineNavigationElementList());
      this.mainElement = $("<div class='yat-inner' />");
      this.mainElement.append(this.elementList);
      navlinks = $(window.yat.templates.timelineNavigationNavlinks());
      this.$el.html(this.mainElement);
      this.$el.append(navlinks);
      this.registerEventListener();
      return this.render();
    };

    _Class.prototype._updateViewportPos = function() {
      var scrollLeft;
      scrollLeft = this.mainElement.scrollLeft();
      _viewportPos = {
        left: scrollLeft,
        right: scrollLeft + this.mainElement.width(),
        width: this.mainElement.width()
      };
      return this.viewManager.updateViewport(_viewportPos);
    };

    _Class.prototype.registerEventListener = function() {
      var startEnd, that;
      that = this;
      startEnd = that.model.getStartEnd();
      this.mainElement.bind('touchmove', function() {
        return that.options.dispatcher.trigger('navigation_position_change', that.viewManager.get_date_for_offset(that.mainElement.scrollLeft()));
      });
      this.mainElement.scroll(function() {
        var offset, percentage;
        offset = that.mainElement.scrollLeft();
        that.scrollOffset = offset;
        percentage = that.viewManager.get_percentage_for_offset(offset);
        return that.options.dispatcher.trigger('navigation_position_change', percentage);
      });
      this.options.dispatcher.on('viewport_scrollstop', function(elements) {
        var index;
        if (_.first(arguments[0]).model.get("date") === startEnd.start) {
          return that.jump_to(moment(startEnd.start), true);
        } else if (_.last(arguments[0]).model.get("date") === startEnd.end) {
          return that.jump_to(moment(startEnd.end), true);
        } else {
          if (arguments[0].length % 2 !== 0) {
            index = (arguments[0].length - 1) / 2;
          } else {
            index = arguments[0].length / 2;
          }
          return that.jump_to(moment(arguments[0][index].model.get("date")), true);
        }
      });
      this.options.dispatcher.on('navigation_position_change', function() {
        return that._updateViewportPos();
      });
      this.options.dispatcher.on('overview_position_change', function(percentage) {
        return that.jump_to_percentage(percentage, false);
      });
      this.$el.find('.yat-navlinks .yat-left a').click(function() {
        return that.options.dispatcher.trigger('navigation_prev');
      });
      this.$el.find('.yat-navlinks .yat-right a').click(function() {
        return that.options.dispatcher.trigger('navigation_next');
      });
      this.options.dispatcher.on('navigation_prev', function() {
        var current_position, offset, percentage;
        current_position = that.viewManager.get_percentage_for_offset(that.mainElement.scrollLeft());
        offset = (that.elementList.parent().width() / that.viewManager.paneWidth) / 2;
        percentage = current_position - offset;
        return that.jump_to_percentage(percentage, true);
      });
      return this.options.dispatcher.on('navigation_next', function() {
        var current_position, offset, percentage;
        current_position = that.viewManager.get_percentage_for_offset(that.mainElement.scrollLeft());
        offset = (that.elementList.parent().width() / that.viewManager.paneWidth) / 2;
        percentage = current_position + offset;
        return that.jump_to_percentage(percentage, true);
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
      this.elementList.append(navElement.$el);
      return navElement;
    };

    _Class.prototype.repositionElement = function(navElement) {
      var distance, distance_to_prev, element, height, interval, last_index, last_model, model, next, offset_left, offset_top, parent_height, prev;
      element = navElement.$el;
      prev = $(element).prev();
      if (prev[0] !== void 0) {
        model = navElement.model;
        last_index = _.indexOf(this.model.models, model) - 1;
        last_model = this.model.at(last_index);
        interval = Math.abs(moment(model.get("date")).diff(last_model.get("date"), 'days'));
        this.startEnd = this.model.getStartEnd();
        distance = Math.abs(moment(this.startEnd.start).diff(this.startEnd.end, 'days'));
        distance_to_prev = parseInt(((this.model.length * element.width() / distance) * interval) / 10, 10);
        height = prev.height();
        parent_height = prev.parent().height();
        offset_top = prev.position().top;
        offset_left = prev.position().left;
        next = true;
        if (offset_top >= (height + this.options.vertical_offset)) {
          element.css("top", prev.position().top - height - this.options.vertical_offset);
          element.css("left", prev.position().left + distance_to_prev);
          if (this.is_there_an_element_at_this_positon(element.siblings(), element)) {
            next = true;
          } else {
            next = false;
          }
        }
        if (next && (height * 2 + offset_top + this.options.vertical_offset) < parent_height) {
          element.css("top", height + offset_top + this.options.vertical_offset);
          element.css("left", prev.position().left + distance_to_prev);
          if (this.is_there_an_element_at_this_positon(element.siblings(), element)) {
            next = true;
          } else {
            next = false;
          }
        }
        if (next) {
          if (prev.position().left + prev.width() > distance_to_prev) {
            distance_to_prev = prev.position().left + prev.width();
          }
          return element.css("left", distance_to_prev + this.options.horizontal_offset);
        }
      }
    };

    _Class.prototype.is_there_an_element_at_this_positon = function(elements, element) {
      var left, ret, top;
      left = element.position().left;
      top = element.position().top;
      ret = false;
      elements.each(function(i, e) {
        if ($(e).position().top <= top && $(e).position().top + $(e).height() >= top) {
          if ($(e).position().left <= left && $(e).position().left + $(e).width() >= left) {
            ret = true;
            return;
          }
        }
        if (($(e).position().left + $(e).width() + $(e).width()) < left) {

        }
      });
      return ret;
    };

    _Class.prototype.repositionElements = function(elements) {
      var that;
      that = this;
      return window.setTimeout(function() {
        var item, line, position, _i, _len;
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
          item.view.$el.css('left', position + 'px');
        }
        return that.options.dispatcher.trigger('load_component_end');
      }, 0);
    };

    _Class.prototype.addElement = function() {};

    _Class.prototype.jump_to_percentage = function(percentage, animate) {
      var scrollLeft;
      scrollLeft = this.viewManager.get_offset_for_percentage(percentage);
      if (animate) {
        return this.mainElement.animate({
          scrollLeft: scrollLeft
        }, this.options.animation_duration);
      } else {
        return this.mainElement.scrollLeft(scrollLeft);
      }
    };

    _Class.prototype.jump_to = function(date, animate) {
      var scrollLeft;
      scrollLeft = this.viewManager.get_offset_for_date(date);
      if (animate) {
        return this.mainElement.animate({
          scrollLeft: scrollLeft
        }, this.options.animation_duration);
      } else {
        return this.mainElement.scrollLeft(scrollLeft);
      }
    };

    return _Class;

  })(Backbone.View);

}).call(this);
