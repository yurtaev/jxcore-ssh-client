uuid = require 'node-uuid'
Client = require('ssh2').Client


connections = {}
streams = {}


log = (msg) -> Mobile('log').call(msg)

exports =
    setWindow:
        sync: no
        callback: (id, rows, columns) ->
            streams[id].setWindow rows, columns
    write:
        sync: no
        callback: (id, data) ->
            streams[id].write data
    connect:
        sync: no
        callback: (options, callback) ->
            id = uuid.v1()
            connections[id] = connection = new Client

            connection.on('keyboard-interactive', (name, instructions, instructionsLang, prompts, finish) ->
                finish [options.password]
            )

            connection.on 'ready', ->
                log 'Client :: ready'

                connection.shell (err, stream) ->
                    if err
                        throw err

                    streams[id] = stream

                    stream.on 'close', (code, signal) ->
                        log 'Stream :: close :: code: ' + code + ', signal: ' + signal
                        connection.end()

                    stream.on 'data', (data) ->
                        log data.toString()

                    stream.stderr.on 'data', (data) ->
                        log data.toString()

            connection.connect(options)
            callback(id, options)



for name, options of exports
    if options.sync
        Mobile(name).registerSync(options.callback)
    else
        Mobile(name).registerAsync(options.callback)
