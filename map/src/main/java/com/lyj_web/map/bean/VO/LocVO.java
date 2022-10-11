package com.lyj_web.map.bean.VO;

import lombok.Data;
import org.springframework.stereotype.Component;

@Component
@Data
public class LocVO {
    private String last_update;
    private String id;
    private String name;
    private String location;
    private String group;
    private String heading;
    private String speed;
}
