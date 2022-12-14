<!-- Running on https://lyj.kr/map -->
<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Map</title>
    <meta charset="utf-8">
    <script src="/js/jquery.min.js"></script>
    <script src="/js/jquery.cookie.js"></script>
    <link rel="stylesheet" href="/css/view.css">
</head>
<body>
<!-- speed -->
<h3><span id="myInfo"></span></h3>
<!-- update type or toggle btns -->
<button id="updateBtn" onclick="toggleUpdate()">RE</button>
<button id="watchBtn" onclick="switchWatch()">DM</button>
<button id="trackBtn" onclick="toggleTrack()">⊙</button>
<div id="map"></div>
</body>
</html>
<script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAqOsjFu-Up_Q5VAvMJmzCGFPHiLFA3AzI&callback=initMap"></script>
<script>
    // define global variables
    let map
    let curPosMk
    let circle
    let watcher
    let speeds
    let heading
    let myIW
    let updateOtherI
    let curPos
    let gLat
    let gLon
    let focus
    let connecterLine
    let accAl = 0
    let radius = 0
    let interval = null
    let watching = false
    let track = false
    let isChanging = false
    let watch = true
    let group = "${group}"
    let markers = []
    let iWindows = []
    let usrInfo = []

    // init application
    function init() {
        // get first position
        navigator.geolocation.getCurrentPosition((pos) => {
            let crd = pos.coords;
            let lat = crd.latitude
            let lon = crd.longitude

            // set heading
            heading = crd.heading

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
                // position: {lat: lat, lng: lon},
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
            // pan to cur location
            map.panTo(curPos)
            // zoom
            setTimeout(() => {
                // zooming...
                map.setZoom(19)
                // re panTo
                map.panTo(curPos)
            }, 1000)
            // set btn enabled
            document.getElementById("trackBtn").style.color = "skyblue"
        }
    }

    // update other user's position and upload my status
    function updateOther() {
        // check user logined
        if($.cookie("usrInI")) {
            // if group isn't null
            if (group !== "null") {
                // get user info array from cookie
                var usrInfo = $.cookie("usrInI").split("|")
                // start ajax
                var rq = new XMLHttpRequest();
                // send name, id, location, heading, speed, group
                rq.open("GET", "./mapUpdate?id="+usrInfo[2]+"&group="+group+"&name="+encodeURIComponent(usrInfo[0])+"&location="+gLat+encodeURIComponent("^|^")+gLon+"&heading="+heading+"&speed="+speeds);
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
                        let pos = {lat: parseFloat(e['location'].split("^|^")[0]), lng: parseFloat(e['location'].split("^|^")[1])}

                        let contentIw = e['name']+" | "+e['speed']+"km/h"

                        // if marker focused, get distence and show it
                        if (focus === e['id']) {
                            // get distence
                            let dist = getDist(gLat, gLon, pos['lat'], pos['lng']);
                            contentIw = e['name']+" | "+e['speed']+"km/h<br>distence: "+dist.toFixed(3)+" km"
                            const myPosToMk = [
                                {lat: gLat, lng: gLon},
                                pos
                            ];
                            if (connecterLine) {
                                connecterLine.setPath(myPosToMk)
                            }else {
                                connecterLine = new google.maps.Polyline({
                                    path: myPosToMk,
                                    geodesic: true,
                                    strokeColor: "#FF0000",
                                    strokeOpacity: 1.0,
                                    strokeWeight: 2,
                                });
                            }
                            connecterLine.setMap(map)
                        }

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
                            content: contentIw,
                            disableAutoPan: true,
                        });

                        // open info window. for marker
                        usrIW.open({
                            anchor: usrMk,
                            map,
                            shouldFocus: false,
                        });

                        // put id into usrMk
                        usrMk.usrId = e['id']
                        usrMk.addListener("click", () => {
                            // when click, set focus to usrId
                            focus = usrMk.usrId
                        })
                    })
                }
            }
        }
    }

    // update my status. ex) marker, speed, info window and heading
    function updateMy(pos) {
        // simplize 2222
        let crd = pos.coords
        let lat = crd.latitude
        let lon = crd.longitude
        let acc = crd.accuracy

        heading = crd.heading

        gLat = lat
        gLon = lon
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
        // set myInfo
        content = getSpeed(pos)+" km/h";
        document.getElementById("myInfo").innerHTML = content
        // update my info window
        if ($.cookie("usrInI")) {
            myIW.setContent($.cookie('usrInI').split("|")[0]+" | "+speeds+" km/h")
        }
        if (track) {
            map.panTo({lat: lat, lng: lon})
        }
    }

    // accuracy circle animating
    function circleChange() {
        // if accuracy circle is animating now, aborting..
        if (isChanging) {
            return
        }
        // set status - running
        isChanging = true
        // define variable
        var circleInterval;
        // get accuracy
        var nowAcc = accAl
        // abort if accuracy is not valid
        if(nowAcc <= 1) return
        // split accuracy
        var splitedAcc = nowAcc/10
        // decreasing animation (after increasing)
        function less() {
            // reset
            circle.setRadius(0)
            // start animation
            circleInterval = setInterval(() => {
                // decrease
                radius -= splitedAcc
                circle.setRadius(radius)
                // if finish, exit
                if(radius <= 0) return clearInterval(circleInterval);
            }, 100);
        }
        // increasing animation
        circleInterval = setInterval(() => {
            // increase
            radius += splitedAcc
            circle.setRadius(radius)
            // if finish, call function less() and exit
            if(radius >= nowAcc) {clearInterval(circleInterval); return less()}
        }, 100);
        // set status - stopped
        isChanging = false
    }

    // set info window for me
    function initMyIW() {
        // get info from cookie
        var info = $.cookie('usrInI').split("|");
        // define info window
        myIW= new google.maps.InfoWindow({
            content: info[0]+" | "+speeds+" km/h",
            disableAutoPan: true
        });
        // open info window
        myIW.open({
            anchor: curPosMk,
            map,
            shouldFocus: false,
        });
    }

    // calculate distence
    function getDist(lat1, lon1, lat2, lon2) {
        // ???
        var R = 6371;
        var dLat = deg2rad(lat2-lat1);
        var dLon = deg2rad(lon2-lon1);
        var a =
            Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
            Math.sin(dLon/2) * Math.sin(dLon/2)
        ;
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return R * c; // Distance in km
    }

    // calculate speed by times and locations
    function calculateSpeed(t1, lat1, lon1, t2, lat2, lon2) {
        return ((getDist(lat1, lon1, lat2, lon2)/((t2-t1)/1000))*60*60).toFixed(2);
    }

    // ???
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

    // set spped to global variable
    function setSpeed(speed) {
        speeds = speed;
    }

    // error handler
    function error(e) {
        console.log(e);
    }

    // check mobile type
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

    // start
    window.initMap = init
</script>
</html>
