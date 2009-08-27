Ext.ux.SnakePanel = Ext.extend(Ext.Panel, {


	initComponent: function() {

		Ext.apply(this, {
			id: "snakegame"
		});
		
		AMQPClient.addListener("exchangeDeclared", this.createSnakeGame, this);

		Ext.ux.LogPanel.superclass.initComponent.apply(this, arguments);
	},
	
	
	testFn: function(m) {
		this.game.onMessage(m);
	},
	
	
	createSnakeGame: function(ex) {
		this.game = new SnakeGame({
			canvas	: $('snakegame'),
			name	: MQ.declare.queue,
			exchange: ex
		});
		
		//MQ.bind(ex, "snake", this.game.onMessage.createDelegate(game));
		MQ.bind(ex, "snake", this.testFn.createDelegate(this));
	}
});
Ext.ComponentMgr.registerType('snakePanel', Ext.ux.SnakePanel);
