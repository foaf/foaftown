$(document).ready(function() {
	var avElement =	document.getElementById('content');
	avElement.load()
	avElement.addEventListener("load", function() { 
		avElement.play(); 
		$(".duration span").html(avElement.duration);
		$(".filename span").html(avElement.src);
	}, true);



	
	$('.play').click(function() {
		avElement.play();
		
	});
	$('.pause').click(function() {
		avElement.pause();
	});
	$('.volumeMax').click(function() {
		avElement.volume=1;
	});
		$('.volumestop').click(function() {
		avElement.volume=0;
	});

	$('.playatTime').click(function() {
		avElement.currentTime= 35;
		avElement.play();
	});			

	$('.goRight').click(function() {
          ix = ix + 1;
          if (ix > ( trailers.length -1) ) { ix = 0;}
	  play(ix);
	  alert("You clicked right");
	});			
});
