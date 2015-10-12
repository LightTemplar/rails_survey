window.App = angular.module('Survey',
  ['ngResource', 'ui.sortable', 'localytics.directives', 'chieffancypants.loadingBar', 'ngAnimate', 'ngSanitize',
   'angularFileUpload', 'ngCookies', 'ui.keypress', 'xeditable', 'angularUtils.directives.dirPagination', 'wysiwyg.module'])
.config(['$locationProvider', ($locationProvider) ->
    $locationProvider.html5Mode(true)
  ])