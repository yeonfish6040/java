<!-- Running on https://lyj.kr/map -->
<%@ page contentType="text/html; charset=UTF-8"
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
    let accAl = 0
    let radius = 0
    let interval = null
    let watching = false
    let track = false
    let isChanging = false
    let watch = true
    let markers = []
    let iWindows = []
    let usrInfo = []

    // init application
    function init() {

        // add eventlistener which detect divice heading change
        if (checkMobile() === "ios") {
            window.addEventListener('deviceorientation', manageCompass)
        } else if (checkMobile() === "android") {
            window.addEventListener("deviceorientationabsolute", manageCompass, true);
        }

        // get first position
        navigator.geolocation.getCurrentPosition((pos) => {
            let crd = pos.coords;
            let lat = crd.latitude
            let lon = crd.longitude

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
            // get param 'group'
            let group = "<%=request.getParameter("group")%>"
            // if group isn't null
            if (group !== "null") {
                // get user info array from cookie
                var usrInfo = $.cookie("usrInI").split("|")
                // start ajax
                var rq = new XMLHttpRequest();
                // send name, id, location, heading, speed, group
                rq.open("GET", "./mapUpdate?id="+usrInfo[2]+"&group="+group+"&name="+usrInfo[0]+"&location="+gLat+"^|^"+gLon+"&heading="+heading+"&speed="+speeds);
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
        let crd = pos.coords
        let lat = crd.latitude
        let lon = crd.longitude
        let acc = crd.accuracy
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

    // on user login
    function onSignIn(res) {
        // start ajax
        rq = new XMLHttpRequest();
        // send token and client id to node js api server. (used to get user info)
        rq.open("GET", "https://lyj.kr:6040/?cre="+res.credential+"&cid="+res.clientId)
        // execute
        rq.send()
        // on finish
        rq.onload = () => {
            // parsing json string
            re = JSON.parse(rq.responseText)
            // set cookie
            $.cookie('usrInI', (re['name']+"|"+re['picture']+"|"+re['sub']+"|"+re['email_verified']), { expires: 7 });
            // init info window function initMyIW
            initMyIW()
        }

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

    // get and set heading
    function manageCompass(event) {
        if (event.webkitCompassHeading) {
            // if ios
            absoluteHeading = event.webkitCompassHeading + 360;
        } else {
            // other
            absoluteHeading = 360 - event.alpha;
        }
        // output
        heading = absoluteHeading
        return heading
    }

    // calculate speed by times and locations
    function calculateSpeed(t1, lat1, lon1, t2, lat2, lon2) {
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
        var d = R * c; // Distance in km
        return ((d/((t2-t1)/1000))*60*60).toFixed(2);
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
