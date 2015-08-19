App.filter 'ToTrustedHtml', ['$sce', ($sce) ->
  (text) ->
    $sce.trustAsHtml text
]