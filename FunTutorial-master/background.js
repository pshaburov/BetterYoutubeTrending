var config = {
    apiKey: "AIzaSyAyWdgJ_a-yvH2EaDOKhILIuLvqkhtsIKM",
    authDomain: "ytdemo3-bee16.firebaseapp.com",
    databaseURL: "https://ytdemo3-bee16-586d6.firebaseio.com/",
    projectId: "ytdemo3-bee16",
    storageBucket: "ytdemo3-bee16.appspot.com",
    messagingSenderId: "187839479436"
  };
  firebase.initializeApp(config);

var database = firebase.database();
var number = 0;
var user = Math.floor((Math.random() * 1000000) + 1);
var userString = user.toString(8) + "/";

var childData = [];

var youtuberef = firebase.database().ref("Youtube/")
function readNumberOne() {

firebase.database().ref().child("First").on('value', function(snapshot) {
    snapshot.forEach(function(child) {
   		 var revisedVal = child.val().replace("watch?v=", "embed/");
       childData.push(revisedVal);
    	});

    chrome.storage.sync.set({color: childData}, function() {
      console.log('The color is green.');
    });
    chrome.declarativeContent.onPageChanged.removeRules(undefined, function() {
      chrome.declarativeContent.onPageChanged.addRules([{
        conditions: [new chrome.declarativeContent.PageStateMatcher({
          pageUrl: {hostEquals: 'developer.chrome.com'},
        })
        ],
            actions: [new chrome.declarativeContent.ShowPageAction()]
      }]);
    });
	});
}

window.onload = function() {
 	 readNumberOne();
}

 
function writeUserData(link) {
  youtuberef.push({
    link: link,
  });
}

var globalURL = "";
chrome.tabs.onUpdated.addListener( function (tabId, changeInfo, tab) {
  if (changeInfo.status == 'complete') {
	chrome.tabs.query({'active': true, 'lastFocusedWindow': true}, function (tabs) {
	var url = tabs[0].url;
	if (url.includes("www.youtube.com/watch?") && (globalURL != url || globalURL == "")) {
		number = number + 1;
		var urlString = url.toString()
    	writeUserData(urlString);
    	globalURL = url;
    	}
	});
  }
})

