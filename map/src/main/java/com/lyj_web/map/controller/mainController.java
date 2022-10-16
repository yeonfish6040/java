package com.lyj_web.map.controller;

import com.lyj_web.map.DTO.LocDTO;
import com.lyj_web.map.service.updateMap_main;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;

@Slf4j
@RestController
@RequestMapping("/map/*")
public class mainController {


    @Autowired
    updateMap_main service;

    @GetMapping(value = "/mapUpdate", produces = "application/json")
    public String mapUpdate(@ModelAttribute("dto") LocDTO dto) {
        if (service.put(dto) == false)
            return String.valueOf(HttpServletResponse.SC_SERVICE_UNAVAILABLE) + " SERVICE UNAVAILABLE. (failed to run query)";
        return service.get(dto, true);
    }
}