//the main application object, exposed globally
var Application;
var MQ;
var DemoExchange;

//the application class, used for loading panels, and handling navigation
Ext.Application = Ext.extend(Ext.Viewport, {

	initComponent: function() {

		Ext.apply(this,{
			layout: 'vbox',
			border: false,
			renderTo: 'application-view',
			layoutConfig: {
				align : 'stretch'
			},
			defaults: {
				border: false,
				flex: 1,
				anchor: "100% 50%",
				layout: 'hbox',
				layoutConfig: {
					align : 'stretch'
				},
				defaults: {
					flex  : 1,
					margins: "2 2 2 2"
				}
			},
			
			items: [{
				items: [{
					xtype: 'snakePanel',
					title: 'Snakes!',
					bbar: [{
						xtype: "label",
						text: "Click Whitespace to Spawn.  Use arrow keys to turn.  Edges are death!"
					}]
				},{
					xtype: 'interactiveGridPanel',
					title: 'Increment Updates'
				}]
			},{
				items: [{
					xtype: 'chatPanel',
					title: 'Chat'
				},{
					xtype: 'logPanel',
					title: 'Logging'
				}]
			
			}]
		});
		
		Ext.Application.superclass.initComponent.apply(this, arguments);
	},
	
	messageReceived: function(msg) {
	}
});

//this is the first code executed after the dom is fully
//rendered and ready to go
Ext.onReady(function() {

	Application = new Ext.Application();
	
	MQ.configure({
		host: "amqp.peermessaging.com"
	});

	/*MQ.exchange("demo");
	
	AMQPClient.addListener("ready", function() {
		MQ = new MessageQueue({
			callback: null
		});
	
		DemoExchange = new Exchange({
			declare: {
				exchange: "demo",
				type: "topic"
			}
		});
	});*/
	
	swfobject.embedSWF(
		"../swfs/amqp.swf?nc=" + Math.random().toString(),
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
	
	
	Ext.get("loading").remove();
	Ext.get("loading-mask").fadeOut();
});



