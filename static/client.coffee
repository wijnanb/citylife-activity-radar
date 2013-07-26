
ignorePopups = (markers) ->
    clean = []
    for marker in markers
        clean.push marker if marker.showTooltip

    return clean
  
loopMarkers = (map, markerData) ->
    i = 0

    nextOne = ->
        window.setTimeout ->
            markers = ignorePopups markerData
            i = 0 if (++i > markers.length - 1)
            
            map.center(markers[i].location, true)
            markers[i].showTooltip()
            nextOne()
        , 4000

    window.setTimeout -> 
        nextOne()
    , 2000

    window.setTimeout -> 
        map.zoom(config.map.zoomDetail, true)
    , 5900


createMap = ->
    map = mapbox.map('map')
    map.addLayer(mapbox.layer().id('examples.map-zr0njcqy'))

    markerLayer = mapbox.markers.layer()

    # Add interaction to this marker layer. This
    # binds tooltips to each marker that has title
    # and description defined.
    mapbox.markers.interaction(markerLayer)
    map.addLayer(markerLayer)

    map.zoom(config.map.zoom).center
        lat: config.map.center[0]
        lon: config.map.center[1]

    markerLayer.features(markers)

    loopMarkers(map, markerLayer.markers())

connected = (status) ->
    if status
        $('#connection_status').html "connected"
        $('#connection_status').addClass "connected"
    else
        $('#connection_status').html "not connected"
        $('#connection_status').removeClass "connected"

openSocket = ->
    socket_options =
        reconnect: true
        reconnection_delay: 3000
        max_reconnection_attempts: 1

    socket = io.connect config.host+":"+config.port, socket_options

    socket.on 'connect', (socket) ->
        console.log '[SOCKET.IO] Connect'
        connected(true)

    socket.on 'update', (response) ->
        # parse the response
        # ...

        connected(true)
        console.log '[SOCKET.IO] Update', response
    
    socket.on 'disconnect', ->
        connected(false)
        console.log '[SOCKET.IO] Disconnected'
   
    socket.on 'error', (error) ->
        connected(false)
        console.error '[SOCKET.IO] Error', error


createMap()
openSocket()



