underscore = angular.module('underscore', [])
underscore.factory '_', ->
  window._

window.App = angular.module('Survey',
  ['ngResource', 'ngAnimate', 'ngSanitize', 'ngCookies', 'ngMessages', 'ui.router',
  'ui.sortable', 'ui.keypress', 'ui.bootstrap', 'angular-loading-bar', 'ui.select',
  'angularFileUpload', 'xeditable', 'angularUtils.directives.dirPagination',
  'textAngular', 'checklist-model', 'angular.filter', 'underscore', 'templates'
  ]).factory 'HttpResponseInterceptor', ['$q', '$window', ($q, $window) ->
    {
      responseError: (rejection) ->
        if rejection.status == 401
          $window.location.href = '/users/sign_in'
        $q.reject rejection
    }
]

App.filter 'propertyFilter', ->
  (items, properties) ->
    output = []
    if angular.isArray(items)
      keys = Object.keys(properties)
      items.forEach (item) ->
        itemMatches = false
        i = 0
        while i < keys.length
          property = keys[i]
          text = properties[property].toLowerCase()
          if item[property].toString().toLowerCase().indexOf(text) != -1
            itemMatches = true
            break
          i++
        if itemMatches
          output.push item
        return
    else
      output = items
    output
