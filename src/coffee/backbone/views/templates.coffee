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
   timelineViewport: _.template('<div class="yat-viewport"></div>')
   timelineViewportElementList: _.template('<ol class="yat-elements"></div>')
   timelineViewportElement: _.template('<div class="yat-element-inner"><%= content %></div><span class="arrow"></span>')
   timelineNavigation: _.template('<div class="yat-navigation"></div>')
   timelineOverview: _.template('<ol class="yat-years"></ol>')
   timelineOverviewYear: _.template('<li style="width: <%= width %>;"><span><%= year %></span></li>')
   timelineOverviewSelection: _.template('<div class="yat-current-position">Aktueller Ausschnitt</div>')
   timelineNavigationElementList: _.template('<ol class="yat-elements"></ol>')
   timelineNavigationElement: _.template('<li><a href="<%= linkHref %>"><%= shorttitle %></a></li>')