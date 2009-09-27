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
This will not work for computers behind a firewall blocking outoing traffic on port 843.  See below for details.

##Javascript UPDATED API 9/26/09
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


	//publish a message to an exchange
	MQ.topic("fooTopic").publish({ foo: "bar" }, "foo.bang.bar");

	//same shit, different exchange
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

Web Server (Not Exactly True)
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


##Thanks
Ralf S. Engelschall