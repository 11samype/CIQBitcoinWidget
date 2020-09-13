using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.Application.Storage as Stor;
using Toybox.Time;

class BitcoinView extends Ui.View {

	var bitCoinView;
	var currencyView;
	var bitCoinPrice = "Loading...";
	var currency;
	var priceValueKey = "price";
	var priceCacheValueKey = "price_cache_time";
	var backend;

    function initialize(currencyVal, backendVal) {
    	View.initialize();
    	currency = currencyVal;
    	
    	backend = backendVal;
    }

    // Load your resources here
    function onLayout(dc) {
    	bitCoinView = new WatchUi.Text({
    		:text => bitCoinPrice,
    		:color => Graphics.COLOR_WHITE,
    		:font => Graphics.FONT_LARGE,
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_CENTER
    	});
    	
    	currencyView = new WatchUi.Text({
    		:text => currency,
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
    	var cacheTime = Stor.getValue(priceCacheValueKey);
    	var nowTime = 0;
    	var timeDiff = 10000;
    	if (cacheTime) {
    		nowTime = Time.now().value();
    		timeDiff = nowTime - cacheTime;
    	}
    	
    	if (timeDiff > 30) {
    		System.println("Cache timeout, make request.");
    		makeRequest();
    	} else {
    		System.println("Cache hit, no request.");
    		bitCoinPrice = Stor.getValue(priceValueKey);
    	}
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        System.println("Price: " + bitCoinPrice);
        View.onUpdate(dc);
        //var bitCoinFloat = bitCoinPrice.toString().toFloat().format("%[.2]");
		bitCoinView.setText(bitCoinPrice);
		currencyView.draw(dc);
        bitCoinView.draw(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
   
    function makeRequest() {
    	var url = getBackendURL();
    	System.println(url);
    	var headerKey = getHeaderKey();
    	var headerValue = getHeaderValue();
    	var params = {};
    	var options = {
    		:method => Comm.REQUEST_CONTENT_TYPE_JSON,
    		:headers => {headerKey => headerValue},
    		:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
    	};
    	Comm.makeWebRequest(url, params, options, method(:onReceive));
    }
    
    function onReceive(responseCode, data) {
    	System.println(data);
    	if (responseCode == 200) {
    		System.println("Request Successful");
    		bitCoinPrice = getPrice(data);
    		bitCoinPrice = bitCoinPrice.toString().toFloat().format("%.2f");
    		
    		Stor.setValue(priceValueKey, bitCoinPrice);
    		Stor.setValue(priceCacheValueKey, Time.now().value());
    		
    	} else {
    		System.println("Response: " + responseCode);
    		bitCoinPrice = "Load Fail";
    	}
    	Ui.requestUpdate();
    }
    
    function getBackendURL() {
    	switch (backend) {
			case "BitcoinAverage": {
				return "https://apiv2.bitcoinaverage.com/indices/global/ticker/short?crypto=BTC&fiat=" + currency;
				break;
			}
			case "CoinMarketCap": {
				return "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=BTC&convert=" + currency;
				break;
			}
			case "Coinbase": {
				return "https://api.coinbase.com/v2/prices/BTC-" + currency + "/spot";
				break;
			}
			case "Bitstamp": {
				var currencyPair = "BTC" + currency;
				return "https://www.bitstamp.net/api/v2/ticker/" + currencyPair.toLower();
				break;
			}
			case "Kraken": {
				return "https://api.kraken.com/0/public/Ticker?pair=XBT" + currency;
				break;
			}
		}
    }
    
    function getHeaderKey() {
    	switch (backend) {
			case "BitcoinAverage": {
				return "x-ba-key";
				break;
			}
			case "CoinMarketCap": {
				return "X-CMC_PRO_API_KEY";
				break;
			}
			case "Coinbase": {
				return "";
				break;
			}
			case "Bitstamp": {
				return "";
				break;
			}
			case "Kraken": {
				return "";
				break;
			}
		}
    }
    
    function getHeaderValue() {
    	switch (backend) {
			case "BitcoinAverage": {
				return "ZDYxMWJkOWIzNmIwNGRjMmFjYzM3ODhhOGQxY2JkZWY";
				break;
			}
			case "CoinMarketCap": {
				return "842053ca-84bd-4d71-9658-9d309edd3b43";
				break;
			}
			case "Coinbase": {
				return "";
				break;
			}
			case "Bitstamp": {
				return "";
				break;
			}
			case "Kraken": {
				return "";
				break;
			}
		}
    }
    
    function getPrice(data) {
    	switch (backend) {
			case "BitcoinAverage": {
				return data.get("BTC" + currency).get("last");
				break;
			}
			case "CoinMarketCap": {
				return data.get("data").get("BTC").get("quote").get(currency).get("price");
				break;
			}
			case "Coinbase": {
				return data.get("data").get("amount");
				break;
			}
			case "Bitstamp": {
				return data.get("last");
				break;
			}
			case "Kraken": {
				return data.get("result").get("XXBTZUSD").get("c")[0];
				break;
			}
		}
    }
    
}
