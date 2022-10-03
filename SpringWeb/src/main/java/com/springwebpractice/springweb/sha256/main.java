package com.springwebpractice.springweb.sha256;

import com.springwebpractice.springweb.util.sql.sqlQuery;
import com.springwebpractice.springweb.util.sql.sqlResults;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

@RequestMapping("/sha256*")
@RestController
public class main {

    String dPath = new FileSystemResource("").getFile().getAbsolutePath()+"/src/main";
    String resourcePath = dPath + "/resources";
    String templatePath = resourcePath + "/templates";

    @RequestMapping("/getKey")
    public String getKey(@RequestParam String hash) throws Exception {
        String result = "";
        sqlQuery sq = new sqlQuery("localhost", "3306", "root", "root", "java");
        String[][] re = sq.query("select `key` from sha256 where hash like '"+hash+"'").get();
        result = re[1][0];
        return result;
    }
}