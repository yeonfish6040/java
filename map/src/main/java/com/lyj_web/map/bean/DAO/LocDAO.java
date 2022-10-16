package com.lyj_web.map.bean.DAO;

import com.lyj_web.map.DTO.LocDTO;
import com.lyj_web.map.bean.VO.LocVO;
import com.lyj_web.map.mappers.UpdateMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
@RequiredArgsConstructor
public class LocDAO {
    @Autowired
    UpdateMapper mapper;

    public boolean put(LocDTO dto) {
        return mapper.insert(dto) != 0;
    }
    public boolean delete(LocDTO dto) { return mapper.deleteExpired(dto) != 0; }
    public List<LocVO> get(LocDTO dto) {
        return mapper.select(dto);
    }
}
