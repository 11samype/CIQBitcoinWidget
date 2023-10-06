using Toybox.Application as App;
using Toybox.Lang;

class BitcoinApp extends App.AppBase {

	var cryptoBackend;

	hidden var mView;
	hidden var mDelegate;
	hidden var glanceView;
	hidden var apiKeyView;
	var currency;
	var backend;
	var apikey;
	var dateformat;
	var timeformat;
	
	var isGlance = false;

    function initialize() {
    
    	AppBase.initialize();
    	
    	cryptoBackend = new BitcoinBackend("BTC");
    	
		getCurrencyProperty();
		getBackendProperty();
		getAPIKeyProperty();
		getDateFormatProperty();
		getTimeFormatProperty();
    }
    
    function onSettingsChanged() {
    	getCurrencyProperty();
		getBackendProperty();
		getAPIKeyProperty();
		getDateFormatProperty();
		getTimeFormatProperty();
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
    
	(:typecheck(false))
    function getCurrencyProperty() {
		var currencyNum = Properties.getValue("currency");
    	currency = cryptoBackend.CURRENCIES[currencyNum];
    	cryptoBackend.setCurrency(currency);
    	System.println(cryptoBackend.getCurrency());
    }
    
	(:typecheck(false))
    function getBackendProperty() {
    	var backendNum = Properties.getValue("backend");
    	backend = cryptoBackend.BACKENDS[backendNum];
    	cryptoBackend.setBackend(backend);
    	System.println(cryptoBackend.getBackend());
    }
    
    function getAPIKeyProperty() {
    	apikey = Properties.getValue("apikey");
    	cryptoBackend.apikey = apikey;
    	System.println(cryptoBackend.apikey);
    }
    
	(:typecheck(false))
    function getDateFormatProperty() {
    	var dateformatNum = Properties.getValue("dateformat");
    	dateformat = cryptoBackend.DATEFORMATS[dateformatNum];
    	cryptoBackend.setDateformat(dateformat);
    	System.println(cryptoBackend.getDateformat());
    }
    
	(:typecheck(false))
    function getTimeFormatProperty() {
    	var timeformatNum = Properties.getValue("timeformat");
    	timeformat = cryptoBackend.TIMEFORMATS[timeformatNum];
    	cryptoBackend.setTimeformat(timeformat);
    	System.println(cryptoBackend.getTimeformat());
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