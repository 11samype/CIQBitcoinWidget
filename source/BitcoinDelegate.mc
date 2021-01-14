using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class BitcoinDelegate extends Ui.BehaviorDelegate {
	var relatedView;
	
	function initialize(view) {
		Ui.BehaviorDelegate.initialize();
		relatedView = view;
	}
	
	function onSelect() {
		relatedView.makeRequest();
		return true;
	}

}