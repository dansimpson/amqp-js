/*
Copyright (c) 2009 Dan Simpson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/


var TopicExchange = new Class({
	
	Implements	: [Events, Log],
	
	client		: null,
	name		: null,
	key			: "*",
	messages	: [],
	subscribed	: false,

	initialize: function(opts) {
		$extend(this,opts);
		
	},

	onMessageReceived: function(z,message) {
		//this.data.push(message);
		this.log(z, message);
		//this.fireEvent('message_recevied');
	},
	
	subscribe: function() {
	},

	publish: function(message) {
		/*if(!this.subscribed) {
			this.client.bridge.object.subscribe(this.name, this.key);
			this.subscribed = true;
		}*/
		this.log("Sending message on " + this.name + " - " + this.key);
		this.client.bridge.object.publish(this.name, this.key, message);
	}
	
});



var AMQPClient = new Class({

	Implements	: [Events, Log],
	
	host		: "localhost",
	vhost		: "/",
	port		: 5672,
	login		: "guest",
	passcode	: "guest",
	
	initialize: function(opts) {
		$extend(this,opts);
		
		//TODO: fix... make it so there can be more than one client
		MQ.client = this;
		
		if(this.bridgePath) {
			this.createBridge(this.bridgePath);
		}
	},
	
	
	createBridge: function(path) {
		this.bridge = new Swiff(path, {
			id: 'amqp_bridge_swiff',
			container: 'amqp_bridge',
			width: 10,
			height: 10
		});
	},
	
	exchange: function(opts) {
		return new TopicExchange($extend(opts, {
			client: this
		}));
	},
	
	
	/**
	* Event Handlers
	*/
	onMessageReceived: function(queue, message) {
		this.log(queue, message);
	},

	//handle the error properly
	onConnectionError: function(details) {
		this.log("Connection Error.  Details: " + details);
	},

	//ready to subscribe publish
	onConnect: function() {
		this.log("Connection Established");
	},

	//ready to call commands on the bridge
	onReady: function() {
		this.log("Bridge Initialized - Connecting");
		this.bridge.object.connect(this.host, this.port, this.login, this.passcode);
	}
	
});



MQ = {

	client	: null,

	onMessageReceived: function(queue, message) {
		this.client.onMessageReceived(queue, message);
	},

	//handle the error properly
	onConnectionError: function(details) {
		this.client.onConnectionError();
	},

	//ready to subscribe publish
	onConnect: function() {
		this.client.onConnect();
	},

	//ready to call commands on the bridge
	onReady: function() {
		this.client.onReady();
	}

};