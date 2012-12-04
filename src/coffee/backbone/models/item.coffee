# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# The item is one "event" at a specific time on the timeline
window.yat.Item = class extends Backbone.Model
  defaults:
    category: ""
    content: ""
    date: ""
    important: false
    shorttitle: ""
    tags: []
