window.App = angular.module('Survey',
  ['ngResource', 'ui.sortable', 'angular-loading-bar', 'ngAnimate', 'ngSanitize', 'ngCookies', 'ui.keypress',
   'angularFileUpload', 'xeditable', 'angularUtils.directives.dirPagination', 'colorpicker.module', 'wysiwyg.module'])
.config(['$locationProvider', ($locationProvider) ->
    $locationProvider.html5Mode(true)
  ])