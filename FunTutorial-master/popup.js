
  
  document.addEventListener('DOMContentLoaded', function() {
  document.getElementById("Button").addEventListener("click", handler);
});

  document.addEventListener('DOMContentLoaded', function() {
  document.getElementById("testify").addEventListener("click", loadEverything);
  });
	function loadEverything() {
		let changeColor = document.getElementById('SomeLink');
 		chrome.storage.sync.get('color', function(data) {
  			var length = 20;
  			if (data.color.length - 1 < 20) {
  				length = data.color.length - 1
  			}
  	 	 	for(i = 0; i < length; i++) {
				document.getElementById("parentId").innerHTML += "<iframe src=" + data.color[i] + "></iframe>";
			}
  		});
	}
	
  	function handler() {
 		document.getElementById("myDropdown").classList.toggle("show");
	}

window.onclick = function(event) {
  if (!event.target.matches('.dropbtn')) {
    var dropdowns = document.getElementsByClassName("dropdown-content");
    var i;
    for (i = 0; i < dropdowns.length; i++) {
      var openDropdown = dropdowns[i];
      if (openDropdown.classList.contains('show')) {
        openDropdown.classList.remove('show');
      }
    }
  }
}