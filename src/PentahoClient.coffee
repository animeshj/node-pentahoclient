request = require 'request'
parser  = require 'xml2json-light'

class PentahoClient

	constructor: (options) ->
		@host = options.host or process.env.PENTAHO_HOST
		@port = options.port or process.env.PENTAHO_PORT or 9080
		@username = options.username or process.env.PENTAHO_USERNAME
		@password = options.password or process.env.PENTAHO_PASSWORD


	_parseJson: (res) ->
		listp ={}

		if res && res.serverstatus && res.serverstatus.jobstatuslist==''
				listp ={}

		if res && res.serverstatus && res.serverstatus.jobstatuslist && res.serverstatus.jobstatuslist.jobstatus && res.serverstatus.jobstatuslist.jobstatus.jobname
				listp[res.serverstatus.jobstatuslist.jobstatus.jobname]=res.serverstatus.jobstatuslist.jobstatus.status_desc

		if res && res.serverstatus && res.serverstatus.jobstatuslist && res.serverstatus.jobstatuslist.jobstatus && res.serverstatus.jobstatuslist.jobstatus.jobname==undefined
				for x in res.serverstatus.jobstatuslist.jobstatus
					listp[x.jobname]=x.status_desc
		return listp



	getServerJobList: (callback) =>
		@getServerStatus  (err, res ) =>
			callback {} if err or callback {} unless res
			listp = @_parseJson(res) if res
			callback listp


	runJob:	(jobloc, callback) ->
		console.log jobloc
		@_performRequest "/pentaho-di/kettle/runJob?job=#{jobloc}&level=Debug&xml=y", callback

	startJob:	(jobname, callback) ->
		console.log jobname
		@_performRequest "/pentaho-di/kettle/startJob?name=#{jobname}&xml=y", callback



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
		    callback error,null
				return

		  json = parser.xml2json( body )
		  callback null, json

module.exports = PentahoClient
