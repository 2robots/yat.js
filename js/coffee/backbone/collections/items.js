// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.yat = window.yat || {};

  window.yat.ItemList = (function(_super) {

    __extends(ItemList, _super);

    function ItemList() {
      return ItemList.__super__.constructor.apply(this, arguments);
    }

    ItemList.prototype.model = yat.Item;

    return ItemList;

  })(Backbone.Collection);

}).call(this);
