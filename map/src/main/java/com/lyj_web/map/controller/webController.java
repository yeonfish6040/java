package com.lyj_web.map.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/map*")
public class webController {
    @RequestMapping("")
    public String index() {
        return "view";
    }
}
