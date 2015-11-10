window.App = angular.module('Survey',
  ['ngResource', 'ngAnimate', 'ngSanitize', 'ngCookies', 'ui.sortable', 'ui.keypress', 'angular-loading-bar',
   'angularFileUpload', 'xeditable', 'angularUtils.directives.dirPagination', 'colorpicker.module', 'wysiwyg.module'
  ]).config(['$locationProvider', ($locationProvider) ->
    $locationProvider.html5Mode(true)
  ])