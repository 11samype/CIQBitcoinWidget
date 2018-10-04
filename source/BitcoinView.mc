using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.Application.Storage as Stor;
using Toybox.Time;

class BitcoinView extends Ui.View {

	var bitCoinView;
	var currencyView;
	var bitCoinPrice = "Loading...";
	var currency;
	var priceValueKey = "price";
	var priceCacheValueKey = "price_cache_time";

    function initialize(currencyVal) {
    	View.initialize();
    	currency = currencyVal;
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
    	
    	currencyView = new WatchUi.Text({
    		:text => currency,
    		:color => Graphics.COLOR_WHITE,
    		:font => Graphics.FONT_LARGE,
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_BOTTOM
    	});
    	
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	var cacheTime = Stor.getValue(priceCacheValueKey);
    	var nowTime = 0;
    	var timeDiff = 10000;
    	if (cacheTime) {
    		nowTime = Time.now().value();
    		timeDiff = nowTime - cacheTime;
    	}
    	
    	if (timeDiff > 10) {
    		System.println("Cache timeout, make request.");
    		makeRequest();
    	} else {
    		System.println("Cache hit, no request.");
    		bitCoinPrice = Stor.getValue(priceValueKey);
    	}
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        System.println("Price: " + bitCoinPrice);
        View.onUpdate(dc);
        //var bitCoinFloat = bitCoinPrice.toString().toFloat().format("%[.2]");
		bitCoinView.setText(bitCoinPrice);
		currencyView.draw(dc);
        bitCoinView.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
   
    function makeRequest() {
    	var url = "https://btcbackend.azurewebsites.net/price?currency=" + currency;
    	System.println(url);
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
    		bitCoinPrice = data.get("price");
    		bitCoinPrice = bitCoinPrice.toString().toFloat().format("%.2f");
    		
    		Stor.setValue(priceValueKey, bitCoinPrice);
    		Stor.setValue(priceCacheValueKey, Time.now().value());
    		
    	} else {
    		System.println("Response: " + responseCode);
    		bitCoinPrice = "Load Fail";
    	}
    	Ui.requestUpdate();
    }
    
}
