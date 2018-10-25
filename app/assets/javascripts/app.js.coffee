underscore = angular.module('underscore', [])
underscore.factory '_', ->
  window._

window.App = angular.module('Survey',
['ngResource', 'ngAnimate', 'ngSanitize', 'ngCookies', 'ngMessages', 'ui.router',
'ui.sortable', 'ui.keypress', 'ui.bootstrap', 'angular-loading-bar', 'ui.select',
'angularFileUpload', 'xeditable', 'angularUtils.directives.dirPagination',
'textAngular', 'checklist-model', 'angular.filter', 'underscore', 'templates', 'ngFileSaver'
]).factory 'HttpResponseInterceptor', ['$q', '$window', ($q, $window) ->
  {
    responseError: (rejection) ->
      if rejection.status == 401
        $window.location.href = '/users/sign_in'
      $q.reject rejection
  }
]
