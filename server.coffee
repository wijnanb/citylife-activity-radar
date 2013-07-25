config = require('./config.js').config
express = require 'express'
fs = require 'fs'
path = require 'path'
eco = require 'eco'
log4js = require('log4js')
log4js.replaceConsole()

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
    context = {}
    res.send eco.render template, context

console.log "http server running on port " + config.server_port
server.listen config.server_port