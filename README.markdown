#amqp-js

* amqp-js brings low-latency message queuing to javascript, without using HTTP.
* amqp-js joins forces with actionscript to establish socket connections to your AMQP server.
* amqp-js alpha working example http://amqp.peermessaging.com (open in 2 windows)


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

	//This declares a queue and subscribes
	//to it.  When messages are delivered to the queue,
	//the method myCallbackFunction is called.
	var queue:Queue = new Queue(connection, {
		queue: "somequeue",
		exclusive: false
	}, myCallbackFunction);
	
	//this simply declares a topic exchange called stocks
	var exchange:Exchange(connection, {
		exchange: "stocks",
		type: "topic"
	});
	
	//This binds the exchange to the queue, so that when
	//messages are published on the exchange with the routing key
	//matching nasdaq.*, they are delivered to the queue.
	//Beyond that, we specify a callback override, so that
	//myOtherCallback is called rather than myCallbackFunction for
	//messages matching the bind conditions
	queue.bind(exchange, "nasdaq.*", myOtherCallback);
	
	//This publishes a message to the exchange, with the routingKey "test".
	//The message payload is a simple object.
	exchange.publish("test", { 
		type: "test",
		message: "this is a test message payload"
	});


##Javascript - High Level Implementation
In order to send and receive messages from an AMQP broker with javascript,
you need to do the following.

- Include "amqp.js" in your src.
- Configure the proxy.  Example:

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
		//The callback is called when messages
		//are delivered to the queue
		myQueue = new MessageQueue({
			callback: messageRecieved
		});
		
		//Declare an exchange
		myExchange = new Exchange({
			declare: {
				exchange: "myExchange",
				type: "topic"
			}
		});
		
		//Bind the exchange to the queue
		myQueue.bind(myExchange, "keyTest", exchangeMessageReceived);
		
		//Publish a message on the exchange
		myExchange.publish("keyTest", { message: "hello world!" });
	});

- Load the AMQPFlash.swf object into the dom. Example using swfobject:

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
- AMQP Server

	RabbitMQ: http://www.rabbitmq.com/
	ActiveMQ: http://activemq.apache.org/
	Qpid: http://qpid.apache.org/
	ZeroMQ: http://www.zeromq.org/

- Web Server (Not Exactly True)
- Basic understanding of message queues.


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