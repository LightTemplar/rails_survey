App.controller 'FileUploadCtrl', ['$scope', '$fileUploader', 'Image', ($scope, $fileUploader, Image) ->

  if $scope.question.id
    uploader = $scope.uploader = $fileUploader.create({
      scope: $scope,
      url: '/api/v1/frontend/projects/' + $scope.project_id + '/instruments/' + $scope.instrument_id + '/questions/' + $scope.question.id + '/images/',
      headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content') } ,
      isHTML5: true,
      withCredentials: true,
      alias: 'photo',
      formData: [ { name: uploader } ]
    } )

    uploader.filters.push (item) ->
      type = (if uploader.isHTML5 then item.type else '/' + item.value.slice(item.value.lastIndexOf('.') + 1))
      type = '|' + type.toLowerCase().slice(type.lastIndexOf('/') + 1) + '|'
      '|jpg|png|jpeg|'.indexOf(type) isnt - 1

  $scope.$watch 'question.images', ((newValue, oldValue, scope) ->
    if $scope.question.images.length > 0
      $scope.images = $scope.queryImages()
  ), true

  $scope.queryImages = () ->
    Image.query(
      {
        'project_id': $scope.project_id,
        'instrument_id': $scope.instrument_id,
        'question_id': $scope.question.id
      } , (result) ->
        uploader.queue = []
    )

  $scope.uploadStarted = () ->
    $scope.images = $scope.queryImages()

  $scope.deleteImage = (image) ->
    image.project_id = $scope.project_id
    image.instrument_id = $scope.instrument_id
    image.question_id = $scope.question.id
    image.$delete()
    $scope.images.splice($scope.images.indexOf(image), 1)

  $scope.saveImageDetails = (image) ->
    image.project_id = $scope.project_id
    image.instrument_id = $scope.instrument_id
    image.question_id = $scope.question.id
    image.$update()

  $scope.sortableImages = {
    cursor: 'move',
    handle: '.move-image',
    axis: 'y',
    stop: (e, ui) ->
      angular.forEach $scope.images, (image, index) ->
        if image.id
          image.project_id = $scope.project_id
          image.instrument_id = $scope.instrument_id
          image.question_id = $scope.question.id
          image.number = index + 1
          image.$update()
    }

]
