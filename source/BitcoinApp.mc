using Toybox.Application as App;

class BitcoinApp extends App.AppBase {

	var cryptoBackend;

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
    	
    	cryptoBackend = new BitcoinBackend();
    
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
    	currency = cryptoBackend.CURRENCIES[currencyNum];
    	cryptoBackend.setCurrency(currency);
    }
    
    function getBackendProperty() {
    	var backendNum = AppBase.getProperty("backend");
    	backend = cryptoBackend.BACKENDS[backendNum];
    	cryptoBackend.setBackend(backend);
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
        	mView = new BitcoinView(currency, backend, apikey, cryptoBackend);
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
		glanceView = new BitcoinGlanceView(currency, backend, apikey, cryptoBackend);
		return [ glanceView ];
	}

}