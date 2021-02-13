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

var cryptoBackend;

(:glance)
class BitcoinGlanceView extends Ui.GlanceView {
    function initialize(cryptoBackendVal) {
        GlanceView.initialize();
    	cryptoBackend = cryptoBackendVal;
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

		if (bitCoinPrice.equals("") || fetching || cryptoBackend.apiKeyNeeded()) {
			dc.drawText(10, 15, Graphics.FONT_GLANCE_NUMBER, "Bitcoin", Graphics.TEXT_JUSTIFY_LEFT);
		} else {
			dc.drawText(10, 15, Graphics.FONT_GLANCE_NUMBER, getSymbol() + bitCoinPrice, Graphics.TEXT_JUSTIFY_LEFT);
		}
		
    }
    
    function onShow() {
    	var cacheTime = Stor.getValue(cryptoBackend.PRICECACHEVALUEKEY);
    	var nowTime = 0;
    	var timeDiff = 10000;
    	if (cacheTime) {
    		nowTime = Time.now().value();
    		timeDiff = nowTime - cacheTime;
    	}
    	
    	if (timeDiff > cryptoBackend.CACHETIME) {
    		System.println("Cache timeout, make request.");
    		makeRequest();
    	} else {
    		System.println("Cache hit, no request.");
//    		bitCoinPrice = Stor.getValue(priceValueKey);
    	}
    	bitCoinPrice = Stor.getValue(cryptoBackend.CACHEVALUEKEY);
    }
    
    function getSymbol() {
    	return cryptoBackend.getCurrencySymbol();
    }
    
    // NEED TO PULL THES OUT INTO SHARED CODE
    
    function makeRequest() {
    	cryptoBackend.makeRequest(method(:onReceive));
    	fetching = true;
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
    		bitCoinPrice = "Load Fail";
    	}
    	Ui.requestUpdate();
    }
}