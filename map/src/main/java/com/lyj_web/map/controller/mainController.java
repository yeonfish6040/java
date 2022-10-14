package com.lyj_web.map.controller;

import com.lyj_web.map.DTO.LocDTO;
import com.lyj_web.map.bean.VO.LocVO;
import com.lyj_web.map.mappers.UpdateMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/map/*")
public class mainController {


    @Autowired
    UpdateMapper mapper;

    @GetMapping(value = "/mapUpdate", produces = "application/json")
    public String mapUpdate(@ModelAttribute("dto") LocDTO dto) {
        // delete Expired info
        mapper.deleteExpired(dto);

        // insert my new info
        mapper.insert(dto);

        // Get other user's info
        StringBuffer json = new StringBuffer();
        json.append("[");
        int i = 0;
        mapper.select(dto).forEach((LocVO vo) -> {
            json.append("{\"id\": \""+vo.getId()+"\", \"name\": \""+vo.getName()+"\", \"location\": \""+vo.getLocation()+"\", \"group\": \""+vo.getGroup()+"\", \"heading\": \""+vo.getHeading()+"\", \"speed\": \""+vo.getSpeed()+"\"},");

        });
        if (json.length() != 1)
            json.deleteCharAt(json.length()-1);
        json.append("]");
        return json.toString();
    }
}