#amqp-js / amqp-flash / velveteen

*Note: this project is not done...  I highly recommend you wait until I have a fully working demo, and a 
documented API*

+amqp-js is an attempt to bring low-latency message queuing to javascript, without using HTTP.
+amqp-js works by joining forces with actionscript to establish socket connections to your AMQP server.


##AS3/Flex/Flash - Protocol implementation (Work in Progress 06/20/2009)
For those familiar with AMQP terminology, the implementation provides classes for every
"AMQP Class", and "AMQP Method".  Each Method Class extends a Method Base Class which provides helper 
methods for creating frames and sending it accross the channel.

Simple Example:

	var declare:Declare = new Declare();
	declare.queue 		= name;
	declare.autoDelete 	= true;
	declare.exclusive 	= false;
	declare.send(connection);

Every "AMQP Method" outlined in the AMQP spec follows this pattern.

Other Helpers (Doc Coming Soon)
Observers
Connection
Event Types
Diagnostics (For logging to the higher level APIs (console.log in JS) etc)


I will be releasing the protocol implementation shortly, targetting advanced actionscripters that
want to implement their own high-level implementation.  **The swf compiles down to 18K so far**.

Thanks to Ben Hood and Aman Gupta for opening up their AMQP projects.  I have referenced both during
the development process.



##AS3/Flex/Flash - High Level AKA Velveteen (Work in Progress 06/20/2009)
I will also be releasing velveteen, a higher level AS3 libary.  Velveteen will abstract the protocol
and provide the programmer with a more sensible API for the most common features.

High Level Classes:

Queue
Exchange
RPC
...

Concept API (Not Official):

	var queue	:Queue 		= new Queue(connection, "my_queue", ...opts);
	var exchange:Exchange 	= new Exchange(connection, "my_exchange", ...opts);
	
	queue.subscribe(callback);
	queue.subscribe(otherCallback, routingKey); //callback only when it meets certain requirements
	
	queue.bind(exchange, "*.routing.key.#");
	queue.bind(exchange, "*.routing.other.#");
	
	queue.publish(data, ...);
	exchange.publish(data, ...);

##Javascript - High Level Implementation (Not Started 06/20/2009)
I will attempt to make this as close to the AS3 high level implementation as possible.  However,
I stated there will be a low level AMQP protocol implementation, and I will expose the entire
protocol to javascript via external interface and stange calls, such as:

	swf.api_call("Connection", "StartOk", {
		clientProperties: {
			product: "AMQP-JS",
			version: "0.01"
		},
		locale: "en_US",
		... //you get the picture if you care about it 
	});

Expected release of protocol implementation: End of June 2009
Expected release of High Level JS implementation: End of July 2009


##Requirements
1. AMQP Server

RabbitMQ: http://www.rabbitmq.com/
ActiveMQ: http://activemq.apache.org/
Qpid: http://qpid.apache.org/
ZeroMQ: http://www.zeromq.org/

2. Web Server (Not Exactly True)
3. Basic understanding of message queues.


##Flash Policy
If you happen to run your AMQP server on a different server than that which you host your website, 
then a few extra steps are required to get everything working together.  
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