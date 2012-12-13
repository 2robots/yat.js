// Generated by CoffeeScript 1.3.3
(function() {

  window.yat = window.yat || {};

  window.yat.templates = {
    timelineContainer: _.template('<div class="yat-timeline"><div class="yat-timeline-inner1"></div></div>'),
    timelineViewport: _.template('<div class="yat-viewport"></div>'),
    timelineViewportElementList: _.template('<ol class="yat-elements"></div>'),
    timelineViewportElement: _.template('<div class="yat-element-inner"><%= content %></div><span class="arrow"></span>'),
    timelineNavigation: _.template('<div class="yat-navigation"></div>'),
    timelineOverview: _.template('<ol class="yat-years"></ol>'),
    timelineOverviewYear: _.template('<li style="width: <%= width %>;"><span><%= year %></span></li>'),
    timelineOverviewSelection: _.template('<div class="yat-current-position">Aktueller Ausschnitt</div>'),
    timelineNavigationElementList: _.template('<ol class="yat-elements"></ol>'),
    timelineNavigationElement: _.template('<li><a href="<%= linkHref %>"><%= shorttitle %></a></li>')
  };

}).call(this);
