using Toybox.Communications as Comm;
using Toybox.Application.Storage as Stor;
using Toybox.Time;

(:background)
class BitcoinBackend {
	const CACHETIME = 10;
	const CACHEVALUEKEY = "price";
	const PRICECACHEVALUEKEY = "price_cache_time";
	const SECONDSINDAY = 86400;
	
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
	
	enum {
		mmddyyyy,
		ddmmyyyy
	}
	
	enum {
		hr12,
		hr24
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
	
	const DATEFORMATS = [
		"mmddyyyy",
		"ddmmyyyy"
	];
	
	const TIMEFORMATS = [
		"12hr",
		"24hr"
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
	hidden var dateformat;
	hidden var timeformat;
	
	var fetching = false;
	var fetch;
	var fetchFailed = false;
	
	var price = "";
	
	var myOnReceive;
	
	function initialize(cryptoVal) {
		crypto = cryptoVal;
		var storedPrice = Stor.getValue(CACHEVALUEKEY);
		if (storedPrice) {
			price = storedPrice;
		}
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
    
    function getDateformat() {
    	return dateformat;
    }
    
    function setDateformat(aDateformat) {
    	dateformat = aDateformat;
    }
    
    function getTimeformat() {
    	return timeformat;
    }
    
    function setTimeformat(aTimeformat) {
    	timeformat = aTimeformat;
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
		var priceMoment = new Time.Moment(Time.now().value());
		if (priceTimeValue) {
			priceMoment = new Time.Moment(priceTimeValue);
		}
		return Time.Gregorian.info(priceMoment, Time.FORMAT_SHORT);
	}
	
	function getFormattedPriceTime() {
		var priceTime = getPriceTime();
		if (timeformat.equals(TIMEFORMATS[hr24])) {
			return priceTime.hour.format("%2d") + ":" + priceTime.min.format("%02d");
		} else {
			var hour = priceTime.hour % 12;
			var formattedHour;
			if (hour < 10) {
				if (hour == 0) {
					hour = 12;
				}
				formattedHour = hour.format("%1d");
			} else {
				if (hour == 0) {
					hour = 12;
				}
				formattedHour = hour.format("%2d");
			}
			var amPM;
			if (priceTime.hour < 12) {
				amPM = "AM";
			} else {
				amPM = "PM";
			}
			return formattedHour + ":" + priceTime.min.format("%02d") + amPM;
		}
	}
	
	function getFormattedPriceDate() {
		var priceTime = getPriceTime();
		var day = priceTime.day;
		var month = priceTime.month;
		var year = priceTime.year;
		
		if (dateformat.equals(DATEFORMATS[ddmmyyyy])) {
			return day.format("%1d") + "/" + month.format("%1d") + "/" + year.format("%4d");
		} else {
			return month.format("%1d") + "/" + day.format("%1d") + "/" + year.format("%4d");
		}
	}
	
	function cacheOlderThanADayOld() {
		var cacheTime = Stor.getValue(PRICECACHEVALUEKEY);
    	var nowTime = 0;
    	var timeDiff = 10000;
    	if (cacheTime) {
    		nowTime = Time.now().value();
    		timeDiff = nowTime - cacheTime;
    	}
    	
    	return timeDiff > SECONDSINDAY;
	}
	
	function getFormattedPriceDateOrTime() {
		if (cacheOlderThanADayOld()) {
			return getFormattedPriceDate();
		} else {
			return getFormattedPriceTime();
		}
	}

}