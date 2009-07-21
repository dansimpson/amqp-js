/**
---------------------------------------------------------------------------

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

---------------------------------------------------------------------------
**/

/*
* Make a "class" act as an event dispatcher.
*/
function eventelize(klass) {
	klass.listeners = {};
	klass.addListener = function(name, fn, scope) {
		if(!this.listeners[name]) {
			this.listeners[name] = [];
		}
		this.listeners[name].push({
			fn: fn,
			scope: scope || window
		});
	};
	klass.fireEvent = function() {
		var args = [].slice.call(arguments);
		var name = args.shift();
		var calls = this.listeners[name];
		if(calls) {
			for(var i = 0; i < calls.length;i++) {
				var c = calls[i];
				c.fn.apply(c.scope, args);
			}
		}
	}
}

/*
* MessageQueue provides a simple interface to a AMQPClient Queue.
* When instantiated, the broker is sent a declare request.
* If the broker accepts the declaration of the queue, the client
* will receive enqueued messages as they arrive.  When the message
* makes it's way to your object, the onReceive message processes the
* data and calls the appropriate callback.
*/
var MessageQueue = function(opts) {
	for(var k in opts) {
		this[k] = opts[k];
	}
	AMQPClient.registerQueue(this);
};

MessageQueue.prototype = {

	declare: {
		queue		: "",
		passive		: false,
		durable		: false,
		exclusive	: false,
		autoDelete	: false,
		nowait		: false
	},

	routes		: {},
	callback	: null,

	
	//bind an exchange to this queue with the routing key "routingKey"
	bind: function(exchange, routingKey, callback) {
		this.route(exchange.declare.exchange, routingKey, callback);
		AMQPClient.apiCall("bind", this.declare.queue, exchange.declare.exchange, routingKey);
	},
	
	//unbind an exchange, so no more messages published on that exchange
	//with the routing key "routingKey" are delivered to this queue
	unbind: function(exchange, routingKey) {
		this.unroute(exchange.declare.exchange, routingKey, callback);
		AMQPClient.apiCall("unbind", this.declare.queue, exchange.declare.exchange, routingKey);
	},
	
	route: function(exchange, routingKey, callback) {
		if(!this.routes[exchange]) {
			this.routes[exchange] = {};
		}
		if(!this.routes[exchange][routingKey]) {
			this.routes[exchange][routingKey] = callback;
		}
	},
	
	unroute: function(exchange, routingKey, callback) {
		var rk = this.routes[exchange][routingKey];
		if(rk) {
			delete rk;
		}
	},

	onDeclare: function(queue) {
		this.declare.queue = queue;
		this.fireEvent('declared', this);
	},
	
	onReceive: function(data) {
		var ex = this.routes[data.exchange];
		if(ex) {
			for(var k in ex) {
				var rk = new RegExp("^" + k.replace('*','(.+)') + "$");
				if(rk.test(data.routingKey)) {
					if(typeof ex[k] == "function") {
						ex[k](data);
						return;
					}
				}
			}
		}
		if(this.callback) {
			this.callback(data);
		}
	}
};
eventelize(MessageQueue.prototype);

/**
* The Exchange class provides a simple interface for
* declaring exchanges and publishing messages to it.
* To bind a queue to an exchange, use the MessageQueue class.
*/
var Exchange = function(opts) {
	for(var k in opts) {
		this[k] = opts[k];
	}
	AMQPClient.registerExchange(this);
};
Exchange.prototype = {
	declared: false,
	declare	: {
		exchange	: "amq.fanout",
		type		: "fanout"
	},
	routes	: {},
	
	publish: function(key, message) {
		AMQPClient.apiCall("publish", this.declare.exchange, key, message);
	},
	
	route: function(key, callback) {
		this.routes[key] = callback;
	},
	
	onDeclare: function(ex) {
		this.declared = true;
		this.fireEvent('declared');
	}
};
eventelize(Exchange.prototype);

/**
* The AMQPClient object acts a proxy between javascript and actionscript.
* You should only use this class for configuration.
*/
var AMQPClient = {

	logger		: null,
	connection	: {},
	logLevel	: 3,
	instance	: null,
	connected	: false,
	queues		: [],
	exchanges	: {},
	swfPath		: "../swfs/AMQPFlash.swf",
	expressPath	: "../swfs/expressInstall.swf",
	id			: "AMQPProxy",
	
	initialize: function(opts) {
		for(var k in opts) {
			this[k] = opts[k];
		}
		
		//embed the swf
		swfobject.embedSWF(
			this.swfPath,
			this.id,
			"1",
			"1",
			"9",
			this.expressPath,
			{},
			{
				allowScriptAccess: 'always',
				wmode: 'opaque',
				bgcolor: '#ffffff'
			},
			{}
		);
	},
	
	configure: function() {
		this.apiCall("configure", {
			logLevel: this.logLevel
		});
	},
	
	connect: function() {
		this.apiCall("connect", this.connection);
	},
	
	disconnect: function() {
		this.apiCall("disconnect");
	},

	registerQueue: function(q) {
		this.queues.push(q);
		this.apiCall("subscribe", q.declare);
	},
	
	registerExchange: function(ex) {
		this.apiCall("exchange", ex.declare);
		this.exchanges[ex.declare.exchange] = ex;
	},
	
	apiCall: function() {
		var args = [].slice.call(arguments);
		this.instance[args.shift()].apply(this.instance, args);
	},

	setLogLevel: function(lvl) {
		this.apiCall("setLogLevel", this.logLevel = lvl);
	},

	/**
	* Not for public use
	*/
	onApiReady: function() {
		this.instance = document.getElementById(this.id);
		this.configure();
		this.connect();
	},
	
	onReady: function() {
		this.fireEvent("ready");
	},
	
	onConnect: function() {
		this.connected = true;
		this.fireEvent("connected");
	},

	onDisconnect: function() {
		this.fireEvent("disconnected");
	},

	onLogEntry: function(msg) {
		if(this.logger) {
			this.logger.log(msg);
		}
	},
	
	onQueueDeclare: function(queue) {
		this.fireEvent("queueDeclared", this.queues[0]);
		this.queues[0].onDeclare(queue);
	},
	
	onExchangeDeclare: function(exchange) {
		this.fireEvent("exchangeDeclared", this.exchanges[exchange]);
		this.exchanges[exchange].onDeclare(exchange);
	},
	
	onReceive: function(data) {
		this.queues[0].onReceive(data);
	}
};
eventelize(AMQPClient);