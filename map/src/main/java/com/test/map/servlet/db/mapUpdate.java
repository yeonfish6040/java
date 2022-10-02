package com.test.map.servlet.db;

import com.test.map.util.sql.sqlQuery;
import com.test.map.util.sql.sqlResults;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


import java.io.IOException;
import java.io.PrintWriter;
import java.time.Instant;

@WebServlet("/mapUpdate")
public class mapUpdate extends HttpServlet {
    sqlQuery sq = new sqlQuery("lyj.kr", "3306", "java", "java", "java");


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        PrintWriter out = response.getWriter();
//        if (request.getRemoteHost().equals("133.186.213.35") == false)
//            return;
        try {
            sq.query("delete from locations where last_update+600 < "+String.valueOf(Instant.now().getEpochSecond())+" or id like "+request.getParameter("id"));
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            sq.query("insert into locations(`last_update`, `id`, `name`, `location`, `group`, `heading`, `speed`) values('"+String.valueOf(Instant.now().getEpochSecond())+"', '"+request.getParameter("id")+"', '"+request.getParameter("name")+"', '"+request.getParameter("location")+"', '"+request.getParameter("group")+"', '"+request.getParameter("heading")+"', '"+request.getParameter("speed")+"')");
        } catch (Exception e) {
            e.printStackTrace();
        }
        sqlResults results;
        try {
            results = sq.query("select * from locations where id not like \""+request.getParameter("id")+"\" and `group` like \""+request.getParameter("group")+"\"");
        } catch (Exception e) {
            e.printStackTrace();
            results = null;
        }
        out.println(results.getJSON());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}
