// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.yat = window.yat || {};

  window.yat.OverviewView = (function(_super) {

    __extends(_Class, _super);

    function _Class() {
      return _Class.__super__.constructor.apply(this, arguments);
    }

    _Class.prototype.className = 'yat-timeline-overview';

    _Class.prototype.options = {
      animation_duration: 200
    };

    _Class.prototype.initialize = function() {
      return this.render();
    };

    _Class.prototype.remove = function() {
      return Backbone.View.prototype.remove.call(this);
    };

    _Class.prototype.render = function() {
      var itemWidth, overview, selection, that, y, years, _i, _j, _len, _ref, _ref1, _results;
      that = this;
      overview = $(window.yat.templates.timelineOverview());
      years = (function() {
        _results = [];
        for (var _i = _ref = this.model.start.getFullYear(), _ref1 = this.model.end.getFullYear(); _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; _ref <= _ref1 ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this);
      itemWidth = Math.round(10000 / years.length, 2) / 100;
      for (_j = 0, _len = years.length; _j < _len; _j++) {
        y = years[_j];
        overview.append(window.yat.templates.timelineOverviewYear({
          year: y,
          width: itemWidth + '%'
        }));
      }
      selection = $(window.yat.templates.timelineOverviewSelection());
      setTimeout((function() {
        var inner_width, main_width;
        main_width = parseInt(selection.css('width'), 10);
        inner_width = parseInt(selection.find('.yat-position-inner').css('width'), 10);
        selection.find('.yat-position-container').css('width', main_width);
        selection.find('.yat-position-container').css('padding-left', main_width - inner_width);
        return that.jump_to(moment(that.model.start));
      }), 10);
      this.$el.html(overview);
      this.$el.append(selection);
      selection.parent().click(function(event) {
        return that.options.dispatcher.trigger('overview_jump_to', that.get_date_for_offset(event.pageX - $('.yat-current-position').offset().left));
      });
      that.options.dispatcher.on('overview_jump_to', function() {
        var animate;
        animate = true;
        if (arguments.length > 1) {
          animate = arguments[1];
        }
        return that.jump_to(arguments[0], animate);
      });
      this.$el.find('.yat-current-position').bind('scrollstop', function() {
        var element_width, pos_left;
        pos_left = $('.yat-position-inner').offset().left;
        element_width = $('.yat-position-inner').width();
        return that.options.dispatcher.trigger('overview_position_change', that.get_date_for_offset(pos_left - $('.yat-current-position').offset().left));
      });
      return this.options.dispatcher.on('viewport_scrollstop', function() {
        return that.jump_to(moment(arguments[0][0].model.get("date")), true);
      });
    };

    _Class.prototype.jump_to = function(date, animate) {
      var element_width, left, width;
      left = this.get_offset_for_date(date);
      width = $('.yat-current-position').width();
      element_width = $('.yat-position-inner').width();
      if (animate) {
        return this.$el.find('.yat-current-position').animate({
          scrollLeft: width - left - (element_width / 2)
        }, this.options.animation_duration);
      } else {
        return this.$el.find('.yat-current-position').scrollLeft(width - left - (element_width / 2));
      }
    };

    _Class.prototype.get_offset_for_date = function(date) {
      var end, start, width;
      width = $('.yat-current-position').width();
      start = moment(this.model.start);
      end = moment(this.model.end);
      return (date.diff(start) / end.diff(start)) * width;
    };

    _Class.prototype.get_date_for_offset = function(offset) {
      var end, start, width;
      width = $('.yat-current-position').width();
      start = moment(this.model.start);
      end = moment(this.model.end);
      return moment(start).add(end.diff(start) * (offset / width));
    };

    return _Class;

  })(Backbone.View);

}).call(this);
