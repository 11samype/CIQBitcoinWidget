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
	
	var bitcoinBackend;

    function initialize(currencyVal, backendVal, apikeyVal, cryptoBackendVal) {
    	View.initialize();
    	currency = currencyVal;
    	backend = backendVal;
    	apikey = apikeyVal;
    	bitcoinBackend = cryptoBackendVal;
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
		makeRequest();
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
		
		currencyView.setText(currency);
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
    
    	var cacheTime = Stor.getValue(priceCacheValueKey);
    	var nowTime = 0;
    	var timeDiff = 10000;
    	if (cacheTime) {
    		nowTime = Time.now().value();
    		timeDiff = nowTime - cacheTime;
    	}
    	
    	if (timeDiff > 5) {
    		System.println("Cache timeout, make request.");
    	} else {
    		System.println("Cache hit, no request.");
    		bitCoinPrice = Stor.getValue(priceValueKey);
    		return;
    	}
    
    	var url = getBackendURL();
    	System.println(url);
    	var params = {};
    	var options = {
    		:method => Comm.REQUEST_CONTENT_TYPE_JSON,
    		:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
    	};
    	Comm.makeWebRequest(url, params, options, method(:onReceive));
    	fetching = true;
    	fetchFailed = false;
    	Ui.requestUpdate();
    }
    
    function onReceive(responseCode, data) {
    	fetching = false;
    	System.println(data);
    	if (responseCode == 200) {
    		System.println("Request Successful");
    		bitCoinPrice = getPrice(data);
    		bitCoinPrice = formatPrice(bitCoinPrice);
    		
    		Stor.setValue(priceValueKey, bitCoinPrice);
    		Stor.setValue(priceCacheValueKey, Time.now().value());
    		
    	} else {
    		System.println("Response: " + responseCode);
    		fetchFailed = true;
    	}
    	Ui.requestUpdate();
    }
    
    function formatPrice(price) {
    	var remainder = price - price.toNumber();
    	if (remainder != 0) {
    		return price.toString().toFloat().format("%.2f");
    	} else {
    		return price.toString().toFloat().format("%.0f");
    	}
    }
    
    function getBackendURL() {
    	var url = "https://btc-beckend.azurewebsites.net/price?source=" + backend.toLower() + "&currency=" + currency.toLower();
    	if (backend.equals("CoinMarketCap")) {
    		url = url + "&apikey=" + apikey;
    	}
		return url;
    }
    
    function getPrice(data) {
		return data.get("price");
    }
    
    function setCurrency(newCurrency) {
    	currency = newCurrency;
    }
    
    function setBackend(newBackend) {
    	backend = newBackend;
    }
    
}
