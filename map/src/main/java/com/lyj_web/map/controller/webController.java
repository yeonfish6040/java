package com.lyj_web.map.controller;

import com.lyj_web.map.mappers.UpdateMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.view.RedirectView;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import java.util.Arrays;

@Controller
@RequestMapping("/map*")
public class webController {

    @Autowired
    UpdateMapper mapper;

    @RequestMapping("do")
    public String map(@RequestParam("code") String code, @RequestParam("group") String group, Model model) {
        if (mapper.check(code).isEmpty() == false) {
            model.addAttribute("group", group);
            model.addAttribute("code", code);
            return "view";
        }else {

            return "thymeleaf/error/rr_method_not_allowed";
        }
    }

    @RequestMapping("login")
    public RedirectView login(@CookieValue("userInI") String userInI, HttpServletRequest req) {
        if (userInI != null) {
            return new RedirectView("do");
        }else {
            RedirectView redirectView = new RedirectView();
            redirectView.setUrl("https://google.com");
            return redirectView;
        }
    }

    @RequestMapping("login/do")
    public RedirectView domap() {
        return new RedirectView("../do?group=a&code=a");
    }

    @RequestMapping("")
    public String index() {
        return "main";
    }
}
