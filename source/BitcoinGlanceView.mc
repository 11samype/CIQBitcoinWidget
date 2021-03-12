using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Communications as Comm;
using Toybox.Application.Storage as Stor;
using Toybox.Time;

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

//		if (cryptoBackend.price.equals("") || cryptoBackend.fetching || cryptoBackend.apiKeyNeeded()) {
//			dc.drawText(10, 15, Graphics.FONT_GLANCE_NUMBER, "Bitcoin", Graphics.TEXT_JUSTIFY_LEFT);
//		} else {
			dc.drawText(0, 15, Graphics.FONT_GLANCE_NUMBER, getSymbol() + cryptoBackend.price + " @" + cryptoBackend.getFormattedPriceTime(), Graphics.TEXT_JUSTIFY_LEFT);
//		}
    }
    
    function onShow() {
    	if (cryptoBackend.cacheExpired()) {
    		System.println("Cache timeout, make request.");
    		makeRequest();
    	} else {
    		System.println("Cache hit, no request.");
    	}
    }
    
    function getSymbol() {
    	return cryptoBackend.getCurrencySymbol();
    }
    
    function makeRequest() {
    	cryptoBackend.makeRequest(method(:onReceive));
    }
    
    function onReceive() {
    	Ui.requestUpdate();
    }
}