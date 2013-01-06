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

  _lastElements = [];

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
      id_prefix: '',
      id_postfix: '',
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
          return that.jump_to_cid(arguments[0][index].model.cid, true);
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
      navElement.$el.attr("id", this.options.id_prefix + item.model.cid + this.options.id_postfix);
      this.elementList.append(navElement.$el);
      return navElement;
    };

    _Class.prototype.repositionElements = function(elements) {
      var that;
      that = this;
      this.line = 0;
      this.current_objects = [];
      return window.setTimeout(function() {
        var el, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = elements.length; _i < _len; _i++) {
          el = elements[_i];
          this.callIndex = 0;
          that.arrange_element(el);
          _results.push(console.log(that.line));
        }
        return _results;
      }, 10);
    };

    _Class.prototype.arrange_element = function(element) {
      var shortest_right, success;
      success = false;
      if (!element.pos) {
        element.pos = {
          left: element.position,
          top: 0,
          height: parseInt(element.view.$el.css('height'), 10),
          width: parseInt(element.view.$el.css('width'), 10)
        };
      }
      element.pos.nextLeft = function() {
        return this.left + this.width + 10;
      };
      element.pos.nextTop = function() {
        return this.top + this.height + 10;
      };
      if (element.pos.left > this.line) {
        this.line = element.pos.left;
      }
      this.cleanup_current_objects();
      if (this.current_objects.length === 0) {
        element.pos.top = 0;
        success = true;
      } else {
        shortest_right = _.min(this.current_objects, function(item) {
          return item.pos.nextLeft();
        });
        if (shortest_right != null) {
          shortest_right = shortest_right.pos.nextLeft();
        }
        console.log('shortest_right', shortest_right);
        this.current_objects = _.sortBy(this.current_objects, function(item) {
          return item.pos.top;
        });
        element.pos.left = this.line;
        element.pos.top = 0;
        if (this.position_is_valid(this.current_objects, element.pos)) {
          success = true;
        } else {
          _.each(this.current_objects, function(item) {
            element.pos.left = this.line;
            element.pos.top = item.pos.nextTop();
            if (this.position_is_valid(this.current_objects, element.pos)) {
              return success = true;
            }
          }, this);
        }
      }
      if (success) {
        this.current_objects.push(element);
        this.current_objects = _.uniq(this.current_objects);
        element.view.$el.css('left', element.pos.left + 'px');
        return element.view.$el.css('top', element.pos.top + 'px');
      } else {
        console.log(shortest_right, this.line, element.pos.nextLeft(), element.pos);
        if (shortest_right > this.line) {
          this.line = shortest_right;
        } else {
          console.log('+10');
          this.line += 10;
        }
        this.cleanup_current_objects();
        element.pos.top = 0;
        element.pos.left = this.line;
        console.log('line pos', this.line);
        return this.arrange_element(element);
      }
    };

    _Class.prototype.position_is_valid = function(elements, position) {
      var result;
      if (position.nextTop() < 110) {
        result = !_.some(elements, function(el) {
          return el.pos.left < position.nextLeft() && position.left < el.pos.nextLeft() && el.pos.top < position.nextTop() && position.top < el.pos.nextTop();
        });
        return result;
      } else {
        return false;
      }
    };

    _Class.prototype.cleanup_current_objects = function() {
      var start;
      start = this.current_objects.length;
      return this.current_objects = _.reject(this.current_objects, function(item) {
        return item.pos.nextLeft() <= this.line;
      }, this);
    };

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

    _Class.prototype.jump_to_cid = function(cid, animate) {
      var scrollLeft;
      if ($('#' + this.options.id_prefix + cid + this.options.id_postfix)[0] !== void 0) {
        scrollLeft = $('#' + this.options.id_prefix + cid + this.options.id_postfix).position().left - this.$el.outerWidth() / 2;
        if (animate) {
          return this.mainElement.animate({
            scrollLeft: scrollLeft
          }, this.options.animation_duration);
        } else {
          return this.mainElement.scrollLeft(scrollLeft);
        }
      }
    };

    return _Class;

  })(Backbone.View);

}).call(this);
