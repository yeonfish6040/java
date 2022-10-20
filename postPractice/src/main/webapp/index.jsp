<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" href="./css/index.css">
    <title>Post practice</title>
</head>
<body>
    <div class="container">
        <div class="header">
            <span class="name">PostPractice</span>
            <span class="login">
                <form action="./login" method="POST">
                    <input type="text" name="id"><input type="password" name="pw">
                    <input type="submit" value="submit">
                    <input type="hidden" value="index.jsp" name="redirect">
                </form>
            </span>
        </div>
    </div>
</body>
</html>