package com.lyj_web.map.mappers;

import com.lyj_web.map.DTO.LocDTO;
import com.lyj_web.map.bean.VO.LocVO;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Mapper
public interface UpdateMapper {

    public List<LocVO> getList();
    public int deleteExpired(LocDTO dto);
    public int insert(LocDTO dto);
    public List<LocVO> select(LocDTO dto);

    public List<String> check(String code);
}
