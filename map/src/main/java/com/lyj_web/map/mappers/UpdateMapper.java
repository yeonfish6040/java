package com.lyj_web.map.mappers;

import com.lyj_web.map.DTO.LocDTO;
import com.lyj_web.map.bean.VO.LocVO;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

@Service
@Mapper
@Repository
public interface UpdateMapper {

    public void deleteExpired(Long time);
    public int update(LocDTO dto);
    public int insert(LocDTO dto);
    public LocVO select(LocDTO dto);
}
