window.App = angular.module('Survey',
  ['ngResource', 'ui.sortable', 'localytics.directives', 'chieffancypants.loadingBar', 'ngAnimate', 'ngSanitize',
   'angularFileUpload', 'ngCookies', 'ui.keypress', 'xeditable', 'summernote', 'bgf.paginateAnything'])
.config(['$locationProvider', ($locationProvider) ->
    $locationProvider.html5Mode(true)
  ])