using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class BitcoinDelegate extends Ui.BehaviorDelegate {
	var notify;
	
	function onTap() {
		makeRequest();
		return true;
	}
	
	function makeRequest() {
		notify.invoke("Getting\nPrice");
		
		Comm.makeWebRequest(
			"https://api.coinbase.com/v2/prices/:currency_pair/spot",
			null,
			{
				"Content-Type" => Comm.REQUEST_CONTENT_TYPE_URL_ENCODED
			},
			method(:onReceive)
		);
	}
	
	function initialize(handler) {
		Ui.BehaviorDelegate.initialize();
		notify = handler;
	}
	
	function onReceive(responseCode, data) {
		if (responseCode == 200) {
			notify.invoke(data["args"]);
		} else {
		
		}
	}

}