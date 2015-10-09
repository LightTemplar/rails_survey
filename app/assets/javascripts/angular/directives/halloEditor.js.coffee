App.directive 'halloEditor', ->
  {
  restrict: 'A'
  require: '?ngModel'
  link: (scope, element, attrs, ngModel) ->
    if !ngModel
      return
    element.hallo plugins:
      halloformat: {
        bold: true
        italic: true
        strikethrough: true
        underline: true
      }
      halloheadings: {}
      hallojustify: {}
      hallolists: {}
      hallohtml: {}
      halloreundo: {}

    ngModel.$render = ->
      element.html ngModel.$viewValue or ''
      return

    element.on 'hallodeactivated', ->
      ngModel.$setViewValue element.html()
      scope.$apply()
      return
    return

  }