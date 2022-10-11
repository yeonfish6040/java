package com.lyj_web.map.DTO;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.springframework.stereotype.Component;

@Data
@Component
@Getter @Setter
public class LocDTO {
    private String id;
    private String group;
    private String name;
    private String location;
    private String heading;
    private String speed;

    private String table_0;


    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getGroup() { return group; }
    public void setGroup(String group) { this.group = group; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public String getHeading() { return heading; }
    public void setHeading(String heading) { this.heading = heading; }
    public String getSpeed() { return speed; }
    public void setSpeed(String speed) { this.speed = speed; }
    public String getTable_0() { return table_0; }
    public void setTable_0() { this.table_0 = String.valueOf((this.id.charAt(this.id.length() - 1))); }

    @Override
    public String toString() {
        return "{\"id\": "+id+", \"name\": "+name+", \"location\": "+location+", \"heading\": "+heading+", \"speed\": "+speed+", \"group\": "+group+"}";
    }
}
