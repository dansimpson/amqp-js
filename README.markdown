#amqp-js

* amqp-js brings low-latency message queuing to javascript, without using HTTP.
* amqp-js joins forces with actionscript to establish socket connections to your AMQP server.
* amqp-js works: http://amqp.peermessaging.com (open in 2 windows)


##Javascript
In order to send and receive messages from an AMQP broker with javascript,
you need to do the following.

Include "swfobject.js" and "amqp.js" in your document:

	<script src="path/to/swfobject.js" type="text/javascript"></script>
	<script src="path/to/amqp.js" type="text/javascript"></script>

Configure the AMQP client and setup a simple hello world:

	
	function directCallback(m) {
		alert("Direct Callback");
	};

	function exchangeCallback(message) {
		alert(message.data.message); //hello world!
	};

	function helloWorld() {
		myExchange.publish("keyTest", { message: "hello world!" });
	};

	var myQueue;
	var myExchange;

	//Initialize the proxy
	AMQPClient.initialize({
		connection: {
			host: "amqp.peermessaging.com"
		},
		logLevel	: 2, //slightly chatty.
		swfPath		: "path/to/AMQPFlash.swf",
		expressPath	: "path/to/expressInstall.swf"
	});


	AMQPClient.addListener("ready", function() {

		//Declare a queue and subscribe to it.
		//The callback is called when messages
		//are delivered to the queue.
		myQueue = new MessageQueue({
			callback: directCallback
		});

		//Declare an exchange for publishing messages
		//and binding
		myExchange = new Exchange({
			declare: {
				exchange: "ubertopic",
				type: "topic"
			}
		});

		//when the queue is declared, bind the exchange to it, so that
		//messages published to the exchange are delivered to the queue
		//and the javascript callback is called
		myQueue.addListener("declared", function(queue) {
			queue.bind(myExchange, "keyTest", exchangeCallback);
		}, this);
	});
	


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
and an init script to daemonize the flash polciy server.  This is fully working on debian.

##Todo
* Finish code to allow for multiple queue subscriptions
* Package everything nicely
* Provide better sequence handling
* TLS Support - Security
* 0.91 Support and eventually 1.0
* More Examples
* Shrink file size (29Kb now)
* Make it easier