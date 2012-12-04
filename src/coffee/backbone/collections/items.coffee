# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# Collection to hold all items for one single timeline
class window.yat.ItemList extends Backbone.Collection
  model: yat.Item