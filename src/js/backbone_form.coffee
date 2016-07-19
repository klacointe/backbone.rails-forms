class RailsForms.BackboneForm extends RailsForms.AjaxForm

  events:
    'submit': 'submit'

  submit: (e)=>
    @trigger 'submit:start'
    e.preventDefault() if e
    @clearErrors().syncModel()
    @model.save()
      .success(@handleSuccess)
      .error(@handleError)
      .always => @trigger 'submit:end'
    @

  handleSuccess: (resp, textStatus, xhr)=>
    @trigger 'submit:success', resp, textStatus, xhr
    @

  errorOnInput: (attr, error)->
    input = @$("select[name=#{attr}], input[name=#{attr}]").first()
    parent = input.parent('.control-group')
    parent.addClass 'error'
    error = $ '<div>', class: "error msg #{attr}", text: error
    parent.append error
    @

  syncModel: ->
    for input in @$el.serializeArray()
      @model.set input.name, input.value
    @
