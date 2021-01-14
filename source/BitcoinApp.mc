using Toybox.Application as App;

class BitcoinApp extends App.AppBase {

	hidden var mView;
	hidden var mDelegate;
	hidden var glanceView;
	hidden var apiKeyView;
	var currency;
	var backend;
	var apikey;
	
	var isGlance = false;

    function initialize() {
    
    	AppBase.initialize();
    
		getCurrencyProperty();
		getBackendProperty();
		getAPIKeyProperty();
		
		System.println(currency);
		System.println(backend);
		System.println(apikey);

    }
    
    function onSettingsChanged() {
    	getCurrencyProperty();
		getBackendProperty();
		getAPIKeyProperty();
		if (isGlance) {
			glanceView.setCurrency(currency);
			glanceView.setBackend(backend);
			glanceView.setAPIKey(apikey);
			glanceView.makeRequest();
		} else {
			if (apiKeyNeeded()) {
				mView = new APIKeyView();
				WatchUi.switchToView(mView, null, WatchUi.SLIDE_IMMEDIATE);
			} else {
				mView = new BitcoinView(currency, backend, apikey);
	        	mDelegate = new BitcoinDelegate(mView);
	        	WatchUi.switchToView(mView, mDelegate, WatchUi.SLIDE_IMMEDIATE);
			}
		}
		
    }
    
    function getCurrencyProperty() {
    	var currencyNum = AppBase.getProperty("currency");
    	
    	System.println(currencyNum);
    	
		switch (currencyNum) {
			case 0: {
				currency = "USD";
				break;
			}
			case 1: {
				currency = "EUR";
				break;
			}
			case 2: {
				currency = "CNY";
				break;
			}
			case 3: {
				currency = "GBP";
				break;
			}
			case 4: {
				currency = "CAD";
				break;
			}
			case 5: {
				currency = "ZAR";
				break;
			}
			case 6: {
				currency = "PLN";
				break;
			}
			case 7: {
				currency = "AUD";
				break;
			}
		}
    }
    
    function getBackendProperty() {
    	var backendNum = AppBase.getProperty("backend");
		
		switch (backendNum) {
			case 0: {
				backend = "CoinGecko";
				break;
			}
			case 1: {
				backend = "CoinMarketCap";
				break;
			}
			case 2: {
				backend = "Coinbase";
				break;
			}
			case 3: {
				backend = "Bitstamp";
				break;
			}
			case 4: {
				backend = "Kraken";
				break;
			}
		}
    }
    
    function getAPIKeyProperty() {
    	apikey = AppBase.getProperty("apikey");
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {

    	if (apiKeyNeeded()) {
    		mView = new APIKeyView();
    		return [ mView ];
        } else {
        	mView = new BitcoinView(currency, backend, apikey);
        	mDelegate = new BitcoinDelegate(mView);
        	return [ mView, mDelegate ];
        }
        
    }
    
    function apiKeyNeeded() {
    	return backend.equals("CoinMarketCap") && apikey.length() < 30;
    }
	
(:glance)
	function getGlanceView() {
		isGlance = true;
		glanceView = new BitcoinGlanceView(currency, backend, apikey);
		return [ glanceView ];
	}

}