// Generated by CoffeeScript 1.3.3
(function() {

  window.yat = window.yat || {};

  window.yat.NavigationViewManager = (function() {

    function _Class(model, options) {
      this.model = model;
      this.options = options;
      this.initialize();
      this.index = 0;
    }

    _Class.prototype.initialize = function() {
      this.paneWidth = this.options.element_width * (this.model.length / 1.0) + this.options.margin_left + this.options.margin_right;
      this.startEnd = this.model.getStartEnd();
      this.interval = Math.abs(moment(this.startEnd.start).diff(this.startEnd.end, 'days'));
      return this.pixelPerDay = Math.round(this.paneWidth / this.interval);
    };

    _Class.prototype.hasRenderCandidate = function() {
      return this.index < this.model.models.length;
    };

    _Class.prototype.getNextElement = function() {
      var days, item;
      item = this.model.at(this.index++);
      days = moment(item.get('date')).diff(this.startEnd.start, 'days');
      return {
        position: days * this.pixelPerDay + this.options.margin_left,
        model: item
      };
    };

    _Class.prototype.updateViewport = function(viewportPos) {
      this.viewportPos = viewportPos;
    };

    _Class.prototype.get_date_for_offset = function(offset) {
      var days, daysTotal, end, start, widthInDays;
      start = moment(this.startEnd.start).clone();
      end = moment(this.startEnd.end).clone();
      daysTotal = end.diff(start, 'days');
      days = offset / this.pixelPerDay;
      widthInDays = Math.round(this.viewportPos.width / this.pixelPerDay);
      days += (days / (daysTotal - widthInDays)) * widthInDays;
      return start.add('days', days);
    };

    _Class.prototype.get_offset_for_date = function(date) {
      var d, daysTotal, end, r, start, widthInDays;
      start = moment(this.startEnd.start).clone();
      end = moment(this.startEnd.end).clone();
      daysTotal = end.diff(start, 'days');
      widthInDays = this.viewportPos.width / this.pixelPerDay;
      r = moment(date).clone().diff(this.startEnd.start, 'days');
      d = Math.round(r / (1 + (widthInDays / (daysTotal - widthInDays))));
      return d * this.pixelPerDay;
    };

    _Class.prototype.get_percentage_for_offset = function(offset) {
      var daysTotal, end, start;
      start = moment(this.startEnd.start).clone();
      end = moment(this.startEnd.end).clone();
      daysTotal = end.diff(start, 'days');
      return offset / (daysTotal * this.pixelPerDay);
    };

    _Class.prototype.get_offset_for_percentage = function(percentage) {
      var daysTotal, end, start;
      start = moment(this.startEnd.start).clone();
      end = moment(this.startEnd.end).clone();
      daysTotal = end.diff(start, 'days');
      return daysTotal * this.pixelPerDay * percentage;
    };

    return _Class;

  })();

}).call(this);
