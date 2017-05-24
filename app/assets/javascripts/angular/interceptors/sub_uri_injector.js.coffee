# This interceptor adds the base url to every ajax request before it is sent to
# the server. The base url is set in the local_env.yml file under the key 
# BASE_URL, and read into a javascript global variable, _base_url, in the
# application.html.erb file before other application javascript are loaded. 
# The base url is normally the root folder, /, but if the app is mounted on a 
# sub-uri (non-root folder), for example when hosting multiple apps on the same
# server and using PhassengerPhusion, then ajax requests need to be re-written
# to include the mount path. Rails requests do not need to be re-written since
# setting the PassengerBaseURI variable in the virtual host takes care of it. 
App.factory 'SubUrlInjector', [ ->
  baseUrlInjector = request: (config) ->
    if (_base_url != '/')
      config.url = _base_url + config.url
    config
  baseUrlInjector
]

App.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push 'SubUrlInjector'
]