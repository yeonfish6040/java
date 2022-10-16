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
        <link rel="stylesheet" href="/css/bootstrap.css">
        <script type="text/javascript" src="/js/jquery.min.js"></script>
    </head>
    <body>
        <div class="full">
            <div class="animation_down-appear">
                <div class="welcome">환영합니다</div>
                <div class="real"> -The Map-</div>
                <div class="description">간편한 위치공유 시스템</div>
                <div class="start btn btn-outline-info">시작하기</div>
            </div>
            <div class="backgroundImg full"></div>
        </div>
    </body>
    <script>
        let isStarting = false

        $(".start").on("click", rollback)

        function subjectAnimation() {
            $(".animation_down-appear").fadeIn({queue: false, duration: 2000})
            $(".animation_down-appear").animate({
                top: "+=42vh"
            }, 2000, 'swing')
            setTimeout(() => {
                $(".welcome").slideUp(1000)
                $(".real").slideDown(1000)
                setTimeout(descriptionAnimation, 500)
            }, 3000)
        }

        function descriptionAnimation() {
            $(".description").animate({
                width: "100%"
            }, 500, 'swing')
            setTimeout(startBtnAnimation, 1000)
        }

        function startBtnAnimation() {
            $(".start").fadeIn(500)
        }

        function backGroundImageAnimation() {
            $(".backgroundImg").fadeIn({queue: false, duration: 2000})
        }

        function rollback() {
            if (isStarting)
                return

            isStarting = true
            $(".start").fadeOut(500, () => {
                $(".animation_down-appear").fadeOut({queue: false, duration: 2000})
                $(".animation_down-appear").animate({
                    top: "-=42vh"
                }, 2000, 'swing', () => {
                    location.href="https://accounts.google.com/o/oauth2/auth/oauthchooseaccount?redirect_uri=http%3A%2F%2Flocalhost%2Fmap%2Flogin%2Fdo&response_type=permission%20id_token&scope=email%20profile%20openid&openid.realm&include_granted_scopes=true&client_id=549662034486-52qjnqhdd59otlhjn21s2duae268gjku.apps.googleusercontent.com&fetch_basic_profile=true&gsiwebsdk=2&flowName=GeneralOAuthFlow"
                })
            })
        }

        function init() {
            $(".backgroundImg").hide()
            $(".real").hide()
            $(".animation_down-appear").hide();
            $(".start").hide()
            subjectAnimation()
            backGroundImageAnimation()
        }

        init()
    </script>
    </html>
