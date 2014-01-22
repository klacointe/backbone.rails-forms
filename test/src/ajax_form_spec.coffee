describe 'Backbone.RailsForms.AjaxForm', ->

  beforeEach ->
    @form = $ Fixtures.AjaxForm
    @view = new Backbone.RailsForms.AjaxForm el: @form

  afterEach ->
    @xhr.restore() if @xhr

  describe 'submitted', ->
    beforeEach ->
      @xhr = (new Response).with(
        url: @form.attr 'action'
        method: @form.attr 'method'
        content: JSON.stringify {"foo": "bar"}
        status: 200
      ).queue()

    it 'should trigger submit:start and submit:end', ->
      spy = sinon.spy()
      @view.on 'submit:start', spy
      @view.on 'submit:end', spy
      @view.submit()
      expect(spy).to.have.been.calledOnce
      @xhr.respond()
      expect(spy).to.have.been.calledTwice

    describe 'after submit:start event', ->

      beforeEach ->
        @view.trigger 'submit:start'

      it 'should show the spinner', ->
        expect(
          @view.$('input[type=submit]').siblings '.spinner'
        ).to.have.length 1

      it 'should disable inputs', ->
        expect(@view.$('input[type=submit]').attr 'disabled').to.equal 'disabled'

      describe 'and after submit:end event', ->
        beforeEach ->
          @view.trigger 'submit:end'

        it 'should hide the spinner', ->
          expect(
            @view.$('input[type=submit]').siblings '.spinner'
          ).to.have.length 0

        it 'should enable inputs', ->
          expect(@view.$('input[type=submit]').attr 'disabled').to.be.undefined

  describe 'submitted with errors', ->

    describe 'and server respond with an error object', ->

      beforeEach ->
        @xhr = (new Response).with(
          url: @form.attr 'action'
          method: @form.attr 'method'
          content: JSON.stringify {"errors": {"email": ["invalid", "bad"], "civility": ["invalid", "bad"]}}
          status: 422
        ).queue()
        @view.submit()

      it 'should trigger submit:error', ->
        spy = sinon.spy()
        @view.on 'submit:error', spy
        @xhr.respond()
        expect(spy).to.have.been.calledWith {"errors": {"email": ["invalid", "bad"], "civility": ["invalid", "bad"]}}

      it 'should display errors on inputs', ->
        @xhr.respond()
        input = @form.find("input[name=user\\[email\\]]").first()
        expect(
          input.siblings(".error.email").text()
        ).to.equal 'invalid,bad'

      it 'should display errors on selects', ->
        @xhr.respond()
        select = @form.find("select[name=user\\[civility\\]]").first()
        expect(
          select.siblings('.error.civility').text()
        ).to.equal 'invalid,bad'

    describe 'and server respond with an error string', ->

      beforeEach ->
        @xhr = (new Response).with(
          url: @form.attr 'action'
          method: @form.attr 'method'
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
        url: @form.attr 'action'
        method: @form.attr 'method'
        content: JSON.stringify {"foo": "bar"}
        status: 200
      ).queue()
      @view.submit()

    it 'should trigger submit:success', ->
      spy = sinon.spy()
      @view.on 'submit:success', spy
      @xhr.respond()
      expect(spy).to.have.been.calledWith {"foo": "bar"}
