

var http = require('http');
var url = require('url');
// var ui = require('w2ui');
// var ffi = require('ffi');

//var libm = ffi.Library('libm', {
//  'ceil': [ 'double', [ 'double' ] ]
//});
//console.log('count: %d', libm.ceil(1.5) );
//c = libm.ceil(1.5).toString();

c = "hello ";

http.createServer(function (req, res) {
    res.writeHead(200, {'Content-Type': 'text/html'});
    var q = url.parse(req.url, true).query;
    var txt = q.year + " " + q.month;
    res.write(c);
    res.write(txt);
    res.end();

}).listen(8088);
