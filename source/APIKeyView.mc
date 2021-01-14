using Toybox.WatchUi as Ui;

class APIKeyView extends Ui.View {

	var apiKeyText;

    function initialize() {
    	View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {

    	
        setLayout(Rez.Layouts.APIKeyLayout(dc));
    }

    // Update the view
    function onUpdate(dc) {
		View.onUpdate(dc);
    }

}
