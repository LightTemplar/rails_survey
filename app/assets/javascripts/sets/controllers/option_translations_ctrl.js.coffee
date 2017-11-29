App.controller 'LanguageTranslationsCtrl', ['$scope', 'Setting',
($scope, Setting) ->
  $scope.settings = Setting.get({}, ->
    $scope.settings.languages.splice(0,1)
    $scope.languages = $scope.settings.languages
  )

]

App.controller 'ShowOptionTranslationsCtrl', ['$scope', '$routeParams', 'Setting',
'Options', 'OptionTranslation', ($scope, $routeParams, Setting, Options, OptionTranslation) ->
  $scope.language = $routeParams.language
  $scope.options = Options.query({})
  $scope.option_translations = OptionTranslation.query({'language': $scope.language})

  $scope.translation_for = (option) ->
    ot = _.findWhere($scope.option_translations, {option_id: option.id})
    if ot == undefined
      ot = new OptionTranslation()
      ot.language = $scope.language
      ot.option_id = option.id
      ot.text = ""
      $scope.option_translations.push(ot)
    ot

  $scope.save = () ->
    angular.forEach $scope.option_translations, (ot, index) ->
      if ot.id
        ot.$update({})
      else if ot.text != ""
        ot.$save({})

]
