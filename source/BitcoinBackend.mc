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
	
	hidden var crypto;
	hidden var currency;
	hidden var backend;
	var apikey;
	
	var fetch;
	var fetchFailed;
	
	function initialize(cryptoVal) {
		crypto = cryptoVal;
//		currency = currencyVal;
//		backend = backendVal;
//		apikey = apikeyVal;
	}
	
	function makeRequest(onReceive) {
		if (apiKeyNeeded()) {
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
//    	Ui.requestUpdate();
    }
    
    function getBackendURL() {
    	var url = "https://btc-beckend.azurewebsites.net/price?source=" + backend.toLower() + "&currency=" + currency.toLower();
    	if (backend.equals(BACKENDS[CoinMarketCap])) {
    		url = url + "&apikey=" + apikey;
    	}
		return url;
    }
    
    function apiKeyNeeded() {
    	return backend.equals(BACKENDS[CoinMarketCap]) && apikey.length() < 30;
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
    
    function formatPrice(price) {
    	var remainder = price - price.toNumber();
    	if (remainder != 0) {
    		return price.toString().toFloat().format("%.2f");
    	} else {
    		return price.toString().toFloat().format("%.0f");
    	}
    }
    
    function getPrice(data) {
		return data.get("price");
    }
	
}