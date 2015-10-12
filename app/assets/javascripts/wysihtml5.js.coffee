$(document).ready ->
  $('.wysihtml5').each (i, elem) ->
    $(elem).wysihtml5(
      toolbar:
        'font-styles': true
        'emphasis': true
        'lists': true
        'html': true
        'link': false
        'image': false
        'blockquote': true
    )

$(document).on 'page:load', ->
  window['rangy'].initialized = false