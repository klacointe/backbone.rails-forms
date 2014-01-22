class Backbone.RailsForms.AjaxForm extends Backbone.View

  initialize: ->
    @on 'submit:start', @requestPending
    @on 'submit:end', @requestDone
    @$el.addClass 'ajaxForm'

  events:
    'submit': 'submit'

  submit: (e)=>
    @trigger 'submit:start'
    e?.preventDefault()
    @clearErrors()
    headers = {}
    headers["X-CSRF-Token"] = Backbone.RailsForms.csrfToken
    $.ajax(
      method:   @$el.attr 'method'
      url:      @$el.attr 'action'
      data:     @$el.serialize()
      dataType: 'json'
      headers:  headers
    )
    .then(@handleSuccess, @handleError)
    .always => @trigger 'submit:end'
    @

  handleSuccess: (resp)=>
    @trigger 'submit:success', resp
    @

  handleError: (xhr, status, error)=>
    resp = {}
    try
      resp = JSON.parse xhr.responseText
      errors = resp.error || resp.errors
    catch e
    if _.isString errors
      @globalError(errors)
    else unless _.isEmpty errors
      @errorOnInput attr, msg for attr, msg of errors
    @trigger 'submit:error', resp
    @

  errorOnInput: (attr, error)->
    input = @$("select[name$=\\[#{attr}\\]], input[name$=\\[#{attr}\\]]").first()
    input.parent('.control-group').addClass 'error'
    error = $ '<div>', class: "error msg #{attr}", text: error
    error.insertAfter input
    @

  globalError: (error)->
    error = $ '<div>', class: 'error msg', html: error
    @$el.prepend error
    @

  clearErrors: ->
    @$('.error.msg').remove()
    @$('.control-group.error').removeClass 'error'
    @

  requestPending: ->
    @toggleSpinner()
    @$el.addClass 'loading'
    @$('input[type=submit]').attr 'disabled', 'disabled'
    @

  requestDone: ->
    @toggleSpinner()
    @$el.removeClass 'loading'
    @$('input[type=submit]').removeAttr 'disabled'
    @

  toggleSpinner: ->
    unless @_spinner
      @_spinner = $ '<div>', class: 'spinner', text: 'Loading…'
    submit = @$('input[type=submit]')
    if submit.siblings('.spinner').length
      @_spinner.remove()
    else
      @_spinner.insertAfter submit
    @
