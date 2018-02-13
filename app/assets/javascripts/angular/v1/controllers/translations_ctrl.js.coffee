App.controller 'TranslationsCtrl', ['$scope', '$filter', 'Grid', 'InstrumentTranslation', 'GridTranslation', 'GridLabelTranslation', ($scope, $filter, Grid, InstrumentTranslation, GridTranslation, GridLabelTranslation) ->
  $scope.showGridTranslations = false
  $scope.showQuestionTranslations = true
  $scope.gridTranslations = []
  $scope.gridLabelTranslations = []
  
  $scope.init = (project_id, instrument_id, id) ->
    $scope.project_id = project_id
    $scope.instrument_id = instrument_id
    $scope.instrument_translation_id = id
    $scope.grids = $scope.getGrids()
    
  $scope.getTranslations = () ->
    $scope.instrumentTranslation = InstrumentTranslation.get({
      'project_id': $scope.project_id
      'instrument_id': $scope.instrument_id
      'id': $scope.instrument_translation_id
    }, ->
      $scope.gridTranslations.push angular.copy(gridTranslation, new GridTranslation) for gridTranslation in $scope.instrumentTranslation.grid_translations
      $scope.addNewGridTranslations()
      $scope.gridLabelTranslations.push angular.copy(gridLabelTranslation, new GridLabelTranslation) for gridLabelTranslation in $scope.instrumentTranslation.grid_label_translations
      $scope.addNewGridLabelTranslations()
    )
  
  $scope.toggleViews = () ->
    $scope.showGridTranslations = !$scope.showGridTranslations
    $scope.showQuestionTranslations = !$scope.showQuestionTranslations
    
  $scope.getGrids = () ->
    Grid.query({
      'project_id': $scope.project_id
      'instrument_id': $scope.instrument_id
    }, -> $scope.getTranslations())
    
  $scope.addNewGridTranslations = () ->
    angular.forEach $scope.grids, (grid) ->
      translations = $filter('filter')($scope.gridTranslations, grid_id: grid.id, true)
      if typeof translations == 'undefined' || translations.length == 0
        translation = new GridTranslation
        translation.grid_id = grid.id 
        translation.instrument_translation_id = $scope.instrumentTranslation.id
        translation.name = ''
        translation.instructions = ''
        translation.grid_name = grid.name
        translation.grid_instructions = grid.instructions
        $scope.gridTranslations.push(translation)
  
  $scope.addNewGridLabelTranslations = () ->
    angular.forEach $scope.grids, (grid) ->
      angular.forEach grid.grid_labels, (grid_label) ->
        translations = $filter('filter')($scope.gridLabelTranslations, grid_label_id: grid_label.id, true)
        if typeof translations == 'undefined' || translations.length == 0
          translation = new GridLabelTranslation
          translation.grid_label_id = grid_label.id 
          translation.instrument_translation_id = $scope.instrumentTranslation.id
          translation.label = ''
          translation.grid_label_label = grid_label.label
          translation.grid_label_grid_id = grid_label.grid_id
          $scope.gridLabelTranslations.push(translation)
  
  $scope.saveGridTranslations = () ->
    angular.forEach $scope.gridTranslations, (gridTranslation) ->
      gridTranslation.project_id = $scope.project_id
      gridTranslation.instrument_id = $scope.instrument_id
      gridTranslation.instrument_translation_id = $scope.instrument_translation_id
      if gridTranslation.id 
        gridTranslation.$update({},
          (data, headers) ->,
          (result, headers) -> alert "Error updating grid translation"
        )
      else
        gridTranslation.$save({},
          (data, headers) ->,
          (result, headers) -> alert "Error saving grid translation"
        )
        
    angular.forEach $scope.gridLabelTranslations, (gridLabelTranslation) ->
      gridLabelTranslation.project_id = $scope.project_id
      gridLabelTranslation.instrument_id = $scope.instrument_id
      gridLabelTranslation.instrument_translation_id = $scope.instrument_translation_id
      if gridLabelTranslation.id 
        gridLabelTranslation.$update({},
          (data, headers) ->,
          (result, headers) -> alert "Error updating grid label translation"
        )
      else
        gridLabelTranslation.$save({},
          (data, headers) ->,
          (result, headers) -> alert "Error saving grid label translation"
        )
    
]