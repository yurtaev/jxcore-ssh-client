controllers.controller "HostsCtrl", ($scope, $document) ->

  initHack = ->
    $html = angular.element(document.querySelector('#shell')).find('iframe').contents().find('html')
    console.log 'initHack', $html

    $html.bind 'click', ->
      if cordova.plugins.Keyboard.isVisible
        console.log 'Keyboard', yes
      else
        $html.find('textarea').focus()
        console.log 'Keyboard', no

  htermInit = (rootEl) ->
    hterm.defaultStorage = new lib.Storage.Memory()
    lib.init (-> Crosh.init(rootEl)), console.log.bind(console)

  initTerm = (rootEl) ->
    terminal = new hterm.Terminal

    terminal.decorate(rootEl)
    terminal.id = rootEl.id

    terminal.prefs_.set "font-size", 14
    terminal.prefs_.set "font-smoothing", 'auto'
    terminal.prefs_.set "cursor-color", "#002b36"
    terminal.prefs_.set "background-color", "#eee8d5"
    terminal.prefs_.set "foreground-color", "#002b36"
    terminal.prefs_.set "color-palette-overrides",
        ["#073642", "#dc322f", "#859900", "#b58900", "#268bd2", "#d33682", "#2aa198", "#eee8d5", "#002b36", "#cb4b16",
          "#586e75", "#657b83", "#839496", "#6c71c4", "#93a1a1", "#fdf6e3"]

    setTimeout (->
      terminal.setCursorPosition 0, 0
      terminal.setCursorVisible yes
      terminal.setCursorBlink no
      terminal.runCommandClass Crosh, document.location.hash.substr(1)

#      terminal.io['rows'] = 35
#      terminal.io['cols']  = 44
      terminal.io['term'] = 'xterm'

      window.terminal = terminal
      initHack()
    ), 500


  Crosh = (argv) ->
    @argv_ = argv
    @io = null
    @pid_ = -1


  Crosh.init = initTerm

  Crosh::sendString_ = (string) ->
    console.debug 'Crosh::sendString_', string
    jxcore('write').call($scope.id, string, ->)

  Crosh::onTerminalResize_ = (width, height) ->
    console.debug 'Crosh::onTerminalResize_', arguments...
    jxcore('setWindow').call($scope.id, height, width, ->)


  Crosh::run = ->
    console.log 'Crosh::run'
    @io = @argv_.io.push()
    @io.onVTKeystroke = @sendString_.bind(this)
    @io.sendString = @sendString_.bind(this)
    @io.onTerminalResize = @onTerminalResize_.bind(this)


  # Init


  htermInit document.getElementById('shell')

  $scope.keyboard = ->
    $html = angular.element(document.querySelector('#shell')).find('iframe').contents().find('html')
    console.log '=>', 'keyboard2', $html.find('textarea')
    $html.find('textarea').focus()
    return no

  $scope.connect = ->
    options =
      host: 'example.com'
      port: 22
      username: 'username'
      password: 'password'
      tryKeyboard: true

    jxcore('connect').call options, (id, options) ->
        console.debug('connect', 'callback', arguments)
        $scope.id = id
