using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;

class BitcoinView extends Ui.View {

	var bitCoinView;
	var bitCoinPrice = "Loading...";

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    	bitCoinView = new WatchUi.Text({
    		:text => bitCoinPrice,
    		:color => Graphics.COLOR_WHITE,
    		:font => Graphics.FONT_LARGE,
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_CENTER
    	});
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	makeRequest();
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        System.println("Price: " + bitCoinPrice);
        View.onUpdate(dc);
		bitCoinView.setText(bitCoinPrice);
        bitCoinView.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
   
    function makeRequest() {
    	var url = "https://api.coinbase.com/v2/prices/BTC-USD/spot";
    	var params = {};
    	var options = {
    		:method => Comm.REQUEST_CONTENT_TYPE_JSON,
    		:headers => {},
    		:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
    	};
    	Comm.makeWebRequest(url, params, options, method(:onReceive));
    }
    
    function onReceive(responseCode, data) {
    	System.println(data);
    	if (responseCode == 200) {
    		System.println("Request Successful");
    		bitCoinPrice = "$ " + data.get("data").get("amount");
    	} else {
    		System.println("Response: " + responseCode);
    		bitCoinPrice = "Load Fail";
    	}
    	Ui.requestUpdate();
    }
    
}
