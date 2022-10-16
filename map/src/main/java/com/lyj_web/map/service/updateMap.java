package com.lyj_web.map.service;

import com.lyj_web.map.DTO.LocDTO;
import com.lyj_web.map.bean.DAO.LocDAO;
import com.lyj_web.map.bean.VO.LocVO;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface updateMap {

    public boolean put(LocDTO locDTO);

    public List<LocVO> get(LocDTO locDTO);
    public String get(LocDTO locDTO, Boolean isJson);
}
