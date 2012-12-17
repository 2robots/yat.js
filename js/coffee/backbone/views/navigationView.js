// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.yat = window.yat || {};

  window.yat.NavigationView = (function(_super) {

    __extends(_Class, _super);

    function _Class() {
      return _Class.__super__.constructor.apply(this, arguments);
    }

    _Class.prototype.className = 'yat-inner';

    _Class.prototype.initialize = function() {
      this.render();
      return this.registerEventListener();
    };

    _Class.prototype.remove = function() {
      return Backbone.View.prototype.remove.call(this);
    };

    _Class.prototype.registerEventListener = function() {
      var that;
      that = this;
      this.$el.bind('touchmove', function() {
        return that.options.dispatcher.trigger('navigation_position_change');
      });
      return this.$el.scroll(function() {
        return that.options.dispatcher.trigger('navigation_position_change');
      });
    };

    _Class.prototype.render = function() {
      var days, elements, interval, item, lastElements, line, navElement, overview, paneWidth, pixelPerDay, position, startEnd, _i, _len, _ref;
      overview = $(window.yat.templates.timelineNavigationElementList());
      paneWidth = 150 * (this.model.length / 2);
      startEnd = this.model.getStartEnd();
      interval = Math.abs(moment(startEnd.start).diff(startEnd.end, 'days'));
      pixelPerDay = Math.round(paneWidth / interval);
      console.log(paneWidth, interval, pixelPerDay);
      lastElements = [-10000, -10000, -10000];
      elements = [];
      _ref = this.model.models;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        navElement = $(window.yat.templates.timelineNavigationElement({
          shorttitle: item.get('shorttitle'),
          linkHref: '#'
        }));
        days = moment(item.get('date')).diff(startEnd.start, 'days');
        position = days * pixelPerDay;
        line = 0;
        if (lastElements[line] >= position) {
          while (lastElements[line] >= position && line < 3) {
            line++;
          }
          if (line > 2) {
            line = 0;
            position = lastElements[line];
          }
        }
        lastElements[line] = position + 155;
        console.log(item.get('shorttitle'), line, position);
        navElement.css('top', line * 25 + 'px');
        navElement.css('left', position + 'px');
        overview.append(navElement);
      }
      return this.$el.html(overview);
    };

    return _Class;

  })(Backbone.View);

}).call(this);
