package com.test.map.servlet.db;

import com.test.map.util.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.Instant;

@WebServlet(name = "mapUpdate", value = "/map_update")
public class mapUpdate extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        sqlQuery sq = new sqlQuery("lyj.kr", "3306", "java", "java", "java");
        if (!sq.cStatus()) {
            System.out.println("DB connection error");
        }
        try {
            sq.query("delete from locations where location+600 < "+String.valueOf(Instant.now().getEpochSecond())+" or id like "+request.getParameter("id"));
        } catch (Exception e) {
            e.printStackTrace();
        }
        String[][] data = {
                {"last_update", "id", "name", "location", "group"},
                {String.valueOf(Instant.now().getEpochSecond()), request.getParameter("id"), request.getParameter("name"), request.getParameter("location"), request.getParameter("group")}
        };
        try {
            sq.insert("locations", data);
        } catch (Exception e) {
            e.printStackTrace();
        }
        sqlResults results;
        try {
            results = sq.query("select * from locations");
        } catch (Exception e) {
            e.printStackTrace();
            results = null;
        }
        out.println(results.getJSON());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // handle to doGet
        doGet(request, response);
    }
}
