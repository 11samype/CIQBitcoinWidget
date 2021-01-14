using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Communications as Comm;
using Toybox.Application.Storage as Stor;
using Toybox.Time;

var bitCoinPrice = "";
var currency;
var backend;
var fetching = false;
var priceValueKey = "price";
var apiKey;
var priceCacheValueKey = "price_cache_time";

(:glance)
class BitcoinGlanceView extends Ui.GlanceView {
    function initialize(currencyVal, backendVal, apiKeyVal) {
        GlanceView.initialize();
        
        currency = currencyVal;
    	backend = backendVal;
    	apiKey = apiKeyVal;
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

		if (bitCoinPrice.equals("")) {
			dc.drawText(10, 15, Graphics.FONT_GLANCE_NUMBER, "Bitcoin", Graphics.TEXT_JUSTIFY_LEFT);
		} else {
			dc.drawText(10, 15, Graphics.FONT_GLANCE_NUMBER, getSymbol() + bitCoinPrice, Graphics.TEXT_JUSTIFY_LEFT);
		}
		
    }
    
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
//    		bitCoinPrice = Stor.getValue(priceValueKey);
    	}
    	bitCoinPrice = Stor.getValue(priceValueKey);
    }
    
    function getSymbol() {
    	switch (currency) {
    		case "USD": {
    			return "$";
    			break;
    		}
    		case "CAD": {
    			return "$";
    			break;
    		}
    		case "EUR": {
    			return "€";
    			break;
    		}
    		case "CNY": {
    			return "¥";
    			break;
    		}
    		case "GBP": {
    			return "£";
    			break;
    		}
    	}
    }
    
    // NEED TO PULL THES OUT INTO SHARED CODE
    
    function makeRequest() {
    	var url = getBackendURL();
    	System.println(url);
    	var params = {};
    	var options = {
    		:method => Comm.REQUEST_CONTENT_TYPE_JSON,
    		:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
    	};
    	Comm.makeWebRequest(url, params, options, method(:onReceive));
    	fetching = true;
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
    		bitCoinPrice = "Load Fail";
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
    		url = url + "&apikey=" + apiKey;
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
    
    function setAPIKey(newAPIKey) {
    	apiKey = newAPIKey;
    }
}