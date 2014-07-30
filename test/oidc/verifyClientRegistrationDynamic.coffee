chai      = require 'chai'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
expect    = chai.expect




chai.use sinonChai
chai.should()




server          = require '../../server'
AccessToken     = require '../../models/AccessToken'
AccessJWT       = AccessToken.AccessJWT
verifyClientReg = require('../../lib/oidc').verifyClientRegistration
  settings:
    client_registration:        'dynamic'
    trusted_registration_scope: 'realm'




describe 'Verify Dynamic Client Registration', ->


  {req,res,next,err} = {}


  describe 'without bearer token', ->

    before (done) ->
      req = { headers: {}, body: {} }
      res = {}
      next = sinon.spy (error) ->
        err = error
        done()

      verifyClientReg req, res, next

    it 'should not provide an error', ->
      expect(err).to.be.undefined

    it 'should continue', ->
      next.should.have.been.called




  describe 'with invalid JWT bearer token', ->

    before (done) ->
      req =
        bearer: 'invalid.jwt'
        body: {}

      res = {}

      verifyClientReg req, res, (error) ->
        err = error
        done()

    it 'should provide an UnauthorizedError', ->
      err.name.should.equal 'UnauthorizedError'

    it 'should provide a realm', ->
      err.realm.should.equal 'user'

    it 'should provide an error code', ->
      err.error.should.equal 'invalid_token'

    it 'should provide an error description', ->
      err.error_description.should.equal 'Invalid access token'

    it 'should provide a status code', ->
      err.statusCode.should.equal 401




  describe 'with insufficient trusted scope', ->

    before (done) ->
      token =
        scope: 'insufficient'

      sinon.stub(AccessToken, 'verify').callsArgWith(2, null, token)
      req =
        bearer: 'valid.jwt'
        body: { trusted: "true" }

      res = {}

      verifyClientReg req, res, (error) ->
        err = error
        done()

    after ->
      AccessToken.verify.restore()

    it 'should provide an UnauthorizedError', ->
      err.name.should.equal 'UnauthorizedError'

    it 'should provide a realm', ->
      err.realm.should.equal 'user'

    it 'should provide an error code', ->
      err.error.should.equal 'insufficient_scope'

    it 'should provide an error description', ->
      err.error_description.should.equal 'User does not have permission'

    it 'should provide a status code', ->
      err.statusCode.should.equal 403




  describe 'with sufficient trusted scope', ->

    before (done) ->
      token =
        scope: 'realm other'

      sinon.stub(AccessToken, 'verify').callsArgWith(2, null, token)
      req =
        bearer: 'valid.jwt'
        body: { trusted: "true" }

      res = {}
      next = sinon.spy (error) ->
        err = error
        done()

      verifyClientReg req, res, next

    after ->
      AccessToken.verify.restore()

    it 'should not provide an error', ->
      expect(err).to.be.undefined

    it 'should continue', ->
      next.should.have.been.called




  describe 'with valid token', ->

    before (done) ->

      sinon.stub(AccessToken, 'verify').callsArgWith(2, null, {
        scope: 'realm'
      })

      req =
        bearer: 'valid.jwt'
        body: {}

      res = {}
      next = sinon.spy (error) ->
        err = error
        done()

      verifyClientReg req, res, next

    after ->
      AccessToken.verify.restore()

    it 'should not provide an error', ->
      expect(err).to.be.undefined

    it 'should continue', ->
      next.should.have.been.called




