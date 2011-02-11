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

//simple inheritance helper
function extend(superclass, constructor_extend, prototype) {
	var res = function () {
		superclass.apply(this);
		constructor_extend.apply(this, arguments);
	};
	var withoutcon = function () {};
	withoutcon.prototype = superclass.prototype;
	res.prototype = new withoutcon();
	for (var k in prototype) {
		res.prototype[k] = prototype[k];
	}
	return res;
}

//used to add methods and properties to objects
function $extend(target, source){
	for (var key in (source || {})) {
		target[key] = source[key];
	}
	return target;
};



/*
* Base class for event dispatch
*/
var Dispatcher = function() { 
	this.listeners = {};
}
Dispatcher.prototype = {

	addListener: function(name, fn, scope) {
		if(!this.listeners[name]) {
			this.listeners[name] = [];
		}
		this.listeners[name].push({
			fn: fn,
			scope: scope || window
		});
	},
	
	on: function(name, fn, scope) {
		this.addListener(name, fn, scope);
	},
	
	fireEvent: function() {
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
	
};


/*
* Represents the binding of an exchange to a queue, callbacks can be
* added to bindings, so messages received by the queue can handle them
* with a different function
*/
var Binding = extend(Dispatcher, function(queue, exchange, key) {
	MQ.dispatch("bind", queue, exchange, key);
	this.pattern = new RegExp("^" + key.replace('.','\.').replace('*','[^\.|$]+').replace('#','([^\.|$]+\.)+') + "$");
}, {

	pattern: null,

	destroy: function() {
		//not supported with AMQP 08, But 09
	},
	
	callback: function(cb, scope) {
		this.on("rcv", cb, scope);
	}
});

/*
* Represents the end point for messages received.  It's the place
* where your messages are sent.  You can bind the queue to exchanges
* and recieve messages sent on those exchanges.
*/
var Queue = extend(Dispatcher, function(opts) {
	$extend(this, opts);
	MQ.dispatch("subscribe", opts);
}, {

	bindings: {},
	
	bind: function(exchange, key) {
		key = key || "";
		key += "";
		
		if (!MQ.exchanges[exchange]) {
			var type = "";
			if (!key.length) {
				type = 'fanout';
			}
			else if ( key.match(/[\*|#]/) ) {
				type = 'topic';
			}
			else {
				type = 'direct';
			};
			MQ.exchange(exchange, {type: type});
		};
		
		// No need to bind queue to an existing fanout exchange if the queue is already bound to this exchange.
		if (MQ.exchanges[exchange].type == 'fanout' && this.bindings[exchange]) {
			for (var k in this.bindings[exchange]) {
				// Return first element
				return this.bindings[exchange][k];
			}
		}
	
		if(!this.bindings[exchange]) {
			this.bindings[exchange] = {}
		}
		
		if(!this.bindings[exchange][key]) {
			this.bindings[exchange][key] = new Binding(this.queue, exchange, key);
		}
		
		return this.bindings[exchange][key];
	},
	
	receive: function(msg) {

		if(this.queue == "auto") {
			this.queue = MQ.dispatch("getAutoQueueName");
		}

		var match = false;
		var ex = this.bindings[msg.exchange];
		if(ex) {
			var type = MQ.exchanges[msg.exchange].type;
			if (type == 'fanout') {
				for(var k in ex) {
					match = true;
					ex[k].fireEvent("rcv", msg);
					break;
				}
			}
			else if (type == 'direct') {
				for(var k in ex) {
					if (k == msg.routingKey) {
						match = true;
						ex[k].fireEvent("rcv", msg);
						}
				}
			}
			else {
                for(var k in ex) {
				    if (ex[k].pattern.test(msg.routingKey)) {
					    match = true;
					    ex[k].fireEvent("rcv", msg);
				    }
                }
			}
		}
		
		//default to the queue callback
		if(!match) {
			this.fireEvent("rcv", msg);
		}
	},

	callback: function(cb, scope) {
		this.on("rcv", cb, scope);
	}
});



/*
* Represents an exchange, which is used to partition message
* spaces and publish messages to peers
*/
var Exchange = function(opts) {
	$extend(this, opts);
	MQ.dispatch("exchange", opts);
}
Exchange.prototype = {
	publish: function(message, key) {
		MQ.dispatch("publish", this.exchange, key || "", message);
	}
};



/*
* Adaptor interface for the flash based AMQP API
*/
var FlashAdaptor = extend(Dispatcher, function(){}, {

	buffer		: [],

	exchanges	: {},
	queues		: {},

	api			: null,
	
	logger		: null,
	logLevel	: 2,
	policyUrl	: null,
	
	host		: "amqp.peermessaging.com",
	port		: 5672,
	user		: "guest",
	password	: "guest",
	vhost		: "/",
	
	element		: "AMQPProxy",
	autoConnect	: true,

	configure: function(settings) {
		$extend(this, settings);
	},

	connect: function() {
		this.dispatch("connect", {
			host	: this.host,
			port	: this.port,
			user	: this.user,
			password: this.password,
			vhost	: this.vhost
		});
	},

	disconnect: function() {
		this.dispatch("disconnect");
	},
	
	//private
	onLoad: function() {
		this.api = document.getElementById(this.element);
		this.fireEvent("load");
		this.update();
		if(this.autoConnect) {
			this.connect();
		}
	},

	//private
	onConnect: function() {
		this.update();
		this.flush();
		this.fireEvent("connect");
	},

	//private
	onDisconnect: function() {
		this.fireEvent("disconnect");
	},

	//private
	onLogEntry: function(msg) {
		if(this.logger && this.logger.log) {
			this.logger.log(msg);
		}
	},
	
	//private
	onReceive: function(msg) {
		if(this.queues[msg.queue]) {
			this.queues[msg.queue].receive(msg);
		} else {
			this.onLogEntry("Queue not found!");
		}
	},

	queue: function(name, opts) {
		if(!this.queues[name]) {
			this.createQueue(name, opts);
		}
		return this.queues[name];
	},
	
	//private
	createQueue: function(name, opts) {
		this.queues[name] = new Queue($extend({
			queue: name
		}, opts));
	},

	queue_delete: function(name, opts) {
		if(!this.queues[name]) { return false };
		delete this.queues[name];
		if (!opts) {
			opts = {ifUnused: false};
			};
		this.dispatch("queueDelete", name, opts);
	},

	topic: function(name) {
		return this.exchange(name, { type: "topic" });
	},

	fanout: function(name) {
		return this.exchange(name, { type: "fanout" });
	},

	direct: function(name) {
		return this.exchange(name, { type: "direct" });
	},

	exchange: function(name, opts) {
		if(!this.exchanges[name]) {
			this.createExchange(name, opts);
		}
		return this.exchanges[name];
	},
	
	//private
	createExchange: function(name, opts) {
		this.exchanges[name] = new Exchange($extend({
			exchange: name,
			type	: opts.type || "fanout"
		}, opts));
	},
	
	//private
	update: function() {
		if(this.logger) {
			this.dispatch("setLogLevel", this.logLevel);
		}
		if(this.policyUrl) {
			this.dispatch("loadPolicy", this.policyUrl);
		}
	},
	
	//private
	dispatch: function() {
		if(this.api) {
			var args = [].slice.call(arguments);
			return this.api[args.shift()].apply(this.api, args);
		} else {
			this.buffer.push(arguments);
		}
	},
	
	//private
	flush: function() {
		while(this.buffer.length > 0) {
			this.dispatch.apply(this, this.buffer.shift());
		}
	}

});

var MQ = new FlashAdaptor();
