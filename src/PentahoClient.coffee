request = require 'request'
parser  = require 'xml2json-light'

class PentahoClient

	constructor: (options) ->
		@host = options.host or process.env.PENTAHO_HOST
		@port = options.port or process.env.PENTAHO_PORT or 9080
		@username = options.username or process.env.PENTAHO_USERNAME
		@password = options.password or process.env.PENTAHO_PASSWORD


	getServerStatus: (callback) ->
		@_performRequest '/pentaho-di/kettle/status', callback

	_performRequest: (url, callback) ->

		options =
		  method: 'GET'
		  url: "http://#{@host}:#{@port}#{url}"
		  qs: xml: 'y'
		  headers:
		    'content-type': 'application/xml'

		if @username && @password
			options.headers['Authorization'] = "Basic #{new Buffer(@username + ':' + @password).toString('base64')}"

		request options, (error, response, body) ->
		  #TODO: handle case where response is an HTML body and not XML
		  if error
		    throw new Error(error)

		  json = parser.xml2json( body )
		  callback null, json

module.exports = PentahoClient
