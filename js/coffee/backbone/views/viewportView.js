// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.yat = window.yat || {};

  window.yat.ViewportView = (function(_super) {
    var disable_load_more_till_scrollend, rendered_count;

    __extends(_Class, _super);

    function _Class() {
      return _Class.__super__.constructor.apply(this, arguments);
    }

    _Class.prototype.className = 'yat-viewport';

    _Class.prototype.total_index = 0;

    _Class.prototype.current_scroll_position = 0;

    _Class.prototype.options = {
      animation_duration: 200,
      initial_element_count: 4,
      id_prefix: ''
    };

    disable_load_more_till_scrollend = false;

    _Class.prototype.not_rendered_yet = {};

    _Class.prototype.not_rendered_yet_position = 0;

    _Class.prototype.not_rendered_yet_current_element = void 0;

    rendered_count = 0;

    _Class.prototype.initialize = function() {
      return this.render();
    };

    _Class.prototype.remove = function() {
      return Backbone.View.prototype.remove.call(this);
    };

    _Class.prototype.render = function() {
      var navlinks, that, viewport;
      that = this;
      that.options.dispatcher.trigger('load_component_start');
      viewport = $(window.yat.templates.timelineViewportElementList());
      navlinks = $(window.yat.templates.timelineViewportNavlinks());
      this.$el.html(viewport);
      this.$el.append(navlinks);
      this.total_index = this.model.length;
      _(this.total_index).times(function(n) {
        return that.not_rendered_yet[n] = false;
      });
      setTimeout((function() {
        that.$el.find('ol.yat-elements').css('width', 0);
        return _.times(that.options.initial_element_count, (function() {
          that.insert_next_element();
          return that.options.dispatcher.trigger('load_component_end');
        }));
      }), 10);
      return this.registerEventListener();
    };

    _Class.prototype.registerEventListener = function() {
      var that;
      that = this;
      this.$el.find('> .yat-inner').bind('touchmove', function() {
        return that.options.dispatcher.trigger('viewport_position_change', direction);
      });
      this.$el.find('> .yat-inner').scroll(function() {
        var direction;
        direction = 'left';
        if (that.current_scroll_position < that.$el.find('> .yat-inner').scrollLeft()) {
          direction = 'right';
        }
        that.current_scroll_position = that.$el.find('> .yat-inner').scrollLeft();
        return that.options.dispatcher.trigger('viewport_position_change', direction);
      });
      this.$el.find('> .yat-inner').bind('scrollstart', function() {
        return that.options.dispatcher.trigger('viewport_scrollstart');
      });
      this.$el.find('> .yat-inner').bind('scrollstop', function() {
        return that.options.dispatcher.trigger('viewport_scrollstop', that.getCurrentElementModels());
      });
      this.$el.find('.yat-navlinks .yat-left a').click(function() {
        that.options.dispatcher.trigger('viewport_prev');
        return that.options.dispatcher.trigger('viewport_item_deselect');
      });
      this.$el.find('.yat-navlinks .yat-right a').click(function() {
        that.options.dispatcher.trigger('viewport_next');
        return that.options.dispatcher.trigger('viewport_item_deselect');
      });
      that.options.dispatcher.on('viewport_jump_to', function() {
        return that.jump_to(arguments[0], arguments[1]);
      });
      that.options.dispatcher.on('viewport_prev', function() {
        var element;
        element = _.first(that.getCurrentElements()).prev();
        that.insert_prev_element(that.getCurrentElements().length + 2);
        that.disable_load_more_till_scrollend = true;
        return that.options.dispatcher.trigger('viewport_jump_to', element);
      });
      that.options.dispatcher.on('viewport_next', function() {
        var element;
        element = _.last(that.getCurrentElements()).next();
        that.insert_next_element(that.getCurrentElements().length + 2);
        that.disable_load_more_till_scrollend = true;
        return that.options.dispatcher.trigger('viewport_jump_to', element);
      });
      that.options.dispatcher.on('viewport_item_select', function() {
        return that.open_element(arguments[0]);
      });
      that.options.dispatcher.on('viewport_item_deselect', function() {
        return that.close_open_element(arguments[0]);
      });
      that.options.dispatcher.on('viewport_position_change', function() {
        return that.load_more(arguments[0]);
      });
      that.options.dispatcher.on('viewport_scrollstop', function() {
        return that.disable_load_more_till_scrollend = false;
      });
      return that.options.dispatcher.on('navigation_element_selected', function(navigationView) {
        var el, index, position;
        position = _.indexOf(that.model.models, navigationView.model);
        if (that.not_rendered_yet[position] === false) {
          if (that.not_rendered_yet_position > position) {
            index = that.find_prev_not_rendered_element();
            if (index <= that.total_index) {
              el = jQuery('#' + that.options.id_prefix + (that.model.at(index + 1)).cid);
            } else {
              el = void 0;
            }
            that.insert_element_at_position(position, el, void 0);
          } else {
            that.insert_element_at_position(position);
          }
          that.insert_prev_element(that.getCurrentElements().length + 2);
          that.insert_next_element(that.getCurrentElements().length + 2);
        }
        that.disable_load_more_till_scrollend = true;
        that.jump_to($('#' + that.options.id_prefix + navigationView.model.cid));
        this.not_rendered_yet_current_element = $('#' + that.options.id_prefix + navigationView.model.cid);
        return this.not_rendered_yet_position = position;
      });
    };

    _Class.prototype.getCurrentElements = function() {
      var alternative_elements, current_elements, scroll_l, scroll_r;
      scroll_l = this.$el.find('> .yat-inner').scrollLeft();
      scroll_r = scroll_l + this.$el.find('> .yat-inner').width();
      alternative_elements = [];
      current_elements = [];
      this.$el.find('ol.yat-elements').children().each(function() {
        var el_width;
        el_width = $(this).outerWidth() + parseInt($(this).css('margin-left'), 10) + parseInt($(this).css('margin-right'), 10);
        if ($(this).position().left >= scroll_l && ($(this).position().left + el_width) <= scroll_r) {
          current_elements.push($(this));
        }
        if ($(this).position().left >= scroll_l - el_width && ($(this).position().left + el_width) <= scroll_r + el_width) {
          alternative_elements.push($(this));
        }
        if ($(this).position().left > scroll_r) {
          return false;
        }
      });
      if (current_elements.length > 0) {
        return current_elements;
      } else {
        return alternative_elements;
      }
    };

    _Class.prototype.getCurrentElement = function() {
      var elements, index;
      elements = this.getCurrentElements();
      index = parseInt(elements.length / 2, 10);
      return elements[index];
    };

    _Class.prototype.getCurrentElementModels = function() {
      var elements, that;
      that = this;
      elements = [];
      _.each(this.getCurrentElements(), (function(element) {
        return elements.push({
          dom: element,
          model: that.model.get(element.attr('id').substr(that.options.id_prefix.length))
        });
      }));
      return elements;
    };

    _Class.prototype.find_next_not_rendered_element = function() {
      var index;
      index = this.not_rendered_yet_position;
      while (index < this.total_index) {
        if (this.not_rendered_yet[index] === false) {
          return index;
        }
        index++;
      }
      return this.total_index;
    };

    _Class.prototype.find_prev_not_rendered_element = function() {
      var index;
      index = this.not_rendered_yet_position;
      while (index >= 0) {
        if (this.not_rendered_yet[index] === false) {
          return index;
        }
        index--;
      }
      return 0;
    };

    _Class.prototype.insert_next_element = function(count) {
      var that;
      that = this;
      if (count === void 0) {
        count = 1;
      }
      return _(count).times(function() {
        var el, index;
        index = that.find_next_not_rendered_element();
        if (index > 0) {
          el = jQuery('#' + that.options.id_prefix + (that.model.at(index - 1)).cid);
        } else {
          el = void 0;
        }
        return that.insert_element_at_position(index, void 0, el);
      });
    };

    _Class.prototype.insert_prev_element = function(count) {
      var that;
      that = this;
      if (count === void 0) {
        count = 1;
      }
      return _(count).times(function() {
        var el, index;
        index = that.find_prev_not_rendered_element();
        if (index <= that.total_index) {
          el = jQuery('#' + that.options.id_prefix + (that.model.at(index + 1)).cid);
        } else {
          el = void 0;
        }
        return that.insert_element_at_position(index, el, void 0);
      });
    };

    _Class.prototype.insert_element_at_position = function(position, before, after) {
      var all, element, element_view, model, that;
      if (this.not_rendered_yet[position] === false) {
        that = this;
        model = this.model.at(position);
        element_view = new window.yat.viewportItemView({
          model: model
        });
        element = null;
        if (before !== void 0 && before[0] !== void 0) {
          before.before(element_view.$el);
          element = before.prev();
          this.change_list_width(this.element_width(element));
          this.$el.find('> .yat-inner').scrollLeft(this.$el.find('> .yat-inner').scrollLeft() + this.element_width(element));
        } else if (after !== void 0 && after[0] !== void 0) {
          after.after(element_view.$el);
          element = after.next();
          this.change_list_width(this.element_width(element));
        } else {
          all = this.$el.find('ol.yat-elements').append(element_view.$el);
          element = all.children().last();
          this.change_list_width(this.element_width(element));
        }
        element.attr('id', this.options.id_prefix + model.cid);
        element.click(function() {
          if ($(this).hasClass('overflow')) {
            if ($(this).hasClass('open')) {
              return that.options.dispatcher.trigger('viewport_item_deselect');
            } else {
              return that.options.dispatcher.trigger('viewport_item_select', $(this));
            }
          }
        });
        element.data('yat-position', position);
        this.not_rendered_yet[position] = true;
        this.not_rendered_yet_position = position;
        this.not_rendered_yet_current_element = element;
        return rendered_count++;
      }
    };

    _Class.prototype.load_more = function(direction) {
      if (rendered_count < this.total_index && !this.disable_load_more_till_scrollend) {
        if (direction === 'left') {
          this.insert_prev_element();
        } else {
          this.insert_next_element();
        }
        return true;
      }
      return false;
    };

    _Class.prototype.jump_to = function() {
      var cb, container_width, element_width;
      if (arguments[0][0] !== void 0) {
        container_width = this.$el.find('> .yat-inner').outerWidth();
        element_width = arguments[0].outerWidth() + parseInt(arguments[0].css("margin-left"), 10) + parseInt(arguments[0].css("margin-right"), 10);
        cb = arguments[2];
        if (arguments[1] !== void 0 && arguments[1] === false) {
          this.$el.find('> .yat-inner').scrollLeft(arguments[0].position().left - (container_width / 2 - element_width / 2));
        } else {
          this.$el.find('> .yat-inner').animate({
            scrollLeft: arguments[0].position().left - (container_width / 2 - element_width / 2)
          }, {
            duration: this.options.animation_duration,
            complete: function() {
              if (cb !== void 0) {
                return cb();
              }
            }
          });
        }
        this.not_rendered_yet_position = arguments[0].data("yat-position");
        return this.not_rendered_yet_current_element = arguments[0];
      }
    };

    _Class.prototype.open_element = function() {
      var element, new_element_width, old_element_width, that;
      that = this;
      this.close_open_element();
      element = arguments[0];
      old_element_width = this.element_width(element);
      element.addClass('open');
      new_element_width = this.element_width(element);
      this.change_list_width(new_element_width - old_element_width, true);
      this.disable_load_more_till_scrollend = true;
      return this.jump_to(element, true, (function() {
        return this.disable_load_more_till_scrollend = false;
      }));
    };

    _Class.prototype.close_open_element = function() {
      var element, new_element_width, old_element_width, that;
      that = this;
      if (this.$el.find('ol.yat-elements li.open').length > 0) {
        element = this.$el.find('ol.yat-elements li.open').first();
        old_element_width = this.element_width(element);
        this.$el.find('ol.yat-elements li.open').removeClass('open');
        new_element_width = this.element_width(element);
        return this.change_list_width(new_element_width - old_element_width, true);
      }
    };

    _Class.prototype.element_width = function(element) {
      return element.outerWidth() + parseInt(element.css('margin-left'), 10) + parseInt(element.css('margin-right'), 10);
    };

    _Class.prototype.change_list_width = function(width) {
      width = parseInt(this.$el.find('ol.yat-elements').css('width'), 10) + width;
      return this.$el.find('ol.yat-elements').css('width', width);
    };

    return _Class;

  })(Backbone.View);

}).call(this);
