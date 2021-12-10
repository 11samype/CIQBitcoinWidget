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
var loadingText;
var appNameText;

(:glance)
class BitcoinGlanceView extends Ui.GlanceView {
    function initialize(cryptoBackendVal) {
        GlanceView.initialize();
    	cryptoBackend = cryptoBackendVal;
    	loadingText = WatchUi.loadResource(Rez.Strings.loading);
    	appNameText = WatchUi.loadResource(Rez.Strings.AppName);
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

		var viewHeight = dc.getHeight();
		var line1Start = viewHeight / 6;
		var line2Start = dc.getFontHeight(Graphics.FONT_MEDIUM);
		
		var bitcoinPriceFormatted = loadingText;
		if (cryptoBackend.price.length() > 0) {
			System.println("RECEIVED.");
			bitcoinPriceFormatted = getSymbol() + cryptoBackend.price;
		}
		
		if (dc.getHeight() >= (dc.getFontHeight(Graphics.FONT_MEDIUM) + dc.getFontHeight(Graphics.FONT_GLANCE) * 2)) {
			dc.drawText(0, 0, Graphics.FONT_GLANCE, appNameText.toUpper(), Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(0, dc.getFontHeight(Graphics.FONT_GLANCE), Graphics.FONT_LARGE, bitcoinPriceFormatted, Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(0, dc.getFontHeight(Graphics.FONT_GLANCE) + dc.getFontHeight(Graphics.FONT_MEDIUM), Graphics.FONT_GLANCE, "@" + cryptoBackend.getFormattedPriceDateOrTime(), Graphics.TEXT_JUSTIFY_LEFT);
		} else {
			dc.drawText(0, 0, Graphics.FONT_LARGE, bitcoinPriceFormatted, Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(0, line2Start, Graphics.FONT_GLANCE, "BTC", Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(dc.getTextWidthInPixels("BTC", Graphics.FONT_GLANCE) + 5, line2Start, Graphics.FONT_GLANCE, "@" + cryptoBackend.getFormattedPriceDateOrTime(), Graphics.TEXT_JUSTIFY_LEFT);
		}

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