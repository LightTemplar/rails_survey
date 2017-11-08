underscore = angular.module('underscore', [])
underscore.factory '_', ->
  window._

window.App = angular.module('Survey',
  ['ngResource', 'ngAnimate', 'ngSanitize', 'ngCookies', 'ngMessages', 'ngRoute',
  'ui.sortable', 'ui.keypress', 'ui.bootstrap', 'angular-loading-bar',
  'angularFileUpload', 'xeditable', 'angularUtils.directives.dirPagination',
  'textAngular', 'checklist-model', 'angular.filter', 'underscore', 'templates'
  ]).config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    # TODO Why is locationProvider needed for routeProvider to work?
    $locationProvider.html5Mode
      enabled: true
      requireBase: false

    $routeProvider
      .when '/question_sets',
        templateUrl: 'question_sets/index.html'
        controller: 'QuestionSetsCtrl'
      .when '/question_sets/:id',
        templateUrl: 'question_sets/show.html'
        controller: 'ShowQuestionSetCtrl'
      .when '/question_sets/:question_set_id/questions/:id',
        templateUrl: 'questions/show.html'
        controller: 'ShowQuestionCtrl'
      .when '/question_sets/:question_set_id/questions/new',
        templateUrl: 'questions/show.html'
        controller: 'ShowQuestionCtrl'
      .when '/option_sets',
        templateUrl: 'option_sets/index.html'
        controller: 'OptionSetsCtrl'
      .when '/option_sets/:id',
        templateUrl: 'option_sets/show.html'
        controller: 'ShowOptionSetCtrl'
      .when '/instructions',
        templateUrl: 'instructions/index.html'
        controller: 'InstructionsCtrl'
      .when '/instructions/:id',
        templateUrl: 'instructions/show.html'
        controller: 'ShowInstructionCtrl'
      .when '/projects/:project_id/instruments/:instrument_id/instrument_question_sets',
        templateUrl: 'instrument_question_sets/index.html'
        controller: 'InstrumentQuestionSetsCtrl'
      .when '/projects/:project_id/instruments/:instrument_id/instrument_questions',
        templateUrl: 'instrument_questions/index.html'
        controller: 'InstrumentQuestionsCtrl'
      .when '/projects/:project_id/instruments/:instrument_id/instrument_questions/:id',
        templateUrl: 'instrument_questions/show.html'
        controller: 'ShowInstrumentQuestionCtrl'
  ])
