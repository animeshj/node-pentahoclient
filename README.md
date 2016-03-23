

# Example

```
PentahoClient = require 'pentahoclient'

options =
	host: 'localhost'
	port: 9080
	username: 'admin'
	password: 'password'

client = new PentahoClient(options)

client.getServerStatus (err, res) ->
	console.log res
```
