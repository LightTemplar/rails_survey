window.App = angular.module('Survey',
  ['ngResource', 'ngAnimate', 'ngSanitize', 'ngCookies', 'ngMessages', 'ui.sortable', 'ui.keypress', 'ui.bootstrap',
    'angular-loading-bar', 'angularFileUpload', 'xeditable', 'angularUtils.directives.dirPagination', 'textAngular',
    'checklist-model', 'angular.filter'
  ]).config(['$locationProvider', ($locationProvider) ->
    $locationProvider.html5Mode(true)
  ])