package com.lyj_web.map;

import com.lyj_web.map.DTO.LocDTO;
import com.lyj_web.map.mappers.UpdateMapper;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
@Slf4j
public class selct {

    @Autowired
    LocDTO dto;

    @Autowired
    UpdateMapper mapper;

    @Test
    public void select() {
        log.info(mapper.getList().toString());
    }
}
