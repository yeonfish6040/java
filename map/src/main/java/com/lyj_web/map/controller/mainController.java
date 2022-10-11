package com.lyj_web.map.controller;

import com.lyj_web.map.DTO.LocDTO;
import com.lyj_web.map.mappers.UpdateMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/map*")
public class mainController {

    @Autowired
    private UpdateMapper updateMapper;

    @GetMapping("/mapUpdate")
    public String mapUpdate(@ModelAttribute("dto") LocDTO dto) {
        return null;
    }
}
//