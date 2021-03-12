using Toybox.Communications as Comm;
using Toybox.Application.Storage as Stor;
using Toybox.Time;

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
	
	var fetching = false;
	var fetch;
	var fetchFailed = false;
	
	var price = "";
	
	var myOnReceive;
	
	function initialize(cryptoVal) {
		crypto = cryptoVal;
		price = Stor.getValue(CACHEVALUEKEY);
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
    	
    	Comm.makeWebRequest(url, params, options, method(:onReceive));
    	fetching = true;
    	fetchFailed = false;
    	myOnReceive = onReceive;
    }
    
    function onReceive(responseCode, data) {
    	fetching = false;
    	System.println(data);
    	if (responseCode == 200) {
    		System.println("Request Successful");
    		price = getPrice(data);
    		price = formatPrice(price);
    		
    		Stor.setValue(CACHEVALUEKEY, price);
    		Stor.setValue(PRICECACHEVALUEKEY, Time.now().value());
    		
    		myOnReceive.invoke();
    		
    	} else {
    		System.println("Response: " + responseCode);
    		fetchFailed = true;
    	}
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
	
	// has the cache expired?
	function cacheExpired() {
		var cacheTime = Stor.getValue(PRICECACHEVALUEKEY);
    	var nowTime = 0;
    	var timeDiff = 10000;
    	if (cacheTime) {
    		nowTime = Time.now().value();
    		timeDiff = nowTime - cacheTime;
    	}
    	
    	return timeDiff > CACHETIME;
	}
	
	function getPriceTime() {
		var priceTimeValue = Stor.getValue(PRICECACHEVALUEKEY);
		return Time.Gregorian.info(new Time.Moment(priceTimeValue), Time.FORMAT_SHORT);
	}
	
	function getFormattedPriceTime() {
		var priceTime = getPriceTime();
		return priceTime.hour.format("%2d") + ":" + priceTime.min.format("%02d");
	}

}