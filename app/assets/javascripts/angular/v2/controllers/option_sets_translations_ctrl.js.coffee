App.controller 'OptionSetTranslationsCtrl', ['$scope', '$state', '$stateParams',
'Setting', 'OptionSet', 'Option', 'OptionTranslation', 'OptionSetTranslation',
'OptionBackTranslation', ($scope, $state, $stateParams, Setting, OptionSet,
Option, OptionTranslation, OptionSetTranslation, OptionBackTranslation) ->

  $scope.optionSet = OptionSet.get({'id': $stateParams.id})
  $scope.language = $stateParams.language
  $scope.settings = Setting.get({}, ->
    $scope.settings.languages.splice(0, 1)
    $scope.languages = $scope.settings.languages
  )

  $scope.optionSetTranslations = OptionSetTranslation.query({
    'option_set_id': $stateParams.id
  }, ->
    angular.forEach $scope.optionSetTranslations, (ost, index) ->
      ost.checked = true
  )

  $scope.optionBackTranslations = OptionBackTranslation.query({
    'language': $stateParams.language,
    'option_set_id': $stateParams.id
  })

  if $stateParams.id && $stateParams.language
    $scope.options = Option.query({'option_set_id': $stateParams.id})
    $scope.optionTranslations = OptionTranslation.query({
      'language': $stateParams.language, 'option_set_id': $stateParams.id
    })

  $scope.updateLanguage = () ->
    $state.go('optionSetTranslations', {
      language: $scope.language,
      id: $stateParams.id
    })

  $scope.backTranslationFor = (optionSetTranslation) ->
    obt = _.findWhere($scope.optionBackTranslations, {backtranslatable_id: optionSetTranslation.option_translation_id})
    if obt == undefined
      obt = new OptionBackTranslation()
      obt.text = ""
    obt

  $scope.translationsFor = (option) ->
    osts = []
    ots = _.where($scope.optionTranslations, {option_id: option.id})
    angular.forEach ots, (ot, index) ->
      ost = _.findWhere($scope.optionSetTranslations, {option_translation_id: ot.id})
      if ost
        ost.text = ot.text
        ost.option_id = option.id
        osts.push(ost)
      else
        ost = new OptionSetTranslation()
        ost.option_set_id = $stateParams.id
        ost.option_translation_id = ot.id
        ost.text = ot.text
        ost.option_id = option.id
        osts.push(ost)
        $scope.optionSetTranslations.push(ost)
    osts

  $scope.newSelection = (optionSetTranslation) ->
    selected = _.where($scope.optionSetTranslations, {checked: true,
    option_id: optionSetTranslation.option_id})
    angular.forEach selected, (ost, index) ->
      if ost.option_translation_id != optionSetTranslation.option_translation_id
        ost.checked = false

  $scope.save = (osts) ->
    angular.forEach osts, (ost, index) ->
      if ost.checked
        if !ost.id
          ost.$save({},
            (data, headers) ->
              $state.reload()
            (result, headers) ->
              alert(result.data.errors)
          )
      else
        if ost.id
          ost.$delete({},
            (data, headers) ->
              $state.reload()
            (result, headers) ->
              alert(result.data.errors)
            )

]
