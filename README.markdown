#amqp-js

* amqp-js brings low-latency message queuing to javascript, without using HTTP.
* amqp-js joins forces with actionscript to establish socket connections to your AMQP server.
* [Google Group Page](http://groups.google.com/group/amqp-js) or amqp-js@googlegroups.com

##In development
* Adaptor interface for alternative transports (WebSockets, Comet)
* TLS Support
* Examples
* Documentation

##Firewall Note
This will not work for computers behind a firewall blocking outgoing traffic on port 843.  See below for details.

If a firewall is blocking your access and you do not have permissions to modify it, you can still run the examples.
Start up a local AMQP server (by default it listens on port 5672) and modify the examples to connect to your host.
e.g. modify MQ.configure to use 'host: "localhost"'

##Javascript UPDATED API February 16, 2011
I rewrote the API with the requirement that the
programmer does not have to deal with execution order.  There are some caveats,
but the model allows for very consise and simple implementation.


##Getting Started

Include "mq.js" in your document, along with embedding the swf.  I use "swfobject.js":

	<script src="path/to/swfobject.js" type="text/javascript"></script>
	<script src="path/to/mq.js" type="text/javascript"></script>

Configure the AMQP client and do work


	//configure params here
	MQ.configure({
		//enable logging to the console
		//logger: console,
		// to get better performance set
		//onReceiveHandler: "queue",
		host: "amqp.peermessaging.com"
	});

	//create a queue, with an auto generated unique name
	//and subscribe. Note: You can only have one auto exchange
	MQ.queue("auto");

	//subscribe to a named queue and handle messages sent to it
	//in a round robin fashion (the behavior of AMQP shared queues)
	MQ.queue("roundRobin").callback(function(m) {
		alert("message receieved");
	});

	
	//declare a topic exchange
	MQ.topic("fooTopic");
	
	//declare a fanout exchange
	MQ.fanout("fooFanout");
	
	//declare a direct exchange
	MQ.direct("fooDirect");
	
	//bind your auto queue to a topic exchange, with a routingKey
	MQ.queue("auto").bind("fooTopic", "foo.*.bar").callback(function(m) {
		alert(m.data.foo);
	});
	
	//bind the auto queue to a fanout exchange
	MQ.queue("auto").bind("fooFanout").callback(function(m) {
		alert("fooFanout message received");
	});

	//delete a queue
	MQ.deleteQueue("queueName", options);

	// options is an optional hash respecting the following keys:
	var options = {
		ifUnused: true, /* (default false). If set to true, the server will only delete the queue if it has no consumers . */
		ifEmpty: true, /* (default false). If set to true, the server will only delete the queue if it has no messages */
		nowait: true /* (default false) */
	};

	// Example:
	// MQ.deleteQueue("my_queue", {ifUnused: true});

	//publish a message to an exchange
	MQ.topic("fooTopic").publish({ foo: "bar" }, "foo.bang.bar");

	//same thing, different exchange
	MQ.fanout("fooFanout").publish({ foo: "bar" });
	
	//this is identical to the above code
	MQ.exchange("fooExchange", { type: "fanout" }).publish({ foo: "bar" });
	
	
	//the received message format is as follows
	var m = {
		data		: { ... }, 	//your data object (json)
		exchange	: "", 		//the exchange name
		queue		: "",		//the queue name
		routingKey	: "",		//key for topic exchanges
	};
	
	//this is a recommended way of embedding the swf file
	//although, you can use any method you like and the swf
	//when loaded will allow the above code to run in order.
	swfobject.embedSWF(
		"../swfs/amqp.swf",
		"AMQPProxy",
		"1",
		"1",
		"9",
		"../swfs/expressInstall.swf",
		{},
		{
			allowScriptAccess: "always",
			wmode	: "opaque",
			bgcolor	: "#ff0000"
		},
		{}
	);

##Requirements
AMQP Server
	RabbitMQ: http://www.rabbitmq.com/
	ActiveMQ: http://activemq.apache.org/
	Qpid: http://qpid.apache.org/
	ZeroMQ: http://www.zeromq.org/

Web Server (Not Exactly True; see Flash Policy section below)
Basic understanding of message queues.


##Flash Policy
Since amqp-js uses flash to bind to sockets, it's important that you understand how flash deals with sockets.

The following article will help you understand flash policy files
http://www.adobe.com/devnet/flashplayer/articles/fplayer9_security_04.html

Your server will need to dish out flash policy files on port 843.  Check the policy-server
directory to get access to an example flash policy file, a python script to host them,
and an init script to daemonize the flash policy server.  This is fully working on debian.
Note:  the client's network must allow outgoing traffic on port 843 in order for any flash
socket activity.

If you prefer to do your development without running everything through a web server, the Flash plugin security 
settings must be modified to allow local filesystem access. The Macromedia website has a page for accessing the
Flash Settings Manager control panel. Visit this URL for access:
http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager.html

Click on the Global Security Settings tab in the panel. I recommend adding a specific file path
corresponding to the location of your development files. Click on the "Edit Locations..." drop-down menu,
choose "Add Location" and browse to the directory containing your development files.

If you want to run the examples, add /path/to/amqp-js/examples to the trusted locations. Once completed, you
can open the examples directly without running them through a web server or starting up the policy server.



##Thanks
* Ralf S. Engelschall
* Dobro
* cthulhu
