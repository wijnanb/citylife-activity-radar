citylife-activity-radar
==============

A server listen for activity on citylife and visualising these on a map


# Installation

You will need a Node.js installation (v >0.8)

In folder "node.js":

Install dependencies:

    npm install

Compile coffeescripts: (with -b option!)

    node_modules/.bin/coffee -bc *.coffee # for development: add -w for watching changes

Run server:

    node server.js