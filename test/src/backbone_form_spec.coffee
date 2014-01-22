class MyModel extends Backbone.Model
  url: ->
    '/foo/bar'

@Factory ?= {}

Factory.MyModel = {}
Factory.MyModel['base'] = ->
  new MyModel
    civility: 'Mr'
    first_name: 'Bat'
    last_name: 'Man'
    company: 'World Company'
    line_1: '42 foo street'
    line_2: 'Line 2…'
    zip_code: '12345'
    city: 'Mexico'
    phone_number: '0183838383'
    email: 'batman@example.com'
    main_address: false
    country_id: '1'


describe 'App.View.BackboneForm', ->

  beforeEach ->
    @form = $ Fixtures.BackboneForm
    @model = Factory.MyModel['base']()
    @view = new Backbone.RailsForms.BackboneForm
      el: @form
      model: @model

  afterEach ->
    @xhr.restore() if @xhr

  it 'should be defined', ->
    expect(Backbone.RailsForms.BackboneForm).to.be.a 'Function'

  describe 'submitted', ->
    beforeEach ->
      @xhr = (new Response).with(
        url: @model.url()
        content: JSON.stringify @model.toJSON()
        method: 'POST'
        status: 201
      ).queue()

    it 'should trigger submit:start and submit:end', ->
      spy = sinon.spy()
      @view.on 'submit:start', spy
      @view.on 'submit:end', spy
      @view.submit()
      expect(spy).to.have.been.calledOnce
      @xhr.respond()
      expect(spy).to.have.been.calledTwice

    it 'should set attribute on model from inputs, selects and checkboxes', ->
      @view.$('input[name=first_name]').val 'foo'
      @view.$('select[name=country_id] option[value=2]').attr 'selected', 'selected'
      @view.$('input[type=checkbox][name=main_address]').attr 'checked', 'checked'
      @view.submit()
      expect(@view.model.get 'first_name').to.equal 'foo'
      expect(@view.model.get 'country_id').to.equal '2'
      expect(@view.model.get 'main_address').to.equal 'true'

  describe 'submitted with errors', ->

    describe 'and server respond with an error object', ->

      beforeEach ->
        @xhr = (new Response).with(
          url: @model.url()
          content: JSON.stringify {"errors": {"first_name": ["invalid", "bad"], "country_id": ["invalid", "bad"]}}
          method: 'POST'
          status: 422
        ).queue()
        @view.submit()

      it 'should trigger submit:error', ->
        spy = sinon.spy()
        @view.on 'submit:error', spy
        @xhr.respond()
        expect(spy).to.have.been.calledWith {"errors": {"first_name": ["invalid", "bad"], "country_id": ["invalid", "bad"]}}

      it 'should display errors on inputs', ->
        @xhr.respond()
        input = @form.find("input[name=first_name]").first()
        expect(
          input.siblings('.error.first_name').text()
        ).to.equal 'invalid,bad'

      it 'should display errors on selects', ->
        @xhr.respond()
        select = @form.find("select[name=country_id]").first()
        expect(
          select.siblings('.error.country_id').text()
        ).to.equal 'invalid,bad'

    describe 'and server respond with an error string', ->

      beforeEach ->
        @xhr = (new Response).with(
          url: @model.url()
          method: 'POST'
          content: JSON.stringify {"error": 'Foo bar'}
          status: 422
        ).queue()
        @view.submit()

      it 'should trigger submit:error', ->
        spy = sinon.spy()
        @view.on 'submit:error', spy
        @xhr.respond()
        expect(spy).to.have.been.calledWith {"error": 'Foo bar'}

      it 'should display error', ->
        @xhr.respond()
        expect(@form.find('.error').first().text()).to.equal 'Foo bar'


  describe 'submitted with success', ->
    beforeEach ->
      @xhr = (new Response).with(
        url: @model.url()
        content: JSON.stringify @model.toJSON()
        method: 'POST'
        status: 201
      ).queue()
      @view.submit()

    it 'should trigger submit:success', ->
      spy = sinon.spy()
      @view.on 'submit:success', spy
      @xhr.respond()
      expect(spy).to.have.been
