using Toybox.Application as App;

class BitcoinApp extends App.AppBase {

	hidden var mView;
	var currency;
	var backend;

    function initialize() {
    
    	AppBase.initialize();
    
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
		
		var backendNum = AppBase.getProperty("backend");
		
		switch (backendNum) {
			case 0: {
				backend = "Coinbase";
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
		
		System.println(currency);
		System.println(backend);

    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
    	//mView = new BitcoinView();
        //return [ mView, new BitcoinDelegate(mView.method(:onReceive)) ];
        return [new BitcoinView(currency, backend) ];
    }

}