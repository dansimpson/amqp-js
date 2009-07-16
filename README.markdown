#amqp-js

^ amqp-js brings low-latency message queuing to javascript, without using HTTP.
^ amqp-js joins forces with actionscript to establish socket connections to your AMQP server.
^ amqp-js 

##AS3 Implementation
For those familiar with AMQP terminology, the implementation provides classes for every
"AMQP Class", and "AMQP Method".  Each Method Class extends a Method Base Class which provides helper
methods for creating frames and getting them to the broker.


Simple Example:

	var declare:QueueDeclare = new QueueDeclare();
	declare.queue 		= ""; //have the broker generate it
	declare.autoDelete 	= true;
	declare.exclusive 	= false;
	connection.send(new Frame(declare));

##Higher level examples

	//this declares the queue the broker and subscribes
	//to it, calling myCallbackFunction when messages
	//are delivered to the queue
	var queue:Queue = new Queue(connection, {
		queue: "somequeue",
		exclusive: false
	}, myCallbackFunction);
	
	//this simply declares a topic exchange called stocks
	var exchange:Exchange(connection, {
		exchange: "stocks",
		type: "topic"
	});
	
	//this binds the exchange to the queue, so that when
	//messages are published on the exchange with the routing key
	//matching nasdaq.*, they are also delivered to the queue.
	//beyond that, we specify another callback override, so that
	//myOtherCallback is called rather than myCallbackFunction
	queue.bind(exchange, "nasdaq.*", myOtherCallback);
	
	//publish a message to the exchange, with the routingKey test
	//the message payload is a simple object.  If you have custom
	//objects you need to send, then you must serialize them.
	exchange.publish("test", { 
		type: "test",
		message: "this is a test message payload"
	});



##Javascript - High Level Implementation
In order to send and receive messages from an AMQP broker with javascript
You need to do the following.

^ Include "amqp.js" in your document.
^ Configure the proxy.  Example:


	var myQueue;
	var myExchange;
	
	function messageRecieved(message) {
		alert(message);
	};
	
	function messageRecieved(message) {
		alert(message.data.message); //hello world!
	};
	
	Velveteen.initialize({
		connection: {
			host: "amqp.peermessaging.com"
		},
		logLevel: 2, //info and errors, 1 is frame dumps, 3 is errors only
		logger: console //firebug logging
	});
	
	Velveteen.addListener("ready", function() {
		//the callback is called when messages
		//are delivered to the queue
		myQueue = new MessageQueue({
			callback: messageRecieved
		});
		
		//declare an exchange
		myExchange = new Exchange({
			declare: {
				exchange: "myExchange",
				type: "topic"
			}
		});
		
		//bind the exchange to the queue
		myQueue.bind(myExchange, "keyTest", exchangeMessageReceived);
		
		//publish a message on the exchange
		myExchange.publish("keyTest", { message: "hello world!" });
	});

^ Load the AMQPFlash.swf object into the dom. Example using swfobject:

	swfobject.embedSWF(
		"swiffs/AMQPFlash.swf",
		"amqp_flash",
		"1",
		"1",
		"9",
		"swiffs/expressInstall.swf",
		{},
		{
			wmode: 'opaque',
			bgcolor: '#ff0000'
		},
		{}
	);


##Requirements
1. AMQP Server

RabbitMQ: http://www.rabbitmq.com/
ActiveMQ: http://activemq.apache.org/
Qpid: http://qpid.apache.org/
ZeroMQ: http://www.zeromq.org/

2. Web Server (Not Exactly True)
3. Basic understanding of message queues.


##Flash Policy
Since amqp-js uses flash to bind to sockets, it's important that you understand how flash deals with sockets.

The following article will help you understand flash policy files
http://www.adobe.com/devnet/flashplayer/articles/fplayer9_security_04.html

Your server will need to dish out flash policy files on port 843.  Check the policy-server
directory to get access to an example flash policy file, a python script to host them,
and an init script to daemonize the flash polciy server.  This is fully working on debian.

Security
Well... I wouldn't use this for anything that requires security.  No promises.
Update:  I will figure out a way to implement TLS, without making the filesize
big. I would like to see it stay under 20KB, but that is optimistic.

##Todo
^ Finish code to allow for multiple queue subscriptions
^ Provide better sequence handling
^ TLS Support
^ More Examples
^ Shrink file size (29Kb now)
^ Make it easier