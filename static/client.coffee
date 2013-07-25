
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
        , 3000

    nextOne()


createMap = ->
    map = mapbox.map('map')
    map.addLayer(mapbox.layer().id('examples.map-zr0njcqy'))

    markerLayer = mapbox.markers.layer()

    # Add interaction to this marker layer. This
    # binds tooltips to each marker that has title
    # and description defined.
    mapbox.markers.interaction(markerLayer)
    map.addLayer(markerLayer)

    map.zoom(9).center
      lat: 51
      lon: 4.25

    markerLayer.features(markers)

    loopMarkers(map, markerLayer.markers())
###
markers = [{
    geometry: {
        coordinates: [4.5, 51]
    },
    properties: {
        'marker-color': '#ffc84e',
        "marker-size": "medium",
        title: 'Example Marker',
        description: 'This is a single marker.'
    }
  },
  {
      geometry: {
          coordinates: [5, 51]
      },
      properties: {
          'marker-color': '#ffc84e',
          "marker-size": "medium",
          title: 'Example Marker',
          description: 'This is a single marker.'
      }
  }
]
###

createMap()



