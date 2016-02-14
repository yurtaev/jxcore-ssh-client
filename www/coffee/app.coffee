app = angular.module "app", [
  "ionic"
  "app.controllers"
]

exports =
  log:
    sync: yes
    callback: (msg) ->
      console.log msg
      terminal.io.print msg


jxCoreReady = ->
  console.debug '=>', 'jxCoreReady'
  for name, options of exports
    jxcore(name).register(options.callback)
  jxcore 'app.js'
  .loadMainFile (ret, err) ->
    if err
      alert JSON.stringify(err)


app.run ($ionicPlatform) ->
  $ionicPlatform.ready ->
    cordova.plugins.Keyboard.hideKeyboardAccessoryBar true  if window.cordova and window.cordova.plugins.Keyboard
    cordova.plugins.Keyboard.disableScroll(no)
    StatusBar.styleDefault()  if window.StatusBar
    jxcore.isReady jxCoreReady


app.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider.state "app",
    url: "/app"
    abstract: true
    templateUrl: "templates/menu.html"
    controller: "AppCtrl"

  $stateProvider.state "app.hosts",
    url: "/hosts"
    cache: no
    views:
      menuContent:
        templateUrl: "templates/hosts.html"
        controller: "HostsCtrl"

  $urlRouterProvider.otherwise "/app/hosts"
