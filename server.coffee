config = require('./config.js').config
express = require 'express'
fs = require 'fs'
path = require 'path'
eco = require 'eco'
_ = require 'underscore'
log4js = require('log4js')
log4js.replaceConsole()

markers = []

app = require('express')()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

socket = undefined
io.enable 'browser client minification'         # send minified client
io.enable 'browser client etag'                 # apply etag caching logic based on version number
io.enable 'browser client gzip'                 # gzip the file
io.set 'log level', config.sockets.log_level
io.set 'transports', config.sockets.transports

app.configure ->
    app.use '/static', express.static path.join(__dirname, '/static')
    app.use express.bodyParser()
    app.use (req, res, next) ->
        res.header 'Access-Control-Allow-Origin', config.allowedDomains
        res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
        res.header 'Access-Control-Allow-Headers', 'Content-Type'
        next()

app.get '/', (req, res) ->
    template = fs.readFileSync path.join(__dirname + "/index.eco.html"), "utf-8"
    context = 
        markers: markers
        config: config
    res.send eco.render template, context


app.post '/activities', (req, res) ->
    console.log "POST /activities", req.body
    try
        activities = req.body
        new_markers = []

        for activity in activities
            console.log "received activity", JSON.stringify activity

            marker = 
                geometry:
                    coordinates: [activity.longitude, activity.latitude]
                properties:
                    'marker-color': '#ffc84e' #yellow
                    'marker-size': 'medium'
                    title: activity.title
                    description: activity.description
                timestamp: activity.timestamp

            is_duplicate = ! _.isUndefined _.find markers, (element) -> _.isEqual element, marker
            
            unless is_duplicate
                markers.push marker
                new_markers.push marker

        # only keep the last n markers
        markers = _.last(markers, config.max_markers) ? []

        # broadcast to all clients
        if new_markers.length > 0
            io.sockets.emit 'update', new_markers

        res.send 200

    catch error
        console.error error
        res.send 500


console.log "http server running on port " + config.port
server.listen config.port