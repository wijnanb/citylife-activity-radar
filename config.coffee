exports.config =
    host: "http://localhost"
    port: 5000
    sockets:
    	port: 5001
    	log_level: 1            # 0 - error, 1 - warn, 2 - info, 3 - debug
    	transports: ['websocket', 'htmlfile', 'xhr-polling', 'jsonp-polling']   # don't use flashsockets if not on port 80
    allowedDomains: "*"
    map:
    	zoom: 9
    	center: [51,4.25]
    	zoomDetail: 13
    loop:
        count: 10