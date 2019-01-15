App.directive 'fileUpload', ['$parse', ($parse) ->
  {
    restrict: 'A'
    link: (scope, element, attrs) ->
      model = $parse(attrs.fileUpload)
      modelSetter = model.assign
      element.bind 'change', ->
        scope.$apply ->
          modelSetter scope, element[0].files[0]
  }
]
