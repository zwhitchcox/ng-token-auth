suite 'email registration submission', ->
  dfd = null

  suite 'successful submission', ->
    setup ->
      $httpBackend
        .expectPOST('/api/auth')
        .respond(201, {success: true})

    suite 'service module', ->
      setup ->
        dfd = $auth.submitRegistration({
          email: validEmail
          password: 'secret123'
          password_confirmation: 'secret123'
        })

        $httpBackend.flush()

      test '$rootScope should broadcast success event', ->
        assert $rootScope.$broadcast.calledWithMatch('auth:registration-email-success')

      test 'promise is resolved', ->
        dfd.then(-> assert(true))
        $timeout.flush()

    suite 'directive access', ->
      args =
        email: validEmail
        password: 'secret123'
        password_confirmation: 'secret123'

      setup ->
        sinon.spy $auth, 'submitRegistration'

        $rootScope.submitRegistration(args)

        $httpBackend.flush()

      test '$auth.submitRegistration should have been called', ->
        assert $auth.submitRegistration.calledWithMatch(args)


  suite 'failed submission', ->
    suite 'mismatched password', ->
      errorResp =
        success: false
        errors: ['balls']
        fieldErrors: {
          password_confirmation: ['padword midmadch']
        }

      setup ->
        $httpBackend
          .expectPOST('/api/auth')
          .respond(422, errorResp)

        dfd = $auth.submitRegistration({
          email: validEmail
          password: 'secret123'
          password_confirmation: 'bogus'
        })

        $httpBackend.flush()

      test '$rootScope should broadcast failure event', ->
        assert $rootScope.$broadcast.calledWithMatch('auth:registration-email-error', errorResp)

      test 'promise is rejected', ->
        dfd.catch(-> assert(true))
        $timeout.flush()


    suite 'existing user', ->
      errorResp =
        success: false
        errors: ['balls']
        fieldErrors: {
          email: ['user exists']
        }

      setup ->
        $httpBackend
          .expectPOST('/api/auth')
          .respond(422, errorResp)

        dfd = $auth.submitRegistration({
          email: validEmail
          password: 'secret123'
          password_confirmation: 'bogus'
        })
        $httpBackend.flush()

      test '$rootScope should broadcast failure event', ->
        assert $rootScope.$broadcast.calledWithMatch('auth:registration-email-error', errorResp)

      test 'promise is rejected', ->
        dfd.catch(-> assert(true))
        $timeout.flush()
