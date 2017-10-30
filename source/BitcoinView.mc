using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;

class BitcoinView extends Ui.View {

	var bitCoinView;
	var bitCoinPrice = "12345.25";

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    	makeRequest();
        setLayout(Rez.Layouts.MainLayout(dc));
        
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    System.println(bitCoinPrice);
    	bitCoinView = new WatchUi.Text({
    		:text => bitCoinPrice,
    		:color => Graphics.COLOR_WHITE,
    		:font => Graphics.FONT_LARGE,
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_CENTER
    	});
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        bitCoinView.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
    
    function onReceive(args) {
    	if (args instanceof Lang.String) {
    		mMessage = args;
    	}
    	else if (args instanceof Dictionary) {
    		var keys = args.keys();
    		mMessage = "";
    		for (var i = 0; i < keys.size(); i++) {
    			mMessage += Lang.format("$1$: $2$\n", [keys[i], args[keys[i]]]);
    		}
    	}
    	Ui.requestUpdate();
    }
    
    function makeRequest() {
    	var url = "https://api.coinbase.com/v2/prices/spot?currency=USD";
    	var params = {};
    	var options = {
    		:method => Comm.REQUEST_CONTENT_TYPE_JSON,
    		:headers => {"CB-VERSION" => "2017-09-08"},
    		:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
    	};
    	var responseCallback = method(:onReceeive);
    	Comm.makeWebRequest(url, params, options, method(:onReceeive));
    }
    
    function onReceeive(responseCode, data) {
    	System.println(data);
    	if (responseCode == 200) {
    		System.println("Request Successful");
    		bitCoinPrice = data.get("data").get("amount");
    		Ui.requestUpdate();
    	} else {
    		System.println("Response: " + responseCode);
    	}
    }
    
    

}
