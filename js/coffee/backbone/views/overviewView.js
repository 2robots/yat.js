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

    _Class.prototype.initialize = function() {
      this.resize();
      return this.render();
    };

    _Class.prototype.remove = function() {
      return Backbone.View.prototype.remove.call(this);
    };

    _Class.prototype.resize = function() {
      return console.log('resized');
    };

    _Class.prototype.render = function() {
      var itemWidth, overview, y, years, _i, _j, _len, _ref, _ref1, _results;
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
      overview.append(window.yat.templates.timelineOverviewSelection());
      return this.$el.html(overview);
    };

    return _Class;

  })(Backbone.View);

}).call(this);
