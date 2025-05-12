using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.Application.Storage as Stor;
using Toybox.Time;

class BitcoinView extends Ui.View {

	var bitCoinView;
	var currencyView;
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
    		:text => cryptoBackend.price,
    		:color => Graphics.COLOR_WHITE,
    		:font => getPriceFont(dc),
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_CENTER
    	});
    	
    	fetchingView = new Ui.Text({
    		:text => Rez.Strings.loading,
    		:color => Graphics.COLOR_WHITE,
    		:font => Graphics.FONT_LARGE,
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_CENTER
    	});
    	
    	failedView = new Ui.Text({
    		:text => Rez.Strings.loadfail,
    		:color => Graphics.COLOR_WHITE,
    		:font => Graphics.FONT_LARGE,
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_CENTER
    	});
    	
    	currencyView = new Ui.Text({
    		:text => cryptoBackend.getCurrency(),
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
    	if (cryptoBackend.cacheExpired()) {
    		System.println("Cache timeout, make request.");
    		makeRequest();
    	} else {
    		System.println("Cache hit, no request.");
    		return;
    	}
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
		
		currencyView.setText(cryptoBackend.getCurrency());
		currencyView.draw(dc);
        
        if (cryptoBackend.fetching) {
        	fetchingView.draw(dc);
        } else if (cryptoBackend.fetchFailed) {
         	System.println("Failed");
        	failedView.draw(dc);
        } else {
        	System.println("Price: " + cryptoBackend.price);
        	bitCoinView.setText(cryptoBackend.price);
        	bitCoinView.setFont(getPriceFont(dc));
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
    	Ui.requestUpdate();
    }
    
    function onReceive() {
    	Ui.requestUpdate();
    }
    
    // Different font sizes work on different sized devices
    // Check the screen size with different fonts to ensure we have optimal size
    function getPriceFont(dc) {
   		var screenWidth = dc.getWidth();
		var mediumWidth = dc.getTextWidthInPixels(cryptoBackend.price, Graphics.FONT_NUMBER_MEDIUM);
    	var hotWidth = dc.getTextWidthInPixels(cryptoBackend.price, Graphics.FONT_NUMBER_HOT);
    	var thaiHotWidth = dc.getTextWidthInPixels(cryptoBackend.price, Graphics.FONT_NUMBER_THAI_HOT);
    	if (thaiHotWidth <= screenWidth) {
    		return Graphics.FONT_NUMBER_THAI_HOT;
    	} else if (hotWidth <= screenWidth) {
    		return Graphics.FONT_NUMBER_HOT;
    	} else if (mediumWidth <= screenWidth) {
			return Graphics.FONT_NUMBER_MEDIUM;
		}
    	return Graphics.FONT_NUMBER_MILD;
    }
}
