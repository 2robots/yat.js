// Generated by CoffeeScript 1.3.3
(function() {

  window.yat = window.yat || {};

  window.yat.App = (function() {

    function _Class(options) {
      this.dispatcher = _.extend({}, Backbone.Events);
      this.dispatcher.on('all', function() {});
      this.items = new window.yat.ItemList(options.items);
      this.timelineView = new window.yat.TimelineView({
        el: options.containerElement,
        model: this.items,
        dispatcher: this.dispatcher
      });
    }

    return _Class;

  })();

}).call(this);
