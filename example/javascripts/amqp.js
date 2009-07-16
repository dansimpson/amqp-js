function makeEventful(klass) {
}

var MessageQueue = function(opts) {
	for(var k in opts) {
		this[k] = opts[k];
	}
	Velveteen.registerQueue(this);
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

	bind: function(exchange, routingKey, callback) {
		this.route(exchange.declare.exchange, routingKey, callback);
		Velveteen.apiCall("bind", this.declare.queue, exchange.declare.exchange, routingKey);
	},

	unbind: function(exchange, routingKey) {
		this.unroute(exchange.declare.exchange, routingKey, callback);
		Velveteen.apiCall("unbind", this.declare.queue, exchange.declare.exchange, routingKey);
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
	},
	
	onReceive: function(data) {
		var ex = this.routes[data.exchange];
		if(ex) {
			for(var k in ex) {
				var rk = new RegExp("^" + k.replace('*','(.+)') + "$");
				if(rk.test(data.routingKey)) {
					if(typeof ex[k] == "function") {
						ex[k](data);
					}
				}
			}
		}
		if(this.callback) {
			this.callback(data);
		}
	}

};


var Exchange = function(opts) {
	for(var k in opts) {
		this[k] = opts[k];
	}
	Velveteen.registerExchange(this);
};

Exchange.prototype = {

	declare	: {
		exchange	: "amq.fanout",
		type		: "fanout"
	},

	routes	: {},
	
	publish: function(key, message) {
		Velveteen.apiCall("publish", this.declare.exchange, key, message);
	},
	
	route: function(key, callback) {
		this.routes[key] = callback;
	}
};


var Velveteen = {

	logger		: null,
	connection	: {},
	logLevel	: 1,
	instance	: null,
	connected	: false,
	queues		: [],
	exchanges	: {},
	listeners	: {},
	
	initialize: function(opts) {
		for(var k in opts) {
			this[k] = opts[k];
		}
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
		this.apiCall("subscribe", q.declare);
		this.queues.push(q);
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
		//alert('ready');
		this.instance = document.getElementById('amqp_flash');
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
	
	onDeclare: function(queue) {
		this.queues[0].onDeclare(queue);
		this.fireEvent("queueDeclared", this.queues[0]);
	},
	
	onExchangeDeclare: function(exchange) {
		this.exchanges[exchange].declared = true;
		this.fireEvent("exchangeDeclared", this.exchanges[exchange]);
	},
	
	onReceive: function(data) {
		this.queues[0].onReceive(data);
	},
	
	addListener: function(name, fn, scope) {
		if(!this.listeners[name]) {
			this.listeners[name] = [];
		}
		this.listeners[name].push({
			fn: fn,
			scope: scope || window
		});
	},
	
	fireEvent: function() {
		var args = [].slice.call(arguments);
		var name = args.shift();
		var calls = this.listeners[name];
		for(var i = 0; i < calls.length;i++) {
			var c = calls[i];
			c.fn.apply(c.scope, args);
		}
	}

};