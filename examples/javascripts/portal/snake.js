Ext.ux.SnakePanel = Ext.extend(Ext.Panel, {


	initComponent: function() {

		Ext.apply(this, {
			id: "snakegame"
		});
		
		this.on("afterrender", this.createSnakeGame, this);

		Ext.ux.LogPanel.superclass.initComponent.apply(this, arguments);
	},

	
	createSnakeGame: function() {
		this.game = new SnakeGame({
			canvas	: $('snakegame'),
			name	: Math.random().toString()
		});
	}
});
Ext.ComponentMgr.registerType('snakePanel', Ext.ux.SnakePanel);
