(function() {
  var $, Backbone, RailsForms, _, _ref, _ref1,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  RailsForms = {};

  _ = (typeof require === "function" ? require("underscore") : void 0) || window._;

  $ = (typeof require === "function" ? require("jquery") : void 0) || window.$;

  Backbone = (typeof require === "function" ? require("backbone") : void 0) || window.Backbone;

  if (typeof module !== "undefined" && module !== null) {
    module.exports = RailsForms;
  } else {
    Backbone.RailsForms = RailsForms;
  }

  RailsForms.csrfToken = $("meta[name='csrf-token']").attr('content');

  Backbone.sync = (function(original) {
    return function(method, model, options) {
      options.beforeSend = function(xhr) {
        return xhr.setRequestHeader("X-CSRF-Token", RailsForms.csrfToken);
      };
      return original(method, model, options);
    };
  })(Backbone.sync);

  RailsForms.AjaxForm = (function(_super) {
    __extends(AjaxForm, _super);

    function AjaxForm() {
      this.handleError = __bind(this.handleError, this);
      this.handleSuccess = __bind(this.handleSuccess, this);
      this.submit = __bind(this.submit, this);
      _ref = AjaxForm.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    AjaxForm.prototype.initialize = function() {
      this.on('submit:start', this.requestPending);
      this.on('submit:end', this.requestDone);
      return this.$el.addClass('ajaxForm');
    };

    AjaxForm.prototype.events = {
      'submit': 'submit'
    };

    AjaxForm.prototype.submit = function(e) {
      var headers,
        _this = this;
      this.trigger('submit:start');
      if (e != null) {
        e.preventDefault();
      }
      this.clearErrors();
      headers = {};
      headers["X-CSRF-Token"] = RailsForms.csrfToken;
      $.ajax({
        method: this.$el.attr('method'),
        url: this.$el.attr('action'),
        data: this.$el.serialize(),
        dataType: 'json',
        headers: headers
      }).then(this.handleSuccess, this.handleError).always(function() {
        return _this.trigger('submit:end');
      });
      return this;
    };

    AjaxForm.prototype.handleSuccess = function(resp, textStatus, xhr) {
      this.trigger('submit:success', resp, textStatus, xhr);
      return this;
    };

    AjaxForm.prototype.handleError = function(xhr, status, error) {
      var attr, e, errors, msg, resp;
      resp = {};
      try {
        resp = JSON.parse(xhr.responseText);
        errors = resp.error || resp.errors;
      } catch (_error) {
        e = _error;
      }
      if (_.isString(errors)) {
        this.globalError(errors);
      } else if (!_.isEmpty(errors)) {
        for (attr in errors) {
          msg = errors[attr];
          this.errorOnInput(attr, msg);
        }
      }
      this.trigger('submit:error', resp);
      return this;
    };

    AjaxForm.prototype.errorOnInput = function(attr, error) {
      var input, parent;
      input = this.$("select[name$=\\[" + attr + "\\]], input[name$=\\[" + attr + "\\]]").first();
      parent = input.parent('.control-group');
      parent.addClass('error');
      error = $('<div>', {
        "class": "error msg " + attr,
        text: error
      });
      parent.append(error);
      return this;
    };

    AjaxForm.prototype.globalError = function(error) {
      error = $('<div>', {
        "class": 'error msg',
        html: error
      });
      this.$el.prepend(error);
      return this;
    };

    AjaxForm.prototype.clearErrors = function() {
      this.$('.error.msg').remove();
      this.$('.control-group.error').removeClass('error');
      return this;
    };

    AjaxForm.prototype.requestPending = function() {
      this.toggleSpinner();
      this.$el.addClass('loading');
      this.$('input[type=submit]').attr('disabled', 'disabled');
      return this;
    };

    AjaxForm.prototype.requestDone = function() {
      this.toggleSpinner();
      this.$el.removeClass('loading');
      this.$('input[type=submit]').removeAttr('disabled');
      return this;
    };

    AjaxForm.prototype.toggleSpinner = function() {
      var submit;
      if (!this._spinner) {
        this._spinner = $('<div>', {
          "class": 'spinner',
          text: 'Loading…'
        });
      }
      submit = this.$('input[type=submit]');
      if (submit.siblings('.spinner').length) {
        this._spinner.remove();
      } else {
        this._spinner.insertAfter(submit);
      }
      return this;
    };

    return AjaxForm;

  })(Backbone.View);

  RailsForms.BackboneForm = (function(_super) {
    __extends(BackboneForm, _super);

    function BackboneForm() {
      this.handleSuccess = __bind(this.handleSuccess, this);
      this.submit = __bind(this.submit, this);
      _ref1 = BackboneForm.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    BackboneForm.prototype.events = {
      'submit': 'submit'
    };

    BackboneForm.prototype.submit = function(e) {
      var _this = this;
      this.trigger('submit:start');
      if (e) {
        e.preventDefault();
      }
      this.clearErrors().syncModel();
      this.model.save().success(this.handleSuccess).error(this.handleError).always(function() {
        return _this.trigger('submit:end');
      });
      return this;
    };

    BackboneForm.prototype.handleSuccess = function(resp, textStatus, xhr) {
      this.trigger('submit:success', resp, textStatus, xhr);
      return this;
    };

    BackboneForm.prototype.errorOnInput = function(attr, error) {
      var input;
      input = this.$("select[name=" + attr + "], input[name=" + attr + "]").first();
      input.parent('.control-group').addClass('error');
      error = $('<div>', {
        "class": "error msg " + attr,
        text: error
      });
      error.insertAfter(input);
      return this;
    };

    BackboneForm.prototype.syncModel = function() {
      var input, _i, _len, _ref2;
      _ref2 = this.$el.serializeArray();
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        input = _ref2[_i];
        this.model.set(input.name, input.value);
      }
      return this;
    };

    return BackboneForm;

  })(RailsForms.AjaxForm);

}).call(this);
