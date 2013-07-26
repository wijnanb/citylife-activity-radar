
map = undefined
markerLayer = undefined
  
loopMarkers = () ->
    i = 0

    nextOne = ->
        window.setTimeout ->
            markerData = markerLayer.markers()

            if markerData.length > 0
                marker = markerData[i]

                map.center marker.location, true
                window.setTimeout ->
                    marker.showTooltip()
                , 300

                i++
                if i >= Math.min markerData.length-1, config.loop.count
                    i = 0

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

    loopMarkers()

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
        connected(true)
        console.log '[SOCKET.IO] Update', response

        for marker in response
            marker.timestamp = new Date(marker.timestamp)

            is_duplicate = ! _.isUndefined _.find markers, (element) -> _.isEqual element, marker

            unless is_duplicate
                markers.push marker
                console.log 'new Marker', marker

        # sort markers by date
        _.sortBy markers, 'timestamp'

        # only keep the last n markers
        window.markers = _.last(markers, config.max_markers) ? []

        markerLayer.features(markers)

    socket.on 'disconnect', ->
        connected(false)
        console.log '[SOCKET.IO] Disconnected'
   
    socket.on 'error', (error) ->
        connected(false)
        console.error '[SOCKET.IO] Error', error


createMap()
openSocket()



