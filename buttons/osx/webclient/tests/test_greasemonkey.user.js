// ==UserScript==
// @name           test_greasemonkey
// @namespace      http://example.com
// @include        *
// ==/UserScript==

//replace @include above with the player domain(s) you are interested in, one per line

var myid="0000";

//just load in the video 
function do_load(id){
  myid = id;
  alert("do load called with id "+id);
}

unsafeWindow.onload = load;  
   
//send back what we are watching once loaded
function load()  
 { 
   do_nowp();
 } 

//pause the video
function do_pause(){
  unsafeWindow.pause();
}

//play the video and tell the enclosing frame what's playing
function do_play(val){
   try{
    unsafeWindow.play();
    setTimeout(do_nowp,2000);//10 secs
   }catch(err){
    alert("error "+err);
   }
}

//send back a nowp command via a post message (interframe communication; nothing to do with strophe)
function do_nowp(){
//alert("nowp called");
alert("nowp "+myid);
  var message = myid;
  unsafeWindow.parent.postMessage(message, "*");//replace * with the domain of 'far'
}

//respond to a post message (interframe communication; nothing to do with strophe)
function receiveMessage(msg) {
    var res= msg.data;
    var a = res.split(",");
    if(res.match("play")){
      do_play();
    }
    if(res.match("load")){
      do_load(a[1]);
    }
    if(res.match("pause")){
      do_pause();
    }
    return true;
}

//to activate the post message
window.addEventListener("message", receiveMessage, false);






