<%--
  Created by IntelliJ IDEA.
  User: iyeonjun
  Date: 2022/10/14
  Time: 11:28 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>map</title>
    <link rel="stylesheet" href="/css/main.css">
    <script type="text/javascript" src="/js/jquery.min.js"></script>
</head>
<body>
    <div class="container full">
        <div class="animation_down-appear">
            <div class="welcome">환영합니다</div>
            <div class="real"> -The Map-</div>
            <br>
            <div class="description">간편한 위치공유 시스템</div>
        </div>
        <div class="backgroundImg full"></div>
    </div>
</body>
<script>
    function subjectAnimation() {
        $(".animation_down-appear").fadeIn({queue: false, duration: 2000})
        $(".animation_down-appear").animate({
            top: "+=45vh"
        }, 2000, 'swing')
        setTimeout(() => {
            $(".welcome").slideUp(1000)
            $(".real").slideDown(1000)
            setTimeout(() => {
                descriptionAnimation()
            }, 500)
        }, 3000)
    }

    function descriptionAnimation() {
        $(".description").animate({
            width: "100%"
        }, 500, 'swing')
    }

    function backGroundImageAnimation() {
        $(".backgroundImg").fadeIn({queue: false, duration: 2000})
    }

    function init() {
        $(".backgroundImg").hide()
        $(".real").hide()
        $(".animation_down-appear").hide();
        subjectAnimation()
        backGroundImageAnimation()
    }

    init()
</script>
</html>
