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
<h3><span id="myInfo" style="position: absolute; top: 10vh; font-size: 1.5em;"></span></h3>
<span id="loginArea"><span data-client_id='549662034486-gsi7aqabhmdrp5a0b09dtmi6g9hjl8b0.apps.googleusercontent.com' data-callback='onSignIn' id='g_id_onload'></span></span>
<button style="position: absolute; bottom: 15vh;width: 4vh; height: 4vh;" id="updateBtn" onclick="toggleUpdate()">RE</button>
<button style="position: absolute; bottom: 10vh;width: 4vh; height: 4vh;" id="watchBtn" onclick="switchWatch()">DM</button>
<button style="position: absolute; bottom: 5vh;width: 4vh; height: 4vh;" id="trackBtn" onclick="toggleTrack()">⊙</button>
<div id="map" style="position: absolute; top: 0; right: 0; bottom: 0; left: 0;z-index: -1;"></div>
</body>
<script>
    if($.cookie("usrInI"))
        document.getElementById("loginArea").innerHTML = ""
</script>
<script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAqOsjFu-Up_Q5VAvMJmzCGFPHiLFA3AzI&callback=initMap"></script>
<script src='https://accounts.google.com/gsi/client' async defer ></script>
<script>
    interval = null
    var map
    var curPosMk
    var circle
    var watcher
    var speeds
    var heading
    var myIW
    var updateOtherI
    var accAl = 0
    var radius = 0
    var watching = false
    var track = false
    var isChanging = false
    var watch = true
    var markers = []
    var iWindows = []
    var usrInfo = []

    if ($.cookie("usrInI")) {
        $('#loginBtn').hide();
    }

    function init() {
        if (checkMobile() == "ios") {
            window.addEventListener('deviceorientation', manageCompass)
        } else if (checkMobile() == "android") {
            window.addEventListener("deviceorientationabsolute", manageCompass, true);
        }

        navigator.geolocation.getCurrentPosition((pos) => {
            crd = pos.coords;
            lat = crd.latitude
            lon = crd.longitude

            map = new google.maps.Map(document.getElementById("map"), {
                zoom: 18,
                center: {lat: lat, lng: lon},
            });
            const svgMarker = {
                path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW,
                fillOpacity: 0.6,
                strokeWeight: 0,
                rotation: heading,
                scale: 5,
                fillColor: "red",
            };
            curPosMk = new google.maps.Marker({
                position: {lat: lat, lng: lon},
                icon: svgMarker,
                map: map,
                disableAutoPan: true
            });
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
            console.log($.cookie("usrInI"));

            if($.cookie("usrInI")) {
                initMyIW({lat: lat, lng: lon})
            }
        }, error, {timeout: 10000, enableHighAccuracy: true})
        toggleUpdate();
        setInterval(() => circleChange(), 5000);
    }
    function toggleUpdate() {
        if(watching) {
            watching = false
            if (updateOtherI) {
                clearInterval(updateOtherI)
            }
            if (watch) {
                navigator.geolocation.clearWatch(watcher)
            }else{
                clearInterval(watcher)
            }
            document.getElementById("updateBtn").style.color = "black"
        }else {
            watching = true
            updateOtherI = setInterval(updateOther, 500)
            if (watch) {
                watcher = navigator.geolocation.watchPosition(update, error, {enableHighAccuracy: true})
            }else{
                watcher = setInterval(() => navigator.geolocation.getCurrentPosition(update, error, {enableHighAccuracy: true}), 500);
            }
            document.getElementById("updateBtn").style.color = "skyblue"
        }
    }

    function switchWatch() {
        if(watching) {
            toggleUpdate()
        }
        if (watch) {
            watch = false
            document.getElementById("watchBtn").innerHTML = "IU"
        }else {
            watch = true
            document.getElementById("watchBtn").innerHTML = "DM"
        }
        toggleUpdate()
    }

    function toggleTrack() {
        if (track) {
            track = false
            document.getElementById("trackBtn").style.color = "black"
        }else {
            track = true
            document.getElementById("trackBtn").style.color = "skyblue"
        }
    }

    function updateOther() {
        if($.cookie("usrInI")) {
            var group = "<%=request.getParameter("group")%>"
            if (group != "null") {
                var usrInfo = $.cookie("usrInI").split("|")
                var rq = new XMLHttpRequest();
                rq.open("GET", "./mapUpdate?id="+usrInfo[2]+"&group="+group+"&name="+usrInfo[0]+"&location="+lat+"^|^"+lon+"&heading="+heading+"&speed="+speeds);
                rq.send()
                rq.onload = () => {
                    // console.log(rq.responseText)
                    result = JSON.parse(rq.responseText)
                    markers.forEach((e) => {
                        e.setMap(null)
                    })
                    result.forEach((e) => {
                        pos = {lat: parseFloat(e['location'].split("^|^")[0]), lng: parseFloat(e['location'].split("^|^")[1])}
                        const svgMarker = {
                            path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW,
                            fillOpacity: 0.6,
                            strokeWeight: 0,
                            rotation: parseInt(e['heading']),
                            scale: 5,
                            fillColor: "blue",
                        };
                        usrMk = new google.maps.Marker({
                            position: pos,
                            map: map,
                            icon: svgMarker,
                            shouldFocus: false,
                            disableAutoPan: true,
                        });
                        markers.push(usrMk)

                        usrIW = new google.maps.InfoWindow({
                            content: e['name']+" | "+e['speed']+"km/h",
                            disableAutoPan: true,
                        });
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

    function update(pos) {
        crd = pos.coords
        lat = crd.latitude
        lon = crd.longitude
        acc = crd.accuracy
        speed = crd.speed
        curPosMk.setPosition({lat: lat, lng: lon})
        var icon = curPosMk.getIcon();
        icon.rotation = heading;
        curPosMk.setIcon(icon);
        circle.setCenter({lat: lat, lng: lon})
        accAl = acc
        content = getSpeed(pos)+" km/h";
        $('#myInfo').html(content)
        if (track) {
            map.panTo({lat: lat, lng: lon});
        }
        if ($.cookie("usrInI")) {
            myIW.setContent($.cookie('usrInI').split("|")[0]+" | "+speeds+" km/h")
        }
    }

    function circleChange() {
        if (isChanging) {
            return
        }
        isChanging = true
        var circleInterval;
        var nowAcc = accAl*1
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

    function initMyIW(pos) {
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
