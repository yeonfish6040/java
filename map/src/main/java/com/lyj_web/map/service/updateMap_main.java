package com.lyj_web.map.service;

import com.lyj_web.map.DTO.LocDTO;
import com.lyj_web.map.bean.DAO.LocDAO;
import com.lyj_web.map.bean.VO.LocVO;
import com.lyj_web.map.mappers.UpdateMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class updateMap_main implements updateMap {

    @Autowired
    private LocDAO locDAO;

    @Override
    public boolean put(LocDTO locDTO) { locDAO.delete(locDTO); return locDAO.put(locDTO); }

    @Override /** JUST LIST */
    public List<LocVO> get(LocDTO locDTO) {
        return locDAO.get(locDTO);
    }

    @Override /** if isJson is true, return value will be stringify json string. is jsJson is false, return value will be toString() List */
    public String get(LocDTO locDTO, Boolean isJson) {
        if (isJson == false)
            return get(locDTO).toString();

        StringBuffer json = new StringBuffer();
        json.append("[");
        int i = 0;
        locDAO.get(locDTO).forEach((LocVO vo) -> {
            json.append("{\"id\": \""+vo.getId()+"\", \"name\": \""+vo.getName()+"\", \"location\": \""+vo.getLocation()+"\", \"group\": \""+vo.getGroup()+"\", \"heading\": \""+vo.getHeading()+"\", \"speed\": \""+vo.getSpeed()+"\"},");

        });
        if (json.length() != 1)
            json.deleteCharAt(json.length()-1);
        json.append("]");

        return json.toString();
    }
}
