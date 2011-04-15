var http = require('http'),
    faye = require('faye'),
    jade = require ('jade'),
		fugue = require('fugue'),
    fs = require('fs');

var template = fs.readFileSync('index.jade', 'utf8');
var bayeux = new faye.NodeAdapter({
  mount:    '/faye',
  timeout:  45
});

// Handle non-Bayeux requests
var server = http.createServer(function(request, response) {
  response.writeHead(200, {'Content-Type': 'text/html'});
  response.write(jade.render(template));
	// response.write('Hello, non-Bayeux request');
  response.end();
});

bayeux.attach(server);

// server.listen(7777);
fugue.start(server, 7777, null, 2, {verbose : true});