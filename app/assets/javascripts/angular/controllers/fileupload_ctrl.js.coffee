App.controller 'FileUploadCtrl', ['$scope', '$fileUploader', '$filter', 'Image', ($scope, $fileUploader, $filter, Image) ->
  $scope.questionImages = []
  $scope.initialize = (project_id, instrument_id, question_id) ->
    $scope.project_id = project_id
    $scope.instrument_id = instrument_id
    $scope.question_id = question_id 
        
    if $scope.question_id
      uploader = $scope.uploader = $fileUploader.create({
        scope: $scope,
        url: '/api/v1/frontend/projects/' + $scope.project_id + '/instruments/' + $scope.instrument_id + '/images/',
        headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content')},
        isHTML5: true,
        withCredentials: true,
        alias: 'photo',
        formData: [ { name: uploader, question_id: $scope.question_id } ]
      })
    
    if $scope.question_id
      uploader.filters.push (item) -> #{File|HTMLInputElement}
        type = (if uploader.isHTML5 then item.type else "/" + item.value.slice(item.value.lastIndexOf(".") + 1))
        type = "|" + type.toLowerCase().slice(type.lastIndexOf("/") + 1) + "|"
        "|jpg|png|jpeg|".indexOf(type) isnt -1

  $scope.$on('IMAGES-LOADED', (event, message) ->
    $scope.filterQuestionImages()
  )

  $scope.filterQuestionImages = ->
    $scope.questionImages = $filter('filter')($scope.$parent.$parent.images, question_id: $scope.question_id, true)

  $scope.deleteImage = (image) ->
    image.project_id = $scope.project_id
    image.instrument_id = $scope.instrument_id
    image.question_id = $scope.question_id
    image.$delete()
    $scope.$parent.$parent.images.splice($scope.$parent.$parent.images.indexOf(image), 1)
    $scope.filterQuestionImages()
    
  $scope.saveImageDetails = (image) ->
    image.project_id = $scope.project_id
    image.instrument_id = $scope.instrument_id
    image.question_id = $scope.question_id
    image.$update()
    
  $scope.sortableImages = {
    cursor: 'move',
    handle: '.move-image',
    axis: 'y',
    stop: (e, ui) -> 
      angular.forEach $scope.questionImages, (image, index) ->
        if image.id
          image.project_id = $scope.project_id
          image.instrument_id = $scope.instrument_id
          image.question_id = $scope.question_id
          image.number = index + 1  
          image.$update()
    }
  
]
