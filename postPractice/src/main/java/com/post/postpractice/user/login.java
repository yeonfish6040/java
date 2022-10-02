package com.post.postpractice.user;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;

import com.post.postpractice.util.sql.*;

@WebServlet("/login")
public class login extends HttpServlet {

    sqlQuery sq = new sqlQuery("lyj.kr", "3306", "java", "java", "java");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        sq.cStatus();
        String id = request.getParameter("id");
        String pw = request.getParameter("pw");
        sqlResults results = null;
        try {
            results = sq.query("select * from post_users where `user_id` like '"+id+"'");
            if (results.isEmpty()) {
                response.sendError(HttpServletResponse.SC_NO_CONTENT);
                return;
            }
            String[][] result1 = results.get();
            String[] result2 = result1[1];
            String DBIdx = result2[Arrays.asList(result1[0]).indexOf("idx")];
            String DBId = result2[Arrays.asList(result1[0]).indexOf("user_id")];
            String DBPw = result2[Arrays.asList(result1[0]).indexOf("user_pw")];
            String DBPer = result2[Arrays.asList(result1[0]).indexOf("user_permission")];
            try {
                if (DBPw.equals(SHA256.encrypt(pw))) {
                    Cookie cookie = new Cookie("user", "idx="+DBIdx+"&id="+DBId+"&permission="+DBPer);
                    cookie.setMaxAge(60*60*24*7);
                    cookie.setPath("/");
                    response.addCookie(cookie);
                    response.sendRedirect(request.getParameter("redirect"));
                }else {
                    response.sendError(HttpServletResponse.SC_NOT_ACCEPTABLE);
                }
            } catch (NoSuchAlgorithmException e) {
            }
        }catch (Exception e) {
            response.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            e.printStackTrace();
        }
    }
}

class SHA256 {

    public static String encrypt(String text) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(text.getBytes());

        return bytesToHex(md.digest());
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder builder = new StringBuilder();
        for (byte b : bytes) {
            builder.append(String.format("%02x", b));
        }
        return builder.toString();
    }

}