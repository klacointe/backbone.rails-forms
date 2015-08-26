# Rails app has a CSRF protection
# Make backbone sync aware of it

RailsForms.csrfToken = $("meta[name='csrf-token']").attr('content')

Backbone.sync = ((original) ->
  (method, model, options) ->
    options.beforeSend = (xhr) ->
      xhr.setRequestHeader "X-CSRF-Token", RailsForms.csrfToken
    original method, model, options
)(Backbone.sync)
