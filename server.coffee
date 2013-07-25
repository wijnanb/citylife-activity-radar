config = require('./config.js').config
express = require 'express'
fs = require 'fs'
path = require 'path'
eco = require 'eco'
_ = require 'underscore'
log4js = require('log4js')
log4js.replaceConsole()

markers = []
server = express()

server.configure ->
    server.use '/static', express.static path.join(__dirname, '/static')
    server.use express.bodyParser()
    server.use (req, res, next) ->
        res.header 'Access-Control-Allow-Origin', config.allowedDomains
        res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
        res.header 'Access-Control-Allow-Headers', 'Content-Type'
        next()

server.get '/', (req, res) ->
    template = fs.readFileSync path.join(__dirname + "/index.eco.html"), "utf-8"
    context = 
        markers: markers
    res.send eco.render template, context


server.post '/activities', (req, res) ->
    try
        activities = req.body
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


            is_duplicate = _.find markers, (element) -> _.isEqual element, marker
            
            unless is_duplicate
                markers.push marker

        res.send 200

    catch error
        console.error error
        res.send 500


console.log "http server running on port " + config.server_port
server.listen config.server_port