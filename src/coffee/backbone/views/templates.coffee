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
   item: _.template('<h1><%= shorttitle %></h1><p><%= content %></p>')
   timelineOverview: _.template('<div class="yat-timeline-overview">
   <ol class="yat-years"></ol>
   <div class="yat-current-position">Aktueller Ausschnitt</div>
   </div>
   <!-- .yat-timeline-overview ends here -->')
   timelineOverviewYear: _.template('<li><span><%= year %></span></li>')