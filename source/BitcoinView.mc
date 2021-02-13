using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.Application.Storage as Stor;
using Toybox.Time;

class BitcoinView extends Ui.View {

	var bitCoinView;
	var currencyView;
	var bitCoinPrice = "";
	var currency;
	var priceValueKey = "price";
	var priceCacheValueKey = "price_cache_time";
	var backend;
	var fetching = false;
	var fetchFailed = false;
	var fetchingView;
	var apikey;
	var failedView;
	
	var cryptoBackend;

    function initialize(cryptoBackendVal) {
    	View.initialize();
    	cryptoBackend = cryptoBackendVal;
    }

    // Load your resources here
    function onLayout(dc) {
    	bitCoinView = new Ui.Text({
    		:text => bitCoinPrice,
    		:color => Graphics.COLOR_WHITE,
    		:font => Graphics.FONT_NUMBER_MEDIUM,
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_CENTER
    	});
    	
    	fetchingView = new Ui.Text({
    		:text => "Loading...",
    		:color => Graphics.COLOR_WHITE,
    		:font => Graphics.FONT_LARGE,
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_CENTER
    	});
    	
    	failedView = new Ui.Text({
    		:text => "Load Fail",
    		:color => Graphics.COLOR_WHITE,
    		:font => Graphics.FONT_LARGE,
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_CENTER
    	});
    	
    	currencyView = new Ui.Text({
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
    // TODO: May need to move back to makeRequest() due to cache on the button action
    	var cacheTime = Stor.getValue(cryptoBackend.PRICECACHEVALUEKEY);
    	var nowTime = 0;
    	var timeDiff = 10000;
    	if (cacheTime) {
    		nowTime = Time.now().value();
    		timeDiff = nowTime - cacheTime;
    	}
    	
    	if (timeDiff > cryptoBackend.CACHETIME / 2) {
    		System.println("Cache timeout, make request.");
    		makeRequest();
    	} else {
    		System.println("Cache hit, no request.");
    		bitCoinPrice = Stor.getValue(cryptoBackend.CACHEVALUEKEY);
    		return;
    	}
		
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
		
		currencyView.setText(cryptoBackend.getCurrency());
		currencyView.draw(dc);
        
        if (fetching) {
        	fetchingView.draw(dc);
        } else if (fetchFailed) {
         	System.println("Failed");
        	failedView.draw(dc);
        } else {
        	System.println("Price: " + bitCoinPrice);
        	bitCoinView.setText(bitCoinPrice);
        	bitCoinView.draw(dc);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
   
    function makeRequest() {
    	cryptoBackend.makeRequest(method(:onReceive));
    	fetching = true;
    	fetchFailed = false;
    	Ui.requestUpdate();
    }
    
    function onReceive(responseCode, data) {
    	fetching = false;
    	System.println(data);
    	if (responseCode == 200) {
    		System.println("Request Successful");
    		bitCoinPrice = cryptoBackend.getPrice(data);
    		bitCoinPrice = cryptoBackend.formatPrice(bitCoinPrice);
    		
    		Stor.setValue(priceValueKey, bitCoinPrice);
    		Stor.setValue(priceCacheValueKey, Time.now().value());
    		
    	} else {
    		System.println("Response: " + responseCode);
    		fetchFailed = true;
    	}
    	Ui.requestUpdate();
    }
}
