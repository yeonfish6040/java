<%@ page import="java.net.InetAddress" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Map</title>
    <meta charset="utf-8">
    <script src="./src/jquery.min.js"></script>
    <script src="./src/jquery.cookie.js"></script>
</head>
<body>
<!-- speed -->
<h3><span id="myInfo" style="position: absolute; top: 10vh; font-size: 1.5em;"></span></h3>
<!-- google login function -->
<span id="loginArea"><span data-client_id='549662034486-gsi7aqabhmdrp5a0b09dtmi6g9hjl8b0.apps.googleusercontent.com' data-callback='onSignIn' id='g_id_onload'></span></span>
<!-- update type or toggle btns -->
<button style="position: absolute; bottom: 15vh;width: 4vh; height: 4vh;" id="updateBtn" onclick="toggleUpdate()">RE</button>
<button style="position: absolute; bottom: 10vh;width: 4vh; height: 4vh;" id="watchBtn" onclick="switchWatch()">DM</button>
<button style="position: absolute; bottom: 5vh;width: 4vh; height: 4vh;" id="trackBtn" onclick="toggleTrack()">⊙</button>
<div id="map" style="position: absolute; top: 0; right: 0; bottom: 0; left: 0;z-index: -1;"></div>
</body>
<script>
    // if already logined, disable login prompt
    if($.cookie("usrInI"))
        document.getElementById("loginArea").innerHTML = ""
