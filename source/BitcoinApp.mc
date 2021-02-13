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
    	
    	cryptoBackend = new BitcoinBackend("BTC");
    	
		getCurrencyProperty();
		getBackendProperty();
		getAPIKeyProperty();
    }
    
    function onSettingsChanged() {
    	getCurrencyProperty();
		getBackendProperty();
		getAPIKeyProperty();
		if (isGlance) {
			glanceView.makeRequest();
		} else {
			if (cryptoBackend.apiKeyNeeded()) {
				mView = new APIKeyView();
				WatchUi.switchToView(mView, null, WatchUi.SLIDE_IMMEDIATE);
			} else {
				mView = new BitcoinView(cryptoBackend);
	        	mDelegate = new BitcoinDelegate(mView);
	        	WatchUi.switchToView(mView, mDelegate, WatchUi.SLIDE_IMMEDIATE);
			}
		}
		
    }
    
    function getCurrencyProperty() {
    	var currencyNum = AppBase.getProperty("currency");
    	currency = cryptoBackend.CURRENCIES[currencyNum];
    	cryptoBackend.setCurrency(currency);
    	System.println(cryptoBackend.getCurrency());
    }
    
    function getBackendProperty() {
    	var backendNum = AppBase.getProperty("backend");
    	backend = cryptoBackend.BACKENDS[backendNum];
    	cryptoBackend.setBackend(backend);
    	System.println(cryptoBackend.getBackend());
    }
    
    function getAPIKeyProperty() {
    	apikey = AppBase.getProperty("apikey");
    	cryptoBackend.apikey = apikey;
    	System.println(cryptoBackend.apikey);
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {

    	if (cryptoBackend.apiKeyNeeded()) {
    		mView = new APIKeyView();
    		return [ mView ];
        } else {
        	mView = new BitcoinView(cryptoBackend);
        	mDelegate = new BitcoinDelegate(mView);
        	return [ mView, mDelegate ];
        }
        
    }
	
(:glance)
	function getGlanceView() {
		isGlance = true;
		glanceView = new BitcoinGlanceView(cryptoBackend);
		return [ glanceView ];
	}

}