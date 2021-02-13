using Toybox.Communications as Comm;
using Toybox.Application.Storage as Stor;

(:background)
class BitcoinBackend {
	const CACHETIME = 10;
	const CACHEVALUEKEY = "price";
	const PRICECACHEVALUEKEY = "price_cache_time";
	
	enum {
		CoinGecko,
		CoinMarketCap,
		Coinbase,
		Bitstamp,
		Kraken
	}
	
	enum {
		USD,
		EUR,
		CNY,
		GBP,
		CAD,
		ZAR,
		PLN,
		AUD
	}
	
	const BACKENDS = [
		"CoinGecko",
		"CoinMarketCap",
		"Coinbase",
		"Bitstamp",
		"Kraken"
	];
	
	const CURRENCIES = [
		"USD",
		"EUR",
		"CNY",
		"GBP",
		"CAD",
		"ZAR",
		"PLN",
		"AUD"
	];
	
	const CURRENCYSYMBOLS = {
		"USD" => "$",
		"EUR" => "€",
		"CNY" => "¥",
		"GBP" => "£",
		"CAD" => "$",
		"ZAR" => "R",
		"PLN" => "zł",
		"AUD" => "$"
	};
	

	hidden var currency;
	hidden var backend;
	
	function initialize() {
	}
	
	function makeRequest(onReceive) {
    
    	var cacheTime = Stor.getValue(PRICECACHEVALUEKEY);
    	var nowTime = 0;
    	var timeDiff = 10000;
    	if (cacheTime) {
    		nowTime = Time.now().value();
    		timeDiff = nowTime - cacheTime;
    	}
    	
    	if (timeDiff > CACHETIME) {
    		System.println("Cache timeout, make request.");
    	} else {
    		System.println("Cache hit, no request.");
    		bitCoinPrice = Stor.getValue(CACHEVALUEKEY);
    		return;
    	}
    
    	var url = getBackendURL();
    	System.println(url);
    	var params = {};
    	var options = {
    		:method => Comm.REQUEST_CONTENT_TYPE_JSON,
    		:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
    	};
    	Comm.makeWebRequest(url, params, options, onReceive);
    	fetching = true;
    	fetchFailed = false;
    }
    
    function getBackendURL() {
    	var url = "https://btc-beckend.azurewebsites.net/price?source=" + backend.toLower() + "&currency=" + currency.toLower();
    	if (backend.equals("CoinMarketCap")) {
    		url = url + "&apikey=" + apikey;
    	}
		return url;
    }
    
    function apiKeyNeeded() {
    	return backend.equals("CoinMarketCap") && apiKey.length() < 30;
    }
    
    function getCurrency() {
    	return currency;
    }
    
    function setCurrency(aCurrency) {
    	currency = aCurrency;
    }
    
    function getBackend() {
    	return backend;
    }
    
    function setBackend(aBackend) {
    	backend = aBackend;
    }
    
    function getCurrencySymbol() {
    	return CURRENCYSYMBOLS[currency];
    }
	
}