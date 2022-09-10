<%@ page import="org.apache.tomcat.jdbc.pool.interceptor.SlowQueryReport"%>
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
    var accAl = 0
    var radius = 0
    var watching = false
    var track = false
    var isChanging = false
    var watch = true
    var markers = []
    var iWindows = []
    var usrInfo = []

    function init() {
        $('#loginBtn').hide();
        navigator.geolocation.getCurrentPosition((pos) => {
            crd = pos.coords;
            lat = crd.latitude
            lon = crd.longitude

            map = new google.maps.Map(document.getElementById("map"), {
                zoom: 18,
                center: {lat: lat, lng: lon},
            });
            curPosMk = new google.maps.Marker({
                position: {lat: lat, lng: lon},
                map: map,
            });
            circle = new google.maps.Circle({
                strokeColor: "#0000FF",
                strokeOpacity: 0.8,
                strokeWeight: 2,
                fillOpacity: 0,
                map,
                center: {lat: lat, lng: lon},
                radius: 0,
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
            if (watch) {
                navigator.geolocation.clearWatch(watcher)
            }else{
                clearInterval(watcher)
            }
            document.getElementById("updateBtn").style.color = "black"
        }else {
            watching = true
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

    function update(pos) {
        crd = pos.coords
        lat = crd.latitude
        lon = crd.longitude
        acc = crd.accuracy
        speed = crd.speed
        curPosMk.setPosition({lat: lat, lng: lon})
        circle.setCenter({lat: lat, lng: lon})
        accAl = acc
        if(isMobileDevice()) {
            content = speed.toFixed(2)+" km/h<br>± "+acc.toFixed(2)+"m";
            $('#myInfo').html(content)
        }
        if (track) {
            map.panTo({lat: lat, lng: lon});
        }
        if($.cookie("usrInI")){
            var group = "<%=request.getParameter("group")%>"
            if (group != "null") {
                var usrInfo = $.cookie("usrInI").split("|")
                var rq = new XMLHttpRequest();
                rq.open("GET", "./mapUpdate?id="+usrInfo[2]+"&group="+group+"&name="+usrInfo[0]+"&location="+lat+"^|^"+lon);
                rq.send()
                rq.onload = () => {
                    // console.log(rq.responseText)
                    result = JSON.parse(rq.responseText)
                    markers.forEach((e) => {
                        e.setMap(null)
                    })
                    result.forEach((e) => {
                        usrMk = new google.maps.Marker({
                            position: {lat: e['location'].split("^|^")[0], lng: e['location'].split("^|^")[1]},
                            map: map,
                        });
                        markers.push(usrMk)

                        iWindows.forEach((e) => {
                            e.open(null)
                        })
                        usrIW = new google.maps.InfoWindow({
                            content: info[0]
                        });
                        usrIW.open({
                            anchor: usrMk,
                            map,
                            shouldFocus: false,
                        });
                        iWindows.push(usrIW)
                    })
                }
            }
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
        const infowindow = new google.maps.InfoWindow({
            content: info[0]
        });
        infowindow.open({
            anchor: curPosMk,
            map,
            shouldFocus: false,
        });
    }

    function error(e) {
        console.log(e);
    }

    function isMobileDevice() {
        var check = false;
        (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))) check = true;})(navigator.userAgent||navigator.vendor||window.opera);
        return check;
    }

    window.initMap = init
</script>
</html>