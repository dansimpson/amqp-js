#amqp-js

* amqp-js brings low-latency message queuing to javascript, without using HTTP.
* amqp-js joins forces with actionscript to establish socket connections to your AMQP server.
* [Google Group Page](http://groups.google.com/group/amqp-js) or amqp-js@googlegroups.com

##In development
* New, more concise, high level API
* Adaptor interface for alternative transports (WebSockets, Comet)
* TLS Support
* Examples
* Documentation

##Firewall Note
This will not work for computers behind a firewall blocking outoing traffic on port 843.  See below for details.

##Javascript UPDATED API 9/26/09
In order to send and receive messages from an AMQP broker with javascript,
you need to do the following.

Include "swfobject.js" and "amqp.js" in your document:

	<script src="path/to/swfobject.js" type="text/javascript"></script>
	<script src="path/to/mq.js" type="text/javascript"></script>

Configure the AMQP client and setup a simple hello world:

	//publish a message to myExhcange
	function helloWorld() {
		MQ.exchange("myExchange").publish({ message: "hello world!" });
	};

	//configure params here
	MQ.configure({
		host: "amqp.peermessaging.com"
	});

	//Declare a queue and subscribe to it.
	//The callback is called when messages
	//are delivered to the queue.
	//bind the exchange to it, so that
	//messages published to the exchange are delivered to the queue
	//and the javascript callback is called
	MQ.queue("auto").bind("myExchange).callback(function(m) {
		alert(m.data.message);
	});

	//embed the swf in the element
	//with id AMQPProxy
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
			wmode: 'opaque',
			bgcolor: '#ff0000'
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

