package com.lyj_web.map.controller;

import com.lyj_web.map.mappers.UpdateMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

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

            return "thymeleaf/err_method_not_allowed";
        }
    }

    @RequestMapping("")
    public String index() {
        return "main";
    }
}
