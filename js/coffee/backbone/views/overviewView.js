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
      animation_duration: 200,
      quarter_dateformat: 'D.M.'
    };

    _Class.prototype.selection_element = void 0;

    _Class.prototype.current_date = void 0;

    _Class.prototype.initialize = function() {
      this.scrollLeft = 0;
      return this.render();
    };

    _Class.prototype.render = function() {
      var overview, that;
      that = this;
      overview = $(window.yat.templates.timelineOverview());
      this.selection_element = $(window.yat.templates.timelineOverviewSelection());
      setTimeout((function() {
        var scroll_inner_width;
        scroll_inner_width = parseInt(that.selection_element.find('.yat-position-inner').width(), 10);
        that.selection_element.find('.yat-position-container').css('width', '100%');
        that.selection_element.find('.yat-position-container').css('padding-left', that.$el.width() - scroll_inner_width + 'px');
        that.selection_element.find('.yat-position-container').css('padding-right', 0);
        that.selection_element.find('.yat-position-container').css('left', '1px');
        return that.jump_to(moment(that.model.start));
      }), 10);
      that.selection_element.find('.yat-position-container').bind('resize', (function() {
        return that.jump_to(that.current_date);
      }));
      this.$el.html(overview);
      this.$el.append(this.selection_element);
      this.selection_element.parent().bind('mouseup', function(event) {
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
      this.$el.find('.yat-current-position').scroll(function() {
        var offset;
        offset = that.get_percentage_for_offset($(this).scrollLeft());
        if (that.scrollLeft !== $(this).scrollLeft()) {
          return that.options.dispatcher.trigger('overview_position_change', offset);
        }
      });
      this.options.dispatcher.on('navigation_position_change', function(percentage) {
        return that.jump_to_percentage(percentage, false);
      });
      return this.options.dispatcher.on('navigation_elements_positioned', function(years) {
        return that.render_quarters(overview, years);
      });
    };

    _Class.prototype.render_quarters = function(overview, years) {
      var last_year, that;
      that = this;
      last_year = _.last(years);
      last_year.width -= 0.002;
      return _.each(years, function(y) {
        var className, year_view;
        year_view = jQuery(window.yat.templates.timelineOverviewYear({
          year: y.start.year(),
          width: Math.round(10000 * y.width) / 100 + '%'
        }));
        if (moment([y.start.year(), 0]).isSame(y.start, 'day')) {
          className = 'first';
        } else {
          className = '';
        }
        year_view.append(window.yat.templates.timelineOverviewQuarter({
          offset: 100 * y.left,
          title: '',
          className: className
        }));
        _.each(y.quarters, function(q) {
          return year_view.append(window.yat.templates.timelineOverviewQuarter({
            offset: 100 * q.left,
            title: '',
            className: ''
          }));
        });
        overview.append(year_view);
        if (year_view.width() < 32) {
          return year_view.find('span:first').empty();
        }
      });
    };

    _Class.prototype.jump_to_percentage = function(percentage, animate) {
      var left, slider_width, width;
      left = this.get_offset_for_percentage(percentage);
      width = $('.yat-current-position').width();
      slider_width = $('.yat-position-inner').width();
      this.scrollLeft = Math.floor(width - left) - slider_width;
      if (animate) {
        return this.$el.find('.yat-current-position').animate({
          scrollLeft: this.scrollLeft
        }, this.options.animation_duration);
      } else {
        return this.$el.find('.yat-current-position').scrollLeft(this.scrollLeft);
      }
    };

    _Class.prototype.jump_to = function(date, animate) {
      var left, slider_width, width;
      left = this.get_offset_for_date(date);
      width = $('.yat-current-position').width();
      slider_width = $('.yat-position-inner').width();
      this.scrollLeft = Math.floor(width - left - slider_width / 2);
      if (animate) {
        this.$el.find('.yat-current-position').animate({
          scrollLeft: this.scrollLeft
        }, this.options.animation_duration);
      } else {
        this.$el.find('.yat-current-position').scrollLeft(this.scrollLeft);
      }
      return this.current_date = date;
    };

    _Class.prototype.get_percentage_for_offset = function(offset) {
      var slider_width, width;
      width = $('.yat-current-position').width();
      slider_width = $('.yat-position-inner').width();
      return 1 - (offset / (width - slider_width));
    };

    _Class.prototype.get_offset_for_percentage = function(percentage) {
      var slider_width, width;
      width = $('.yat-current-position').width();
      slider_width = $('.yat-position-inner').width();
      return percentage * (width - slider_width);
    };

    _Class.prototype.get_offset_for_date = function(date) {
      var end, start, width;
      date.startOf('day');
      width = $('.yat-current-position').width();
      start = moment(this.model.start);
      end = moment(this.model.end);
      return (date.diff(start) / end.diff(start)) * width;
    };

    _Class.prototype.get_date_for_offset = function(offset) {
      var end, percentage, start, width;
      width = $('.yat-current-position').width();
      percentage = offset / width;
      start = moment(this.model.start);
      end = moment(this.model.end);
      return moment(start).add(end.diff(start) * percentage).startOf('day');
    };

    return _Class;

  })(Backbone.View);

}).call(this);
