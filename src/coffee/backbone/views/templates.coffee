# yat.js
#
# Easy jQuery Timeline-Tool.
#
# Source: https://github.com/2robots/yat.js
# Authors: Benjamin Freundorfer, Franz Wilding
# Licence: GPL v3

window.yat = window.yat || {};

# The item is one "event" at a specific time on the timeline
window.yat.templates =
   timelineContainer: _.template('<div class="yat-timeline"><div class="yat-timeline-inner1"></div></div>')

   timelineViewportElementList: _.template('<div class="yat-inner"><ol class="yat-elements"></ol></div>')
   timelineViewportElement: _.template('<div class="yat-element-inner"><%= content %></div><span class="arrow"></span>')
   timelineViewportNavlinks: _.template('<div class="yat-navlinks"><span class="yat-left"><a href="javascript:void(0);">Nach links navigieren</a></span><span class="yat-right"><a href="javascript:void(0);">Nach rechts navigieren</a></span></div>')

   timelineOverview: _.template('<ol class="yat-years"></ol>')
   timelineOverviewYear: _.template('<li style="width: <%= width %>;"><span><%= year %></span></li>')
   timelineOverviewSelection: _.template('<div class="yat-current-position"><div class="yat-position-container"><div class="yat-position-inner">Aktueller Ausschnitt</div></div></div>')

   timelineNavigation: _.template('<div class="yat-navigation"></div>')
   timelineNavigationElementList: _.template('<ol class="yat-elements"></ol>')
   timelineNavigationElement: _.template('<li><a href="<%= linkHref %>"><%= shorttitle %></a></li>')