</script>
<script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAqOsjFu-Up_Q5VAvMJmzCGFPHiLFA3AzI&callback=initMap"></script>
<script src='https://accounts.google.com/gsi/client' async defer ></script>
<script>
    // define global variables
    var map
    var curPosMk
    var circle
    var watcher
    var speeds
    var heading
    var myIW
    var updateOtherI
    var curPos
    var accAl = 0
    var radius = 0
    var interval = null
    var watching = false
    var track = false
    var isChanging = false
    var watch = true
    var markers = []
    var iWindows = []
    var usrInfo = []

    // init application
    function init() {

        // add eventlistener which detect divice heading change
        if (checkMobile() == "ios") {
            window.addEventListener('deviceorientation', manageCompass)
        } else if (checkMobile() == "android") {
            window.addEventListener("deviceorientationabsolute", manageCompass, true);
        }

        // get first position
        navigator.geolocation.getCurrentPosition((pos) => {
            crd = pos.coords;
            lat = crd.latitude
            lon = crd.longitude

            // define map
            map = new google.maps.Map(document.getElementById("map"), {
                zoom: 18,
                center: {lat: lat, lng: lon},
            });

            // set marker img
            const svgMarker = {
                path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW,
                fillOpacity: 0.6,
                strokeWeight: 0,
                rotation: heading,
                scale: 5,
                fillColor: "red",
            };

            // define main marker
            curPosMk = new google.maps.Marker({
                position: {lat: lat, lng: lon},
                icon: svgMarker,
                map: map,
                disableAutoPan: true
            });

            // define accuracy range circle (animated) function circleChange
            circle = new google.maps.Circle({
                strokeColor: "#0000FF",
                strokeOpacity: 0.8,
                strokeWeight: 2,
                fillOpacity: 0,
                map,
                center: {lat: lat, lng: lon},
                radius: 0,
                disableAutoPan: true,
            });

            // used to debugging... (I don't want to delete this)
            // console.log($.cookie("usrInI"));

            // init user's info window function initMyIW
            if($.cookie("usrInI")) {
                initMyIW()
            }
        }, error, {timeout: 10000, enableHighAccuracy: true})
        // start updating
        toggleUpdate();
        // start animating accuracy circle
        setInterval(() => circleChange(), 5000);
    }

    // toggle updating pos. including function updateOther and updateMy
    function toggleUpdate() {
        if(watching) {
            // set watch status
            watching = false
            // if it's intervaling, clearIt
            if (updateOtherI) {
                clearInterval(updateOtherI)
            }
            // stop watching moving
            if (watch) {
                navigator.geolocation.clearWatch(watcher)
            }else{
                // if it's intervaling, clear it
                clearInterval(watcher)
            }
            // set btn disabled
            document.getElementById("updateBtn").style.color = "black"
        }else {
            // set watch status
            watching = true
            // set interval for update other people's position and upload my status function updateOther
            updateOtherI = setInterval(updateOther, 500)
            if (watch) {
                // starting watch moving
                watcher = navigator.geolocation.watchPosition(updateMy, error, {enableHighAccuracy: true})
            }else{
                // set interval getting cur position
                watcher = setInterval(() => navigator.geolocation.getCurrentPosition(updateMy, error, {enableHighAccuracy: true}), 500);
            }
            // set btn enabled
            document.getElementById("updateBtn").style.color = "skyblue"
        }
    }

    // swich updating mode. I(nterval)U(pdating) and D(etect)M(oving)
    function switchWatch() {
        // stop updating~
        if(watching) {
            toggleUpdate()
        }
        if (watch) {
            // set mode
            watch = false
            // change btn showing
            document.getElementById("watchBtn").innerHTML = "IU"
        }else {
            // set mode
            watch = true
            // change btn showing
            document.getElementById("watchBtn").innerHTML = "DM"
        }
        // restart updating
        toggleUpdate()
    }

    // toggle auto pan to marker
    function toggleTrack() {
        if (track) {
            // set mode
            track = false
            // set btn disabled
            document.getElementById("trackBtn").style.color = "black"
        }else {
            // set mode
            track = true
            // set btn enabled
            document.getElementById("trackBtn").style.color = "skyblue"
        }
    }

    // update other user's position and upload my status
    function updateOther() {
        // check user logined
        if($.cookie("usrInI")) {
            // get param 'group'
            var group = "<%=request.getParameter("group")%>"
            // if group isn't null
            if (group != "null") {
                // get user info array from cookie
                var usrInfo = $.cookie("usrInI").split("|")
                // start ajax
                var rq = new XMLHttpRequest();
                // send name, id, location, heading, speed, group
                rq.open("GET", "./mapUpdate?id="+usrInfo[2]+"&group="+group+"&name="+usrInfo[0]+"&location="+lat+"^|^"+lon+"&heading="+heading+"&speed="+speeds);
                // send
                rq.send()
                // on ajax action finished
                rq.onload = () => {
                    // debug only~~
                    // console.log(rq.responseText)

                    // parsing json string
                    result = JSON.parse(rq.responseText)

                    // delete old marker
                    markers.forEach((e) => {
                        e.setMap(null)
                    })

                    // make new marker
                    result.forEach((e) => {
                        // simplize (?)
                        pos = {lat: parseFloat(e['location'].split("^|^")[0]), lng: parseFloat(e['location'].split("^|^")[1])}

                        // set marker img. filled with blue. my marker is filled with red
                        const svgMarker = {
                            path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW,
                            fillOpacity: 0.6,
                            strokeWeight: 0,
                            rotation: parseInt(e['heading']),
                            scale: 5,
                            fillColor: "blue",
                        };

                        // set marker
                        usrMk = new google.maps.Marker({
                            position: pos,
                            map: map,
                            icon: svgMarker,
                            shouldFocus: false,
                            disableAutoPan: true,
                        });

                        // add marker to array
                        markers.push(usrMk)

                        // init info window
                        usrIW = new google.maps.InfoWindow({
                            content: e['name']+" | "+e['speed']+"km/h",
                            disableAutoPan: true,
                        });

                        // open info window. for marker
                        usrIW.open({
                            anchor: usrMk,
                            map,
                            shouldFocus: false,
                        });
                    })
                }
            }
        }
    }

    // update my status. ex) marker, speed, info window and heading
    function updateMy(pos) {
        // simplize 2222
        crd = pos.coords
        lat = crd.latitude
        lon = crd.longitude
        acc = crd.accuracy
        speed = crd.speed
        curPos = {lat: lat, lng: lon}
        // move marker to cur pos
        curPosMk.setPosition(curPos)
        // rotating marker...
        var icon = curPosMk.getIcon();
        icon.rotation = heading;
        curPosMk.setIcon(icon)
        // move accuracy circle to cur pos
        circle.setCenter(curPos)
        // update global acc variable for accuracy circle
        accAl = acc

        // update my info window
        content = getSpeed(pos)+" km/h";
        if ($.cookie("usrInI")) {
            myIW.setContent($.cookie('usrInI').split("|")[0]+" | "+speeds+" km/h")
        }
    }

    // accuracy circle animating
    function circleChange() {
        // if accuracy circle is animating now, aborting..
        if (isChanging) {
            return
        }
        isChanging = true
        var circleInterval;
        var nowAcc = accAl
        if(nowAcc <= 1) return
        var splitedAcc = nowAcc/10
        function less() {
            circle.setRadius(0)
            circleInterval = setInterval(() => {
                radius -= splitedAcc
                if(radius <= 0) {clearInterval(circleInterval);}
                circle.setRadius(radius)
            }, 100);
        }
        circleInterval = setInterval(() => {
            radius += splitedAcc
            if(radius >= nowAcc) {clearInterval(circleInterval);less()}
            circle.setRadius(radius)
        }, 100);
        isChanging = false
    }

    function onSignIn(res) {
        rq = new XMLHttpRequest();
        rq.open("GET", "https://lyj.kr:6040/?cre="+res.credential+"&cid="+res.clientId)
        rq.send()
        rq.onload = () => {
            re = JSON.parse(rq.responseText)
            $.cookie('usrInI', (re['name']+"|"+re['picture']+"|"+re['sub']+"|"+re['email_verified']), { expires: 7 });
            initMyIW()
        }

    }

    function initMyIW() {
        var info = $.cookie('usrInI').split("|");
        myIW= new google.maps.InfoWindow({
            content: info[0]+" | "+speeds+" km/h",
            disableAutoPan: true
        });
        myIW.open({
            anchor: curPosMk,
            map,
            shouldFocus: false,
        });
    }

    function manageCompass(event) {
        if (event.webkitCompassHeading) {
            absoluteHeading = event.webkitCompassHeading + 180;
        } else {
            absoluteHeading = 360 - event.alpha;
        }
        heading = absoluteHeading
    }

    function calculateSpeed(t1, lat1, lon1, t2, lat2, lon2) {
        var R = 6371; // Radius of the earth in km
        var dLat = deg2rad(lat2-lat1);  // deg2rad below
        var dLon = deg2rad(lon2-lon1);
        var a =
            Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
            Math.sin(dLon/2) * Math.sin(dLon/2)
        ;
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        var d = R * c; // Distance in km
        return ((d/((t2-t1)/1000))*60*60).toFixed(2);
    }

    function deg2rad(deg) {
        return deg * (Math.PI/180)
    }

    function getSpeed(position1) {
        var t1 = Date.now();
        navigator.geolocation.getCurrentPosition((position2) => {
            var speedTemp = calculateSpeed(t1, position1.coords.latitude, position1.coords.longitude, Date.now(), position2.coords.latitude, position2.coords.longitude);
            setSpeed(speedTemp)
        }, error, {enableHighAccuracy: true})
        return speeds
    }

    function setSpeed(speed) {
        speeds = speed;
    }

    function error(e) {
        console.log(e);
    }

    function checkMobile(){
        var varUA = navigator.userAgent.toLowerCase();
        if ( varUA.indexOf('android') > -1) {
            return "android";
        } else if ( varUA.indexOf("iphone") > -1||varUA.indexOf("ipad") > -1||varUA.indexOf("ipod") > -1 ) {
            return "ios";
        } else {
            return "other";
        }

    }


    window.initMap = init
</script>
</html>
