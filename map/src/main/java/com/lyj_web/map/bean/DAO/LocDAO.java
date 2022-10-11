package com.lyj_web.map.bean.DAO;

import com.lyj_web.map.DTO.LocDTO;
import com.lyj_web.map.bean.VO.LocVO;
import com.lyj_web.map.mappers.UpdateMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.time.Instant;

@Repository
@RequiredArgsConstructor
public class LocDAO {
    @Autowired
    UpdateMapper mapper;

    public void deleteExpired() { mapper.deleteExpired(Instant.now().getEpochSecond()); }
    public boolean updateMy(LocDTO dto) {
        return mapper.update(dto) != 0;
    }
    public LocVO getOthers(LocDTO dto) {
        return mapper.select(dto);
    }
}
